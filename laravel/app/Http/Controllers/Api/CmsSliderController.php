<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsSlider;
use Illuminate\Http\JsonResponse;

class CmsSliderController extends Controller
{
    public function index(): JsonResponse
    {
        $sliders = CmsSlider::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (CmsSlider $slider) => [
                'id' => $slider->id,
                'image' => $slider->image_url,
                'title' => $slider->title,
                'link_url' => $slider->link_url,
                'sort_order' => $slider->sort_order,
            ]);

        return response()->json($sliders);
    }
}
