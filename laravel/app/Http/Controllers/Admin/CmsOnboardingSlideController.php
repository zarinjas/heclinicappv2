<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsOnboardingSlideRequest;
use App\Models\CmsOnboardingSlide;
use Illuminate\Support\Facades\Storage;

class CmsOnboardingSlideController extends Controller
{
    public function index()
    {
        $slides = CmsOnboardingSlide::orderBy('created_at', 'desc')->paginate(20);
        return view('admin.cms.onboarding.index', compact('slides'));
    }

    public function create()
    {
        return view('admin.cms.onboarding.form', ['slide' => new CmsOnboardingSlide]);
    }

    public function store(StoreCmsOnboardingSlideRequest $request)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('onboarding', 'public');
        }

        CmsOnboardingSlide::create($data);
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide added.');
    }

    public function edit(CmsOnboardingSlide $slide)
    {
        return view('admin.cms.onboarding.form', compact('slide'));
    }

    public function update(StoreCmsOnboardingSlideRequest $request, CmsOnboardingSlide $slide)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($slide->image && Storage::disk('public')->exists($slide->image)) {
                Storage::disk('public')->delete($slide->image);
            }
            $data['image'] = $request->file('image')->store('onboarding', 'public');
        } else {
            unset($data['image']);
        }

        $slide->update($data);
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide updated.');
    }

    public function destroy(CmsOnboardingSlide $slide)
    {
        if ($slide->image && Storage::disk('public')->exists($slide->image)) {
            Storage::disk('public')->delete($slide->image);
        }

        $slide->delete();
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide deleted.');
    }
}
