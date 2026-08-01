<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\PatientMetadata;
use App\Services\NotificationService;
use App\Services\PatientDocumentService;
use App\Services\PlatoProxyService;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Log;

class PatientController extends Controller
{
    public function index(Request $request): View
    {
        $query = [
            'current_page' => $request->get('page', 1),
        ];

        if ($request->filled('search_name')) {
            $query['name'] = $request->get('search_name');
        }
        if ($request->filled('search_nric')) {
            $query['nric'] = $request->get('search_nric');
        }
        if ($request->filled('search_phone')) {
            $query['phone'] = $request->get('search_phone');
        }

        $plato = app(PlatoProxyService::class);
        $response = $plato->proxy('GET', 'patient', $query);

        $patientsData = [];

        if (! isset($response['error']) && isset($response['data'])) {
            $patientsData = $response['data'];
            if (! is_array($patientsData)) {
                $patientsData = [];
            }
        }

        $currentPage = (int) $request->get('page', 1);
        $perPage = 20;
        $count = count($patientsData);
        $total = $count >= $perPage
            ? ($currentPage * $perPage) + $perPage
            : (($currentPage - 1) * $perPage) + $count;

        $patients = new LengthAwarePaginator(
            $patientsData,
            $total,
            $perPage,
            $currentPage,
            ['path' => $request->url(), 'query' => $request->query()]
        );

        return view('admin.patients.index', compact('patients'));
    }

    public function show(Request $request, string $id): View
    {
        $plato = app(PlatoProxyService::class);

        $query = [];
        if ($request->has('sync')) {
            $query['_nocache'] = time();
        }

        $response = $plato->proxy('GET', "patient/{$id}", $query);

        $patient = [];

        if (! isset($response['error']) && isset($response['data'])) {
            $patient = is_array($response['data']) ? $response['data'] : (array) $response['data'];
        }

        if (empty($patient)) {
            abort(404, 'Patient not found in Plato.');
        }

        $vitalsCount = null;
        try {
            $graphingResponse = $plato->proxy('GET', "patient/{$id}/graphing");
            $vitalsCount = count($graphingResponse['data'] ?? []);
        } catch (\Exception $e) {
            $vitalsCount = null;
        }

        $documents = app(PatientDocumentService::class)->listForAdmin($id);

        $metadata = PatientMetadata::where('patient_plato_uid', $id)->first();

        return view('admin.patients.show', compact('patient', 'vitalsCount', 'documents', 'metadata'));
    }

    public function updateMetadata(Request $request, string $id): RedirectResponse
    {
        $validated = $request->validate([
            'notes' => ['nullable', 'string', 'max:5000'],
            'tags' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'in:normal,vip,blocked'],
        ]);

        $tags = collect(explode(',', $validated['tags'] ?? ''))
            ->map(fn (string $tag) => trim($tag))
            ->filter(fn (string $tag) => $tag !== '')
            ->values();

        PatientMetadata::updateOrCreate(
            ['patient_plato_uid' => $id],
            [
                'notes' => $validated['notes'] ?? null,
                'tags' => $tags->isEmpty() ? null : $tags->toArray(),
                'status' => $validated['status'] ?? null,
                'updated_by' => $request->user()->id,
            ]
        );

        return redirect()
            ->route('admin.patients.show', $id)
            ->with('success', 'Patient notes updated successfully.');
    }

    public function uploadDocument(Request $request, string $id): RedirectResponse
    {
        $request->validate([
            'document' => ['required', 'file', 'mimetypes:application/pdf,image/jpeg,image/png,image/gif,image/webp', 'max:10240'],
            'title' => ['nullable', 'string', 'max:255'],
        ], [
            'document.mimetypes' => 'Only PDF or image files are allowed.',
            'document.max' => 'The document must not be larger than 10MB.',
        ]);

        $service = app(PatientDocumentService::class);

        $patientInfo = $this->fetchPatientInfo($id);
        $branchId = $this->resolvePatientBranch($id, $patientInfo);

        $service->upload(
            $id,
            $request->file('document'),
            $request->input('title'),
            $request->user()->id,
            $patientInfo,
            $branchId,
            'admin',
        );

        try {
            $filename = $request->file('document')->getClientOriginalName();
            app(NotificationService::class)->sendDocumentUploadedNotification($id, $filename, $patientInfo['name'] ?? null);
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Document upload notification failed', [
                'patient_plato_id' => $id,
                'error' => $e->getMessage(),
            ]);
        }

        return redirect()
            ->route('admin.patients.show', $id)
            ->with('success', 'Document uploaded successfully.');
    }

    public function deleteDocument(Request $request, string $id, string $filename): RedirectResponse
    {
        $service = app(PatientDocumentService::class);
        $service->delete($id, $filename);

        return redirect()
            ->route('admin.patients.show', $id)
            ->with('success', 'Document deleted successfully.');
    }

    private function fetchPatientInfo(string $id): array
    {
        try {
            $plato = app(PlatoProxyService::class);
            $response = $plato->proxy('GET', "patient/{$id}");
            $patient = $response['data'] ?? [];

            if (! is_array($patient)) {
                return [];
            }

            return [
                'name' => $patient['name'] ?? null,
                'nric' => $patient['nric'] ?? null,
                'phone' => $patient['phone'] ?? null,
            ];
        } catch (\Exception $e) {
            return [];
        }
    }

    private function resolvePatientBranch(string $id, array $patientInfo): ?int
    {
        $appointment = Appointment::query()
            ->where(function ($q) use ($id, $patientInfo) {
                $q->where('patient_plato_id', $id);

                if (! empty($patientInfo['nric'])) {
                    $q->orWhere('patient_nric', $patientInfo['nric']);
                }

                if (! empty($patientInfo['phone'])) {
                    $q->orWhere('patient_phone', $patientInfo['phone']);
                }
            })
            ->orderBy('appointment_date', 'desc')
            ->orderBy('id', 'desc')
            ->first();

        return $appointment?->branch_id;
    }
}
