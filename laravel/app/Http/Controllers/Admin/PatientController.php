<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\LoyaltyAccount;
use App\Models\LoyaltyRedemption;
use App\Models\Patient;
use App\Models\PatientMetadata;
use App\Models\UserVoucher;
use App\Services\NotificationService;
use App\Services\PatientDocumentService;
use App\Services\PlatoProxyService;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class PatientController extends Controller
{
    public function index(Request $request): View
    {
        $hasSearch = $request->filled('search_name')
            || $request->filled('search_nric')
            || $request->filled('search_phone');

        $plato = app(PlatoProxyService::class);

        if ($hasSearch) {
            $query = [];
            if ($request->filled('search_name')) {
                $query['name'] = $request->get('search_name');
            }
            if ($request->filled('search_nric')) {
                $query['nric'] = $request->get('search_nric');
            }
            if ($request->filled('search_phone')) {
                $query['telephone'] = Patient::normalisePhone($request->get('search_phone'));
            }

            $response = $plato->proxy('GET', 'search/patient', $query);
            $patientsData = is_array($response['data'] ?? null) ? $response['data'] : [];
            $total = count($patientsData);
            $currentPage = 1;
            $perPage = max($total, 1);
        } else {
            $currentPage = (int) $request->get('page', 1);
            $perPage = 20;

            $response = $plato->proxy('GET', 'patient', ['current_page' => $currentPage]);
            $patientsData = is_array($response['data'] ?? null) ? $response['data'] : [];

            // Plato doesn't return a total — if we get exactly $perPage items
            // there are probably more pages, so set total higher to show "Next".
            $count = count($patientsData);
            $total = $count >= $perPage
                ? ($currentPage * $perPage) + 1
                : (($currentPage - 1) * $perPage) + $count;
        }

        $patients = new LengthAwarePaginator(
            $patientsData,
            $total,
            $perPage,
            $currentPage,
            ['path' => $request->url(), 'query' => $request->query()]
        );

        // Build a lookup of which patients (by Plato _id) already have a local
        // app account, so the list can show a "Linked / Not Linked" badge.
        $ids = collect($patientsData)
            ->pluck('_id')
            ->filter()
            ->values()
            ->all();

        $linked = [];
        if (! empty($ids)) {
            $linked = Patient::whereIn('idplato', $ids)->pluck('idplato')->all();
        }

        return view('admin.patients.index', compact('patients', 'linked'));
    }

    public function search(Request $request): \Illuminate\Http\JsonResponse
    {
        $term = trim((string) $request->input('q'));

        if ($term === '') {
            return response()->json([]);
        }

        $plato = app(PlatoProxyService::class);
        $patients = [];
        $seen = [];

        $add = static function (array $p) use (&$patients, &$seen): void {
            $id = $p['id'] ?? null;
            if ($id === null || $id === '') {
                return;
            }
            if (isset($seen[$id])) {
                return;
            }
            $seen[$id] = true;
            $patients[] = $p;
        };

        // 1) Local app accounts — the ones that can actually receive pushes.
        //    Match by name / NRIC / phone / email.
        $localQuery = Patient::query()
            ->where(function ($q) use ($term) {
                $q->where('name', 'like', "%{$term}%")
                  ->orWhere('nric', $term)
                  ->orWhere('telephone', 'like', "%{$term}%")
                  ->orWhereRaw('LOWER(email) = ?', [strtolower($term)]);
            })
            ->limit(20)
            ->get();

        foreach ($localQuery as $p) {
            $add([
                'id' => (string) $p->idplato,
                'name' => $p->name,
                'nric' => $p->nric,
                'telephone' => $p->telephone,
                'email' => $p->email,
                'has_token' => ! empty($p->fcm_token),
            ]);
        }

        // 2) Plato search. `search/patient` honours nric/telephone/email but
        //    ignores `name`, so a name term is filtered client-side.
        $attempts = [];
        if (preg_match('/^\d{12}$/', $term)) {
            $attempts[] = ['nric' => $term];
        } elseif (str_contains($term, '@')) {
            $attempts[] = ['email' => $term];
        } else {
            $digits = preg_replace('/\D/', '', $term);
            if ($digits !== '') {
                $attempts[] = ['telephone' => Patient::normalisePhone($digits)];
            }
            $attempts[] = ['name' => $term];
        }

        foreach ($attempts as $query) {
            $query['current_page'] = 1;

            $response = $plato->proxy('GET', 'search/patient', $query);
            $rows = is_array($response['data'] ?? null) ? $response['data'] : [];

            $isNameQuery = array_key_exists('name', $query);
            $nameNeedle = strtolower($term);

            foreach ($rows as $patient) {
                if ($isNameQuery) {
                    // Plato ignores the name filter, so keep only real matches.
                    $patientName = strtolower((string) ($patient['name'] ?? ''));

                    if ($patientName === '' || ! str_contains($patientName, $nameNeedle)) {
                        continue;
                    }
                }

                $id = $patient['_id'] ?? null;
                if ($id === null || $id === '') {
                    continue;
                }

                $add([
                    'id' => (string) $id,
                    'name' => $patient['name'] ?? '',
                    'nric' => $patient['nric'] ?? '',
                    'telephone' => $patient['telephone'] ?? '',
                    'email' => $patient['email'] ?? '',
                    'has_token' => Patient::where('idplato', (string) $id)
                        ->whereNotNull('fcm_token')
                        ->where('fcm_token', '!=', '')
                        ->exists(),
                ]);
            }

            // Stop early once an exact-match attempt returned results.
            if ($patients !== []) {
                break;
            }
        }

        // Sort: token-bearing accounts first, then by name.
        usort($patients, static function (array $a, array $b): int {
            if ($a['has_token'] !== $b['has_token']) {
                return $a['has_token'] ? -1 : 1;
            }

            return strcasecmp($a['name'], $b['name']);
        });

        return response()->json(array_slice($patients, 0, 20));
    }

    public function show(Request $request, string $id): View
    {
        $plato = app(PlatoProxyService::class);

        $query = [];
        if ($request->has('sync')) {
            $query['_nocache'] = time();
        }

        $response = $plato->proxy('GET', "patient/{$id}", $query);

        $patient = $this->pluckPatient($response);

        if (empty($patient)) {
            abort(404, 'Patient not found in Plato.');
        }

        $localPatient = Patient::where('idplato', $id)->first();
        $vitalsCount = null;

        try {
            $graphingResponse = $plato->proxy('GET', "patient/{$id}/graphing");
            $vitalsCount = count($graphingResponse['data'] ?? []);
        } catch (\Exception $e) {
            $vitalsCount = null;
        }

        $documents = app(PatientDocumentService::class)->listForAdmin($id);

        $metadata = PatientMetadata::where('patient_plato_uid', $id)->first();

        $loyaltyBalance = LoyaltyAccount::where('patient_id', $id)->value('balance') ?? 0;
        $loyaltyRedemptions = $localPatient
            ? LoyaltyRedemption::where('patient_id', $localPatient->id)
                ->with('reward')
                ->orderBy('created_at', 'desc')
                ->limit(10)
                ->get()
            : collect();

        $vouchers = $localPatient
            ? UserVoucher::where('patient_id', $localPatient->id)
                ->with('promotion')
                ->orderBy('created_at', 'desc')
                ->limit(10)
                ->get()
            : collect();

        return view('admin.patients.show', compact(
            'patient', 'localPatient', 'vitalsCount', 'documents', 'metadata',
            'loyaltyBalance', 'loyaltyRedemptions', 'vouchers'
        ));
    }

    // ---------------------------------------------------------------------
    // Reset Password
    // ---------------------------------------------------------------------

    public function resetPassword(Request $request, string $id): RedirectResponse
    {
        $plato = app(PlatoProxyService::class);

        // 1. Fetch patient data from Plato.
        $response = $plato->proxy('GET', "patient/{$id}");
        $platoData = $this->pluckPatient($response);

        if (empty($platoData)) {
            return redirect()
                ->route('admin.patients.show', $id)
                ->with('error', 'Patient not found in Plato.');
        }

        // 2. Ensure local patient record exists.
        $localPatient = Patient::where('idplato', $id)->first();

        if (! $localPatient) {
            // Try other matching criteria.
            $email = $platoData['email'] ?? null;
            $nric = $platoData['nric'] ?? null;
            $telephone = $platoData['phone'] ?? $platoData['telephone'] ?? null;

            $localPatient = Patient::where('email', $email)
                ->orWhere('nric', $nric)
                ->orWhere('telephone', $telephone)
                ->first();

            if (! $localPatient) {
                $localPatient = Patient::create([
                    'name' => $platoData['name'] ?? 'He Clinic Patient',
                    'email' => $email,
                    'telephone' => $telephone ? Patient::normalisePhone($telephone) : null,
                    'nric' => $nric,
                    'idplato' => $id,
                    'password' => Hash::make(bin2hex(random_bytes(16))),
                ]);
            }
        }

        // 3. Generate temporary password.
        $tempPassword = substr(bin2hex(random_bytes(6)), 0, 10);

        $localPatient->update([
            'password' => Hash::make($tempPassword),
            'password_changed_at' => null, // force change on first login
            'reset_token' => null,
            'reset_token_expires_at' => null,
            'otp_code' => null,
            'otp_expires_at' => null,
            'otp_attempts' => 0,
        ]);

        // 4. Revoke all existing tokens so any old session is invalidated.
        $localPatient->tokens()->delete();

        Log::info('Admin reset patient password', [
            'patient_id' => $localPatient->id,
            'idplato' => $id,
            'admin_id' => $request->user()->id,
        ]);

        return redirect()
            ->route('admin.patients.show', $id)
            ->with('success', "Password reset successfully.")
            ->with('temp_password', $tempPassword)
            ->with('patient_name', $platoData['name'] ?? 'Patient');
    }

    // ---------------------------------------------------------------------
    // Metadata, Documents (unchanged)
    // ---------------------------------------------------------------------

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
            $patient = $this->pluckPatient($response);

            if (empty($patient)) {
                return [];
            }

            return [
                'name' => $patient['name'] ?? null,
                'nric' => $patient['nric'] ?? null,
                'phone' => $patient['telephone'] ?? $patient['phone'] ?? null,
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

    /**
     * Plato's patient/{id} endpoint returns data as a list [{...}] (the record
     * at index 0). This unwraps it into the patient object array.
     */
    private function pluckPatient(array $response): array
    {
        $data = $response['data'] ?? [];

        if (! is_array($data)) {
            return [];
        }

        if (isset($data[0]) && is_array($data[0])) {
            return $data[0];
        }

        return $data;
    }
}
