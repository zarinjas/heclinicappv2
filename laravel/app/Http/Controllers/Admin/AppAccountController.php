<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Patient;
use App\Services\PatientMergeService;
use App\Services\PlatoPatientMergeService;
use App\Services\PlatoProxyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AppAccountController extends Controller
{
    /** Cap how many Plato records a single lookup will enrich with counts. */
    private const MAX_PLATO_RECORDS = 10;

    /**
     * List local app accounts (patients), newest signup first, with search,
     * linked/not-linked filter and duplicate-account detection.
     */
    public function index(Request $request): View
    {
        $query = Patient::query();

        if ($request->filled('search')) {
            $search = trim($request->input('search'));
            $query->where(function ($q) use ($search): void {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('nric', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('telephone', 'like', "%{$search}%");
            });
        }

        $view = in_array($request->input('view'), ['linked', 'not_linked'], true)
            ? $request->input('view')
            : 'all';

        if ($view === 'linked') {
            $query->whereNotNull('idplato');
        } elseif ($view === 'not_linked') {
            $query->whereNull('idplato');
        }

        $accounts = $query->orderBy('created_at', 'desc')->paginate(20)->withQueryString();

        $duplicateGroups = $this->duplicateGroups();

        return view('admin.app-accounts.index', compact('accounts', 'duplicateGroups', 'view'));
    }

    public function show(Request $request, Patient $account): View
    {
        $candidates = $this->candidateMatches($account);

        // Plato lookup is opt-in (one or more live Plato requests) so simply
        // opening the page never consumes API quota.
        $platoRecords = $request->boolean('lookup')
            ? $this->fetchPlatoRecords($account)
            : null;

        $merge = app(PlatoPatientMergeService::class);

        return view('admin.app-accounts.show', [
            'account' => $account,
            'candidates' => $candidates,
            'platoRecords' => $platoRecords,
            'mergeEnabled' => $merge->enabled(),
            'mergePhrase' => $merge->acknowledgePhrase(),
        ]);
    }

    public function merge(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'primary_id' => ['required', 'integer'],
            'duplicate_id' => ['required', 'integer', 'different:primary_id'],
        ]);

        $primary = Patient::findOrFail($validated['primary_id']);
        $duplicate = Patient::findOrFail($validated['duplicate_id']);

        try {
            app(PatientMergeService::class)->merge($primary, $duplicate, $request->user());
        } catch (\InvalidArgumentException $e) {
            throw ValidationException::withMessages([
                'duplicate_id' => $e->getMessage(),
            ]);
        }

        return redirect()
            ->route('admin.app-accounts.show', $primary)
            ->with('success', "Account '{$duplicate->name}' merged into '{$primary->name}'.");
    }

    /**
     * Point an app account at a different Plato patient record.
     *
     * Needed when Plato holds two records for the same person (same NRIC) and
     * the app linked to the wrong one — e.g. the letters/MC live under the
     * other record. This only changes which Plato id the app reads; it does NOT
     * merge Plato data. The clinic must merge the duplicate records inside
     * Plato for a permanent fix.
     */
    public function relink(Request $request, Patient $account): RedirectResponse
    {
        $validated = $request->validate([
            'plato_id' => ['required', 'string', 'max:191'],
        ]);

        $platoId = $validated['plato_id'];

        // Only allow linking to a record Plato confirms belongs to this patient.
        if (! $this->platoRecordBelongsToAccount($account, $platoId)) {
            return redirect()
                ->route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1])
                ->with('error', 'That Plato record does not match this account\'s NRIC or phone.');
        }

        $conflict = Patient::withTrashed()
            ->where('idplato', $platoId)
            ->whereKeyNot($account->id)
            ->first();

        if ($conflict !== null) {
            return redirect()
                ->route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1])
                ->with('error', "That Plato record is already linked to account #{$conflict->id} ({$conflict->name}). Merge that account first.");
        }

        $previous = $account->idplato;
        $account->update(['idplato' => $platoId]);

        Log::info('Admin relinked app account to Plato record', [
            'patient_id' => $account->id,
            'from' => $previous,
            'to' => $platoId,
            'admin_id' => $request->user()->id,
        ]);

        return redirect()
            ->route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1])
            ->with('success', 'Account relinked to the selected Plato record.');
    }

    /**
     * Merge two Plato patient records via Plato's `patient/merge` endpoint.
     *
     * DESTRUCTIVE and IRREVERSIBLE. Disabled unless `plato.merge.enabled` is
     * set, requires typing Plato's acknowledgement phrase, and re-verifies that
     * both records belong to this patient before calling Plato.
     */
    public function mergePlato(Request $request, Patient $account, PlatoPatientMergeService $merge): RedirectResponse
    {
        $validated = $request->validate([
            'survivor_id' => ['required', 'string', 'max:191'],
            'merged_id' => ['required', 'string', 'max:191', 'different:survivor_id'],
            'acknowledge' => ['required', 'string'],
        ]);

        $back = fn (string $type, string $message) => redirect()
            ->route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1])
            ->with($type, $message);

        if (! $merge->enabled()) {
            return $back('error', 'Plato merge is disabled on this server. Set PLATO_MERGE_ENABLED=true to enable it.');
        }

        if ($validated['acknowledge'] !== $merge->acknowledgePhrase()) {
            return $back('error', 'Please type the acknowledgement phrase exactly to confirm.');
        }

        // Both records must genuinely belong to this patient's NRIC/phone.
        if (! $this->platoRecordBelongsToAccount($account, $validated['survivor_id'])
            || ! $this->platoRecordBelongsToAccount($account, $validated['merged_id'])) {
            return $back('error', 'Both records must belong to this patient\'s NRIC or phone.');
        }

        $result = $merge->merge($validated['survivor_id'], $validated['merged_id']);

        if (! empty($result['error'])) {
            return $back('error', 'Plato merge failed: '.($result['message'] ?? 'unknown error'));
        }

        // Point the app account at the surviving record.
        if ($account->idplato !== $validated['survivor_id']) {
            $account->update(['idplato' => $validated['survivor_id']]);
        }

        Log::info('Admin merged Plato patient records', [
            'patient_id' => $account->id,
            'survivor_id' => $validated['survivor_id'],
            'merged_id' => $validated['merged_id'],
            'admin_id' => $request->user()->id,
        ]);

        return $back('success', 'Plato records merged into the surviving record. Letters and medical certificates may take a moment to appear.');
    }

    /**
     * Search Plato for every patient record sharing this account's NRIC and/or
     * phone, so staff can see which record actually holds the patient's
     * letters before relinking. Plato often holds several records for the same
     * person, and the app only ever reads one of them.
     *
     * @return array{identifier: array<string,string>|null, records: array<int, array<string,mixed>>, error: string|null}
     */
    private function fetchPlatoRecords(Patient $account): array
    {
        $queries = $this->platoSearchQueries($account);

        if ($queries === []) {
            return [
                'identifier' => null,
                'records' => [],
                'error' => 'This account has no NRIC or phone to search Plato by.',
            ];
        }

        $plato = app(PlatoProxyService::class);
        $rows = [];
        $seen = [];
        $firstError = null;

        foreach ($queries as $query) {
            $response = $plato->proxy('GET', 'search/patient', $query);

            if (! empty($response['error'])) {
                $firstError ??= $response['message'] ?? 'Plato search failed.';

                continue;
            }

            foreach ($response['data'] ?? [] as $row) {
                if (! is_array($row)) {
                    continue;
                }
                $id = (string) ($row['_id'] ?? '');
                if ($id === '' || isset($seen[$id])) {
                    continue;
                }
                $seen[$id] = true;
                $rows[] = $row;
            }
        }

        if ($rows === [] && $firstError !== null) {
            return [
                'identifier' => $queries[0],
                'records' => [],
                'error' => $firstError,
            ];
        }

        // Oldest first — this is the record the app links to on registration.
        usort($rows, fn ($a, $b): int => strcmp(
            (string) ($a['created_on'] ?? ''),
            (string) ($b['created_on'] ?? ''),
        ));

        $records = [];
        foreach (array_slice($rows, 0, self::MAX_PLATO_RECORDS) as $row) {
            $platoId = (string) ($row['_id'] ?? '');
            if ($platoId === '') {
                continue;
            }

            $linked = Patient::withTrashed()
                ->where('idplato', $platoId)
                ->first(['id', 'name', 'deleted_at']);

            $letters = $this->fetchLetterPreview($plato, $platoId);

            $records[] = [
                'plato_id' => $platoId,
                'name' => $row['name'] ?? '',
                'nric' => $row['nric'] ?? '',
                'telephone' => $row['telephone'] ?? ($row['phone'] ?? ''),
                'email' => $row['email'] ?? '',
                'created_on' => $row['created_on'] ?? '',
                'letters' => $letters['count'],
                'letter_preview' => $letters['preview'],
                'documents' => $this->countLocalDocuments($platoId),
                'linked_account_id' => $linked?->id,
                'linked_account_name' => $linked?->name,
            ];
        }

        return ['identifier' => $queries[0], 'records' => $records, 'error' => null];
    }

    /**
     * Every distinct identifier we can search Plato by for this account.
     *
     * @return array<int, array<string,string>>
     */
    private function platoSearchQueries(Patient $account): array
    {
        $queries = [];

        if (! empty($account->nric)) {
            $queries[] = ['nric' => $account->nric];
        }

        if (! empty($account->telephone)) {
            $queries[] = ['telephone' => $account->telephone];
        }

        return $queries;
    }

    /**
     * Whether Plato's search returns $platoId for any of this account's
     * identifiers (NRIC or phone).
     */
    private function platoRecordBelongsToAccount(Patient $account, string $platoId): bool
    {
        $queries = $this->platoSearchQueries($account);

        if ($queries === []) {
            return false;
        }

        $plato = app(PlatoProxyService::class);

        foreach ($queries as $query) {
            $response = $plato->proxy('GET', 'search/patient', $query);

            if (! empty($response['error'])) {
                continue;
            }

            foreach ($response['data'] ?? [] as $row) {
                if ((string) ($row['_id'] ?? '') === $platoId) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Letters Plato holds for a record (first page, capped at 20) plus a short
     * subject/date preview so staff can tell which record has the data.
     *
     * @return array{count:int|null, preview:array<int, array{subject:?string, created_on:?string}>}
     */
    private function fetchLetterPreview(PlatoProxyService $plato, string $platoId): array
    {
        $response = $plato->proxy('GET', 'letter', [
            'patient_id' => $platoId,
            'current_page' => 1,
        ]);

        if (! empty($response['error'])) {
            return ['count' => null, 'preview' => []];
        }

        $rows = $response['data'] ?? [];

        if (! is_array($rows)) {
            return ['count' => null, 'preview' => []];
        }

        $preview = [];
        foreach (array_slice($rows, 0, 3) as $row) {
            if (! is_array($row)) {
                continue;
            }
            $preview[] = [
                'subject' => $row['subject'] ?? null,
                'created_on' => $row['created_on'] ?? null,
            ];
        }

        return ['count' => count($rows), 'preview' => $preview];
    }

    /**
     * Number of admin/patient documents stored locally for a Plato record.
     */
    private function countLocalDocuments(string $platoId): int
    {
        return (int) DB::table('patient_documents')
            ->where('patient_plato_uid', $platoId)
            ->count();
    }

    /**
     * Group app accounts that share an NRIC, email, or phone number — the
     * "same person registered twice" signal the clinic wants to review.
     */
    private function duplicateGroups(): array
    {
        $groups = [];

        $this->collectDuplicateGroups('nric', $groups);
        $this->collectDuplicateGroups('email', $groups);
        $this->collectDuplicateGroups('telephone', $groups);

        return $groups;
    }

    private function collectDuplicateGroups(string $field, array &$groups): void
    {
        $duplicatedValues = Patient::query()
            ->select($field)
            ->whereNotNull($field)
            ->where($field, '!=', '')
            ->groupBy($field)
            ->havingRaw('COUNT(*) > 1')
            ->orderBy($field)
            ->pluck($field)
            ->all();

        foreach ($duplicatedValues as $value) {
            $patients = Patient::where($field, $value)->orderBy('created_at', 'desc')->get();

            $groups[] = [
                'field' => $field,
                'value' => $value,
                'patients' => $patients,
            ];
        }
    }

    /**
     * Other app accounts sharing an NRIC, email, or phone with the given
     * account — the merge candidates shown on the detail page.
     */
    private function candidateMatches(Patient $account): Collection
    {
        return Patient::query()
            ->whereKeyNot($account->id)
            ->where(function ($q) use ($account): void {
                if (! empty($account->nric)) {
                    $q->orWhere('nric', $account->nric);
                }

                if (! empty($account->email)) {
                    $q->orWhere('email', $account->email);
                }

                if (! empty($account->telephone)) {
                    $q->orWhere('telephone', $account->telephone);
                }
            })
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();
    }
}
