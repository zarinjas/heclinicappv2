<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UserVoucher;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserVoucherController extends Controller
{
    public function index(Request $request): View
    {
        $query = UserVoucher::query()
            ->with(['patient', 'promotion'])
            ->orderBy('created_at', 'desc');

        if ($request->filled('q')) {
            $search = $request->string('q')->toString();
            $query->where(function ($q) use ($search) {
                $q->where('code', 'like', "%{$search}%")
                    ->orWhereHas('patient', function ($pq) use ($search) {
                        $pq->where('name', 'like', "%{$search}%")
                            ->orWhere('nric', 'like', "%{$search}%")
                            ->orWhere('telephone', 'like', "%{$search}%");
                    });
            });
        }

        if ($request->filled('status')) {
            $status = $request->string('status')->toString();

            if ($status === 'used') {
                $query->whereNotNull('used_at');
            } elseif ($status === 'expired') {
                $query->whereNull('used_at')
                    ->whereNotNull('expires_at')
                    ->whereDate('expires_at', '<', now()->toDateString());
            } elseif ($status === 'active') {
                $query->whereNull('used_at')
                    ->where(function ($q) {
                        $q->whereNull('expires_at')
                            ->orWhereDate('expires_at', '>=', now()->toDateString());
                    });
            }
        }

        $vouchers = $query->paginate(15)->withQueryString();

        return view('admin.voucher-claims.index', compact('vouchers'));
    }

    public function markUsed(UserVoucher $voucher): RedirectResponse
    {
        if ($voucher->used_at !== null) {
            return back()->with('error', 'This voucher has already been marked as used.');
        }

        $voucher->update(['used_at' => now()]);

        return back()->with('success', 'Voucher marked as used.');
    }
}
