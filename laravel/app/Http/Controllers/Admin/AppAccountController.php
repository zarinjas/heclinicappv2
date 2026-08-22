<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Patient;
use App\Services\PatientMergeService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AppAccountController extends Controller
{
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

    public function show(Patient $account): View
    {
        $candidates = $this->candidateMatches($account);

        return view('admin.app-accounts.show', compact('account', 'candidates'));
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
