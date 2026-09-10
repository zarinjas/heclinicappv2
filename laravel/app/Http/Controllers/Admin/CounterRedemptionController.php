<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyRedemption;
use App\Models\UserVoucher;
use App\Services\LoyaltyService;
use App\Services\VoucherService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\View\View;

class CounterRedemptionController extends Controller
{
    public function __construct(
        private readonly LoyaltyService $loyalty,
        private readonly VoucherService $voucherService,
    ) {}

    public function index(Request $request): View
    {
        $query = trim((string) $request->input('q', ''));
        $results = $query === '' ? collect() : $this->lookup($query);

        return view('admin.counter.index', [
            'query'   => $query,
            'results' => $results,
        ]);
    }

    public function fulfill(Request $request, string $type, int $id): RedirectResponse
    {
        if ($type === 'voucher') {
            $voucher = UserVoucher::findOrFail($id);
            $result = $this->voucherService->fulfill($voucher, $request->user());
            $back = route('admin.redeem-at-counter', ['q' => $voucher->code]);
        } else {
            $redemption = LoyaltyRedemption::findOrFail($id);
            $result = $this->loyalty->fulfillRedemption($redemption, $request->user());
            $back = route('admin.redeem-at-counter', ['q' => $redemption->redemption_code]);
        }

        if (($result['status'] ?? false) === true) {
            return redirect($back)->with('success', 'Code '.($result['code'] ?? ($result['redemption_code'] ?? '')).' fulfilled.');
        }

        return redirect($back)->with('error', $result['message'] ?? 'Unable to fulfil.');
    }

    public function cancel(Request $request, string $type, int $id): RedirectResponse
    {
        if ($type === 'voucher') {
            $voucher = UserVoucher::findOrFail($id);
            $result = $this->voucherService->cancel($voucher);
            $back = route('admin.redeem-at-counter', ['q' => $voucher->code]);
        } else {
            $redemption = LoyaltyRedemption::findOrFail($id);
            $result = $this->loyalty->cancelRedemption($redemption, $request->user());
            $back = route('admin.redeem-at-counter', ['q' => $redemption->redemption_code]);
        }

        if (($result['status'] ?? false) === true) {
            return redirect($back)->with('success', 'Code '.($result['code'] ?? ($result['redemption_code'] ?? '')).' cancelled.');
        }

        return redirect($back)->with('error', $result['message'] ?? 'Unable to cancel.');
    }

    private function lookup(string $query): Collection
    {
        $results = collect();

        $vouchers = UserVoucher::query()
            ->with(['patient', 'promotion'])
            ->where(function ($q) use ($query) {
                $q->where('code', 'like', "%{$query}%")
                    ->orWhereHas('patient', function ($pq) use ($query) {
                        $pq->where('name', 'like', "%{$query}%")
                            ->orWhere('nric', 'like', "%{$query}%")
                            ->orWhere('telephone', 'like', "%{$query}%");
                    })
                    ->orWhereHas('promotion', function ($rq) use ($query) {
                        $rq->where('title', 'like', "%{$query}%");
                    });
            })
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get();

        foreach ($vouchers as $voucher) {
            $results->push($this->normaliseVoucher($voucher));
        }

        $redemptions = LoyaltyRedemption::query()
            ->with(['patient', 'reward'])
            ->where(function ($q) use ($query) {
                $q->where('redemption_code', 'like', "%{$query}%")
                    ->orWhereHas('patient', function ($pq) use ($query) {
                        $pq->where('name', 'like', "%{$query}%")
                            ->orWhere('nric', 'like', "%{$query}%")
                            ->orWhere('telephone', 'like', "%{$query}%");
                    })
                    ->orWhereHas('reward', function ($rq) use ($query) {
                        $rq->where('name', 'like', "%{$query}%");
                    });
            })
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get();

        foreach ($redemptions as $redemption) {
            $results->push($this->normaliseRedemption($redemption));
        }

        return $results;
    }

    private function normaliseVoucher(UserVoucher $voucher): array
    {
        $status = $voucher->status; // active | used | expired

        return [
            'type'          => 'voucher',
            'id'            => $voucher->id,
            'code'          => $voucher->code,
            'kind'          => 'Voucher',
            'patient_name'  => $voucher->patient?->name ?? '—',
            'patient_nric'  => $voucher->patient?->nric ?? '—',
            'title'         => $voucher->promotion?->title ?? 'Voucher',
            'value'         => $voucher->promotion?->cta_text ?? $voucher->promotion?->promo_code ?? 'Discount',
            'status'        => $status,
            'is_fulfillable' => $status === 'active',
            'is_cancelable'  => $voucher->used_at !== null,
            'created_at'    => $voucher->created_at,
            'expires_at'    => $voucher->expires_at,
            'print_url'     => route('admin.voucher-claims.print', $voucher),
        ];
    }

    private function normaliseRedemption(LoyaltyRedemption $redemption): array
    {
        $status = $redemption->status; // pending | fulfilled | cancelled
        $value = $redemption->discount_value !== null
            ? 'RM '.number_format($redemption->discount_value, 2).' off'
            : number_format(abs($redemption->points)).' pts';

        return [
            'type'          => 'redemption',
            'id'            => $redemption->id,
            'code'          => $redemption->redemption_code,
            'kind'          => 'Points',
            'patient_name'  => $redemption->patient?->name ?? '—',
            'patient_nric'  => $redemption->patient?->nric ?? '—',
            'title'         => $redemption->reward?->name ?? 'Points discount',
            'value'         => $value,
            'status'        => $status,
            'is_fulfillable' => $status === 'pending',
            'is_cancelable'  => $status === 'pending',
            'created_at'    => $redemption->created_at,
            'expires_at'    => $redemption->expires_at,
            'print_url'     => route('admin.loyalty.redemptions.print', $redemption),
        ];
    }
}
