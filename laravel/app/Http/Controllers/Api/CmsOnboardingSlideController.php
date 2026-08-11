<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsOnboardingSlide;
use Illuminate\Support\Facades\Storage;

class CmsOnboardingSlideController extends Controller
{
    public function index()
    {
        return CmsOnboardingSlide::where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn ($slide) => [
                'id'             => $slide->id,
                'title'          => $slide->title,
                'subtitle'       => $slide->subtitle,
                // Only return media whose file actually exists on disk. An admin
                // upload can leave a stale DB reference (e.g. after a file is
                // removed), and returning a URL that 404s makes the app wait on
                // a dead request before falling back. Returning null lets it go
                // straight to the image/gradient.
                'image'          => $this->urlIfExists($slide->image, $slide->image_url),
                'video'          => $this->urlIfExists($slide->video, $slide->video_url),
                'gradient_start' => $slide->gradient_start,
                'gradient_end'   => $slide->gradient_end,
            ]);
    }

    private function urlIfExists(?string $path, ?string $url): ?string
    {
        if (empty($path) || empty($url)) {
            return null;
        }

        return Storage::disk('public')->exists($path) ? $url : null;
    }
}
