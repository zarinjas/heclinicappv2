<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UserVoucher;
use App\Services\VoucherService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserVoucherController extends Controller
{
    public function __construct(
        private readonly VoucherService $voucherService,
    ) {}

    public function index(Request $request): View
    {
        $vouchers = $this->buildQuery($request)->paginate(15)->withQueryString();

        return view('admin.voucher-claims.index', compact('vouchers'));
    }

    public function printAll(Request $request): View
    {
        $vouchers = $this->buildQuery($request)->get();

        return view('admin.voucher-claims.print-all', compact('vouchers'));
    }

    public function print(UserVoucher $voucher): View
    {
        $voucher->load(['patient', 'promotion']);

        return view('admin.voucher-claims.print', compact('voucher'));
    }

    public function fulfill(UserVoucher $voucher): RedirectResponse
    {
        $result = $this->voucherService->fulfill($voucher, request()->user());

        if (($result['status'] ?? false) === true) {
            return back()->with('success', 'Voucher '.$voucher->code.' fulfilled.');
        }

        return back()->with('error', $result['message'] ?? 'Unable to fulfil this voucher.');
    }

    public function cancel(UserVoucher $voucher): RedirectResponse
    {
        $result = $this->voucherService->cancel($voucher);

        if (($result['status'] ?? false) === true) {
            return back()->with('success', 'Voucher '.$voucher->code.' un-marked (back to active).');
        }

        return back()->with('error', $result['message'] ?? 'Unable to cancel this voucher.');
    }

    private function buildQuery(Request $request)
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

        return $query;
    }
}
