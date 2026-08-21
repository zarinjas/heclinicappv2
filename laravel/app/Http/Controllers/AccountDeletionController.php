<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Public web page where users can request deletion of their app account.
 *
 * This satisfies the Google Play requirement that account deletion must be
 * reachable through a web URL in addition to the in-app flow. The submitted
 * password is verified against the stored hash before the account is
 * soft-deleted, so the page cannot be used to delete someone else's account.
 */
class AccountDeletionController extends Controller
{
    /**
     * GET /account-deletion — show the deletion request form.
     */
    public function index()
    {
        return view('account-deletion');
    }

    /**
     * POST /account-deletion — verify credentials and soft-delete the account.
     */
    public function destroy(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'identifier' => ['required', 'string', 'max:191'],
            'password'   => ['required', 'string'],
        ]);

        $alreadyDeleted = $this->findDeletedPatientByIdentifier($data['identifier']);

        if ($alreadyDeleted !== null) {
            throw ValidationException::withMessages([
                'identifier' => 'This account has already been deleted.',
            ]);
        }

        $patient = $this->findPatientByIdentifier($data['identifier']);

        if ($patient === null || ! Hash::check($data['password'], $patient->password)) {
            throw ValidationException::withMessages([
                'identifier' => 'We could not verify your account. Please check your IC/passport, phone number or email and your password.',
            ]);
        }

        DB::transaction(function () use ($patient): void {
            $patient->tokens()->delete();
            $patient->update(['fcm_token' => null]);
            $patient->delete();
        });

        return redirect()->route('account-deletion')
            ->with('success', 'Your account has been deleted successfully.');
    }

    private function findPatientByIdentifier(string $identifier): ?Patient
    {
        $type = Patient::detectIdentifierType($identifier);

        if ($type === 'email') {
            return Patient::whereRaw('LOWER(email) = ?', [strtolower($identifier)])->first();
        }

        $digits = preg_replace('/\D/', '', $identifier);
        $variants = array_values(array_unique([$identifier, $digits, '+'.$digits]));

        $query = Patient::query();
        foreach ($variants as $i => $variant) {
            if ($i === 0) {
                $query->where('telephone', $variant);
            } else {
                $query->orWhere('telephone', $variant);
            }
        }

        return $query->first() ?? Patient::where('nric', $identifier)->first();
    }

    private function findDeletedPatientByIdentifier(string $identifier): ?Patient
    {
        $type = Patient::detectIdentifierType($identifier);

        if ($type === 'email') {
            return Patient::withTrashed()
                ->whereRaw('LOWER(email) = ?', [strtolower($identifier)])
                ->whereNotNull('deleted_at')
                ->first();
        }

        $digits = preg_replace('/\D/', '', $identifier);
        $variants = array_values(array_unique([$identifier, $digits, '+'.$digits]));

        return Patient::withTrashed()
            ->where(function ($query) use ($variants, $identifier): void {
                $query->whereIn('telephone', $variants)->orWhere('nric', $identifier);
            })
            ->whereNotNull('deleted_at')
            ->first();
    }
}
