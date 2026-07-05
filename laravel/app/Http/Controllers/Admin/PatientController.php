<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\NotificationService;
use App\Services\PatientDocumentService;
use App\Services\PlatoProxyService;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;

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

        if (!isset($response['error']) && isset($response['data'])) {
            $patientsData = $response['data'];
            if (!is_array($patientsData)) {
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

        if (!isset($response['error']) && isset($response['data'])) {
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

        $documents = app(PatientDocumentService::class)->list($id);

        return view('admin.patients.show', compact('patient', 'vitalsCount', 'documents'));
    }

    public function uploadDocument(Request $request, string $id): RedirectResponse
    {
        $request->validate([
            'document' => ['required', 'file', 'mimetypes:application/pdf', 'max:10240'],
            'title' => ['nullable', 'string', 'max:255'],
        ], [
            'document.mimetypes' => 'Only PDF files are allowed.',
            'document.max' => 'The document must not be larger than 10MB.',
        ]);

        $service = app(PatientDocumentService::class);
        $service->upload($id, $request->file('document'), $request->input('title'), $request->user()->id);

        try {
            $filename = $request->file('document')->getClientOriginalName();
            app(NotificationService::class)->sendDocumentUploadedNotification($id, $filename);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::channel('plato')->warning('Document upload notification failed', [
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
}
