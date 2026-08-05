<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsOnboardingSlideRequest;
use App\Models\CmsOnboardingSlide;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
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
            $data['video'] = $this->storeAndOptimiseVideo($request->file('video'));
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
            $data['video'] = $this->storeAndOptimiseVideo($request->file('video'));
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

    /**
     * Store a video file then optimise it for fast mobile streaming:
     *   - add fast-start metadata (moov atom at beginning)
     *   - compress with H.264 baseline at mobile-friendly quality
     *
     * Falls back to the original file if ffmpeg is unavailable.
     */
    private function storeAndOptimiseVideo($file): string
    {
        $path = $file->store('onboarding', 'public');
        $fullPath = Storage::disk('public')->path($path);

        $output = dirname($fullPath).'/opt_'.$file->hashName();
        $cmd = sprintf(
            'ffmpeg -y -i %s -vf scale=\'min(1080,iw)\':-2 '
            .'-c:v libx264 -preset fast -crf 28 -movflags +faststart '
            .'-c:a aac -b:a 64k %s 2>&1',
            escapeshellarg($fullPath),
            escapeshellarg($output)
        );

        exec($cmd, $cmdOutput, $exitCode);

        if ($exitCode === 0 && file_exists($output)) {
            // Replace original with optimised version.
            rename($output, $fullPath);

            Log::info('CmsOnboarding: video optimised', [
                'path' => $path,
                'original_bytes' => filesize($fullPath),
            ]);
        } else {
            Log::warning('CmsOnboarding: ffmpeg unavailable or failed — keeping original', [
                'path' => $path,
                'exit_code' => $exitCode,
                'output' => implode("\n", array_slice($cmdOutput, -5)),
            ]);
        }

        return $path;
    }
}
