<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsPromotionRequest;
use App\Models\CmsPromotion;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsPromotionController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsPromotion::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('is_active', $request->boolean('status'));
        }

        $promotions = $query->paginate(15)->withQueryString();

        return view('admin.cms.promotions.index', compact('promotions'));
    }

    public function create(): View
    {
        return view('admin.cms.promotions.form', ['promotion' => new CmsPromotion]);
    }

    public function store(StoreCmsPromotionRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('promotions', 'public');
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? 0;

        CmsPromotion::create($data);

        return redirect()
            ->route('admin.cms.promotions.index')
            ->with('success', 'Promotion created successfully.');
    }

    public function edit(CmsPromotion $promotion): View
    {
        return view('admin.cms.promotions.form', compact('promotion'));
    }

    public function update(StoreCmsPromotionRequest $request, CmsPromotion $promotion): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($promotion->image && Storage::disk('public')->exists($promotion->image)) {
                Storage::disk('public')->delete($promotion->image);
            }
            $data['image'] = $request->file('image')->store('promotions', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? $promotion->sort_order;

        $promotion->update($data);

        return redirect()
            ->route('admin.cms.promotions.index')
            ->with('success', 'Promotion updated successfully.');
    }

    public function destroy(CmsPromotion $promotion): RedirectResponse
    {
        if ($promotion->image && Storage::disk('public')->exists($promotion->image)) {
            Storage::disk('public')->delete($promotion->image);
        }

        $promotion->delete();

        return redirect()
            ->route('admin.cms.promotions.index')
            ->with('success', 'Promotion deleted successfully.');
    }
}
