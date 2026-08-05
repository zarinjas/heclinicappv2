<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsOnboardingSlideRequest;
use App\Models\CmsOnboardingSlide;
use Illuminate\Http\Request;
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
        return view('admin.cms.onboarding.form', ['onboarding' => new CmsOnboardingSlide]);
    }

    public function store(StoreCmsOnboardingSlideRequest $request)
    {
        $data = $request->validated();
        $this->fillGradientDefaults($data);

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('onboarding', 'public');
        }

        if ($request->hasFile('video')) {
            $data['video'] = $request->file('video')->store('onboarding', 'public');
        }

        CmsOnboardingSlide::create($data);
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide added.');
    }

    public function edit(CmsOnboardingSlide $onboarding)
    {
        return view('admin.cms.onboarding.form', compact('onboarding'));
    }

    public function update(StoreCmsOnboardingSlideRequest $request, CmsOnboardingSlide $onboarding)
    {
        $data = $request->validated();
        $this->fillGradientDefaults($data);

        if ($request->hasFile('image')) {
            if ($onboarding->image && Storage::disk('public')->exists($onboarding->image)) {
                Storage::disk('public')->delete($onboarding->image);
            }
            $data['image'] = $request->file('image')->store('onboarding', 'public');
        } else {
            unset($data['image']);
        }

        if ($request->hasFile('video')) {
            if ($onboarding->video && Storage::disk('public')->exists($onboarding->video)) {
                Storage::disk('public')->delete($onboarding->video);
            }
            $data['video'] = $request->file('video')->store('onboarding', 'public');
        } else {
            unset($data['video']);
        }

        $onboarding->update($data);
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide updated.');
    }

    public function destroy(CmsOnboardingSlide $onboarding)
    {
        if ($onboarding->image && Storage::disk('public')->exists($onboarding->image)) {
            Storage::disk('public')->delete($onboarding->image);
        }

        if ($onboarding->video && Storage::disk('public')->exists($onboarding->video)) {
            Storage::disk('public')->delete($onboarding->video);
        }

        $onboarding->delete();
        return redirect()->route('admin.cms.onboarding.index')->with('success', 'Slide deleted.');
    }

    public function removeMedia(Request $request, CmsOnboardingSlide $onboarding)
    {
        $type = $request->input('type');

        if ($type === 'image' && $onboarding->image) {
            if (Storage::disk('public')->exists($onboarding->image)) {
                Storage::disk('public')->delete($onboarding->image);
            }
            $onboarding->image = null;
            $onboarding->save();
        } elseif ($type === 'video' && $onboarding->video) {
            if (Storage::disk('public')->exists($onboarding->video)) {
                Storage::disk('public')->delete($onboarding->video);
            }
            $onboarding->video = null;
            $onboarding->save();
        }

        return redirect()->route('admin.cms.onboarding.edit', $onboarding)
            ->with('success', 'File removed.');
    }

    private function fillGradientDefaults(array &$data): void
    {
        $data['gradient_start'] ??= CmsOnboardingSlide::DEFAULT_GRADIENT_START;
        $data['gradient_end'] ??= CmsOnboardingSlide::DEFAULT_GRADIENT_END;
    }
}
