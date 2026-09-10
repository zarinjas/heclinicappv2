<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreLoyaltyRewardRequest;
use App\Models\CmsServicePackage;
use App\Models\LoyaltyReward;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class LoyaltyRewardController extends Controller
{
    public function index(Request $request): View
    {
        $query = LoyaltyReward::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

        if ($request->filled('type')) {
            $query->where('type', $request->string('type')->toString());
        }

        $rewards = $query->paginate(15)->withQueryString();

        return view('admin.loyalty.rewards.index', compact('rewards'));
    }

    public function create(): View
    {
        $packages = CmsServicePackage::where('is_active', true)->orderBy('name')->get();

        return view('admin.loyalty.rewards.form', [
            'reward'   => new LoyaltyReward,
            'packages' => $packages,
        ]);
    }

    public function store(StoreLoyaltyRewardRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('loyalty-rewards', 'public');
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['service_package_id'] = $request->filled('service_package_id') ? $request->integer('service_package_id') : null;
        $data['stock'] = $request->filled('stock') ? $request->integer('stock') : null;

        LoyaltyReward::create($data);

        return redirect()
            ->route('admin.loyalty.rewards.index')
            ->with('success', 'Reward created successfully.');
    }

    public function edit(LoyaltyReward $reward): View
    {
        $packages = CmsServicePackage::where('is_active', true)->orderBy('name')->get();

        return view('admin.loyalty.rewards.form', [
            'reward'   => $reward,
            'packages' => $packages,
        ]);
    }

    public function update(StoreLoyaltyRewardRequest $request, LoyaltyReward $reward): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($reward->image && Storage::disk('public')->exists($reward->image)) {
                Storage::disk('public')->delete($reward->image);
            }
            $data['image'] = $request->file('image')->store('loyalty-rewards', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['service_package_id'] = $request->filled('service_package_id') ? $request->integer('service_package_id') : null;
        $data['stock'] = $request->filled('stock') ? $request->integer('stock') : null;

        $reward->update($data);

        return redirect()
            ->route('admin.loyalty.rewards.index')
            ->with('success', 'Reward updated successfully.');
    }

    public function destroy(LoyaltyReward $reward): RedirectResponse
    {
        if ($reward->image && Storage::disk('public')->exists($reward->image)) {
            Storage::disk('public')->delete($reward->image);
        }

        $reward->delete();

        return redirect()
            ->route('admin.loyalty.rewards.index')
            ->with('success', 'Reward deleted successfully.');
    }
}
