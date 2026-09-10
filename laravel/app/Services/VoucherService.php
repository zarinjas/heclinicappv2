<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserVoucher;

final class VoucherService
{
    /**
     * Mark a claimed voucher as fulfilled (used at the counter). Staff apply
     * the discount manually in Plato — this just records that it was consumed.
     */
    public function fulfill(UserVoucher $voucher, User $admin): array
    {
        if ($voucher->used_at !== null) {
            return ['status' => false, 'message' => 'This voucher has already been fulfilled.'];
        }

        if ($voucher->status === 'expired') {
            return ['status' => false, 'message' => 'This voucher has expired.'];
        }

        $voucher->update(['used_at' => now()]);

        return ['status' => true, 'code' => $voucher->code];
    }

    /**
     * Undo a fulfilment (staff made a mistake). Returns the voucher to active.
     */
    public function cancel(UserVoucher $voucher): array
    {
        if ($voucher->used_at === null) {
            return ['status' => false, 'message' => 'This voucher has not been fulfilled yet.'];
        }

        $voucher->update(['used_at' => null]);

        return ['status' => true, 'code' => $voucher->code];
    }
}
