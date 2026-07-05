<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsSliderRequest;
use App\Models\CmsSlider;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsSliderController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsSlider::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('is_active', $request->boolean('status'));
        }

        $sliders = $query->paginate(15)->withQueryString();

        return view('admin.cms.sliders.index', compact('sliders'));
    }

    public function create(): View
    {
        return view('admin.cms.sliders.form', ['slider' => new CmsSlider]);
    }

    public function store(StoreCmsSliderRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('sliders', 'public');
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? 0;

        CmsSlider::create($data);

        return redirect()
            ->route('admin.cms.sliders.index')
            ->with('success', 'Slider created successfully.');
    }

    public function edit(CmsSlider $slider): View
    {
        return view('admin.cms.sliders.form', compact('slider'));
    }

    public function update(StoreCmsSliderRequest $request, CmsSlider $slider): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($slider->image && Storage::disk('public')->exists($slider->image)) {
                Storage::disk('public')->delete($slider->image);
            }
            $data['image'] = $request->file('image')->store('sliders', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? $slider->sort_order;

        $slider->update($data);

        return redirect()
            ->route('admin.cms.sliders.index')
            ->with('success', 'Slider updated successfully.');
    }

    public function destroy(CmsSlider $slider): RedirectResponse
    {
        if ($slider->image && Storage::disk('public')->exists($slider->image)) {
            Storage::disk('public')->delete($slider->image);
        }

        $slider->delete();

        return redirect()
            ->route('admin.cms.sliders.index')
            ->with('success', 'Slider deleted successfully.');
    }
}
