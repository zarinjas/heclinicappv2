<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsOnboardingSlide;

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
                'image'          => $slide->image_url,
                'gradient_start' => $slide->gradient_start,
                'gradient_end'   => $slide->gradient_end,
            ]);
    }
}
