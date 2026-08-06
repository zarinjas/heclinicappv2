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
     *   - H.264 baseline (maximum device compatibility) MP4
     *   - fast-start metadata (moov atom at the beginning) so playback can
     *     begin before the file finishes downloading
     *   - audio removed (backgrounds play muted) and width capped at 720px,
     *     which shrinks the file dramatically
     *
     * Falls back to the original file if ffmpeg is unavailable or fails.
     */
    private function storeAndOptimiseVideo($file): string
    {
        // Keep the original upload as a fallback until the re-encode succeeds.
        $path = $file->store('onboarding', 'public');

        if (! $this->ffmpegAvailable()) {
            Log::warning('CmsOnboarding: ffmpeg not installed — video kept as-is', [
                'path' => $path,
            ]);
            return $path;
        }

        $fullPath = Storage::disk('public')->path($path);
        $output = dirname($fullPath).'/'.pathinfo($fullPath, PATHINFO_FILENAME).'_opt.mp4';

        $cmd = sprintf(
            'ffmpeg -y -i %s '
            .'-vf "scale=w=\'min(720,iw)\':h=-2:force_original_aspect_ratio=decrease,'
            .'fps=24,format=yuv420p" '
            .'-c:v libx264 -preset veryfast -crf 28 -profile:v baseline -level 3.1 '
            .'-an -movflags +faststart %s 2>&1',
            escapeshellarg($fullPath),
            escapeshellarg($output)
        );

        exec($cmd, $cmdOutput, $exitCode);

        if ($exitCode === 0 && is_file($output) && filesize($output) > 0) {
            // Replace the original upload with the optimised MP4 so the URL in
            // the database always points at a clean, fast-start file.
            $optimisedPath = 'onboarding/'.basename($output);
            Storage::disk('public')->delete($path);

            Log::info('CmsOnboarding: video optimised', [
                'path' => $optimisedPath,
                'bytes' => filesize($output),
            ]);

            return $optimisedPath;
        }

        @unlink($output);
        Log::warning('CmsOnboarding: ffmpeg failed — keeping original', [
            'path' => $path,
            'exit_code' => $exitCode,
            'output' => implode("\n", array_slice($cmdOutput, -8)),
        ]);

        return $path;
    }

    private function ffmpegAvailable(): bool
    {
        exec('ffmpeg -version 2>&1', $_, $code);

        return $code === 0;
    }
}
