<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyRedemption;
use App\Services\LoyaltyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class LoyaltyRedemptionController extends Controller
{
    public function __construct(
        private readonly LoyaltyService $loyalty,
    ) {}

    public function index(Request $request): View
    {
        $query = $this->buildQuery($request);

        $redemptions = $query->paginate(15)->withQueryString();

        return view('admin.loyalty.redemptions.index', compact('redemptions'));
    }

    public function printAll(Request $request): View
    {
        $redemptions = $this->buildQuery($request)->get();

        return view('admin.loyalty.redemptions.print-all', compact('redemptions'));
    }

    private function buildQuery(Request $request)
    {
        $query = LoyaltyRedemption::query()
            ->with(['patient', 'reward'])
            ->orderBy('created_at', 'desc');

        if ($request->filled('q')) {
            $search = $request->string('q')->toString();
            $query->where(function ($q) use ($search) {
                $q->where('redemption_code', 'like', "%{$search}%")
                    ->orWhereHas('patient', function ($pq) use ($search) {
                        $pq->where('name', 'like', "%{$search}%")
                            ->orWhere('nric', 'like', "%{$search}%")
                            ->orWhere('telephone', 'like', "%{$search}%");
                    })
                    ->orWhereHas('reward', function ($rq) use ($search) {
                        $rq->where('name', 'like', "%{$search}%");
                    });
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status')->toString());
        }

        return $query;
    }

    public function fulfill(LoyaltyRedemption $redemption): RedirectResponse
    {
        $result = $this->loyalty->fulfillRedemption($redemption, request()->user());

        if (($result['status'] ?? false) === true) {
            return back()->with('success', 'Redemption '.$redemption->redemption_code.' marked as fulfilled.');
        }

        return back()->with('error', $result['message'] ?? 'Unable to fulfil this redemption.');
    }

    public function cancel(LoyaltyRedemption $redemption): RedirectResponse
    {
        $result = $this->loyalty->cancelRedemption($redemption, request()->user());

        if (($result['status'] ?? false) === true) {
            return back()->with('success', 'Redemption '.$redemption->redemption_code.' cancelled and points refunded.');
        }

        return back()->with('error', $result['message'] ?? 'Unable to cancel this redemption.');
    }

    public function print(LoyaltyRedemption $redemption): View
    {
        $redemption->load(['patient', 'reward', 'fulfiller']);

        return view('admin.loyalty.redemptions.print', compact('redemption'));
    }
}
