<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsOnboardingSlideRequest;
use App\Models\CmsOnboardingSlide;

class CmsOnboardingSlideController extends Controller
{
    public function index()
    {
        $slides = CmsOnboardingSlide::orderBy('sort_order')->orderBy('created_at')->paginate(20);
        return view('admin.cms.onboarding.index', compact('slides'));
    }

    public function create()
    {
        return view('admin.cms.onboarding.form', ['slide' => new CmsOnboardingSlide]);
    }

    public function store(StoreCmsOnboardingSlideRequest $request)
    {
        CmsOnboardingSlide::create($request->validated());
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide added.');
    }

    public function edit(CmsOnboardingSlide $slide)
    {
        return view('admin.cms.onboarding.form', compact('slide'));
    }

    public function update(StoreCmsOnboardingSlideRequest $request, CmsOnboardingSlide $slide)
    {
        $slide->update($request->validated());
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide updated.');
    }

    public function destroy(CmsOnboardingSlide $slide)
    {
        $slide->delete();
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide deleted.');
    }
}
