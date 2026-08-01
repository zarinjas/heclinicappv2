<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsPromotion;
use Illuminate\Http\JsonResponse;

class CmsPromotionController extends Controller
{
    public function index(): JsonResponse
    {
        $promotions = CmsPromotion::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (CmsPromotion $promotion) => [
                'id' => $promotion->id,
                'title' => $promotion->title,
                'description' => $promotion->description,
                'image' => $promotion->image_url,
                'cta_text' => $promotion->cta_text,
                'cta_link' => $promotion->cta_link,
                'promo_code' => $promotion->promo_code,
                'sort_order' => $promotion->sort_order,
            ]);

        return response()->json($promotions);
    }
}
