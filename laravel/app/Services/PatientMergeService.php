<?php

namespace App\Services;

use App\Models\Patient;
use App\Models\User;
use App\Models\UserVoucher;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Merges two local app accounts (duplicate registrations for the same person)
 * into a single primary account.
 *
 * Most patient data (appointments, documents, metadata, notifications, loyalty)
 * is keyed by Plato id, so merging only needs to reconcile local-account-scoped
 * data: vouchers, Sanctum sessions, and the identity fields on the row itself.
 */
class PatientMergeService
{
    /**
     * Merge $duplicate into $primary. $primary is kept; $duplicate is
     * soft-deleted and its login sessions are revoked.
     *
     * @throws \InvalidArgumentException When the accounts can't be merged.
     */
    public function merge(Patient $primary, Patient $duplicate, ?User $admin = null): void
    {
        if ($primary->is($duplicate)) {
            throw new \InvalidArgumentException('Cannot merge an account into itself.');
        }

        if ($primary->trashed() || $duplicate->trashed()) {
            throw new \InvalidArgumentException('Cannot merge a deleted account.');
        }

        // If both accounts are linked to Plato but point at different records,
        // their Plato-keyed data (appointments, documents, loyalty, inbox) can't
        // be combined locally. The clinic must reconcile the Plato side first.
        $primaryIdplato = $primary->idplato;
        $duplicateIdplato = $duplicate->idplato;

        if (! empty($primaryIdplato) && ! empty($duplicateIdplato) && $primaryIdplato !== $duplicateIdplato) {
            throw new \InvalidArgumentException(
                'These accounts are linked to two different Plato records ('.$primaryIdplato
                .' and '.$duplicateIdplato.'). Reconcile the Plato records first.'
            );
        }

        DB::transaction(function () use ($primary, $duplicate): void {
            $this->reassignVouchers($primary, $duplicate);

            // Revoke the duplicate's sessions so it can't be used to log in.
            $duplicate->tokens()->delete();

            $this->fillIdentityGaps($primary, $duplicate);

            $duplicate->delete();
        });

        Log::info('Admin merged patient accounts', [
            'primary_id' => $primary->id,
            'duplicate_id' => $duplicate->id,
            'admin_id' => $admin?->id,
            'primary_nric' => $primary->nric,
        ]);
    }

    private function reassignVouchers(Patient $primary, Patient $duplicate): void
    {
        UserVoucher::where('patient_id', $duplicate->id)
            ->get()
            ->each(function (UserVoucher $voucher) use ($primary): void {
                $alreadyClaimed = UserVoucher::where('patient_id', $primary->id)
                    ->where('promotion_id', $voucher->promotion_id)
                    ->exists();

                // user_vouchers has a unique [patient_id, promotion_id] pair; if
                // the primary already claimed the same promotion, drop the dup.
                if ($alreadyClaimed) {
                    $voucher->delete();

                    return;
                }

                $voucher->update(['patient_id' => $primary->id]);
            });
    }

    /**
     * Fill empty identity fields on the primary from the duplicate so the
     * duplicate's login methods (Apple sub, Plato link, email, phone) continue
     * to resolve to the surviving account.
     */
    private function fillIdentityGaps(Patient $primary, Patient $duplicate): void
    {
        $updates = [];

        // apple_sub and idplato carry UNIQUE indexes, so the duplicate must
        // free the value before the primary can adopt it.
        foreach (['apple_sub', 'idplato'] as $field) {
            if (empty($primary->{$field}) && ! empty($duplicate->{$field})) {
                $value = $duplicate->{$field};
                $duplicate->update([$field => null]);
                $updates[$field] = $value;
            }
        }

        foreach ([
            'email', 'pending_email', 'telephone',
            'nationality', 'dob', 'sex', 'title', 'address', 'referred_by',
        ] as $field) {
            if (empty($primary->{$field}) && ! empty($duplicate->{$field})) {
                $updates[$field] = $duplicate->{$field};
            }
        }

        if (empty($primary->fcm_token) && ! empty($duplicate->fcm_token)) {
            $updates['fcm_token'] = $duplicate->fcm_token;
        }

        if (! empty($updates)) {
            $primary->update($updates);
        }
    }
}
