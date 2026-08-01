<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsPromotion;
use Illuminate\Http\JsonResponse;

class CmsPromotionController extends Controller
{
    public function index(): JsonResponse
    {
        $today = now()->format('Y-m-d');

        $promotions = CmsPromotion::query()
            ->where('is_active', true)
            ->where(function ($q) use ($today) {
                $q->whereNull('valid_from')->orWhereDate('valid_from', '<=', $today);
            })
            ->where(function ($q) use ($today) {
                $q->whereNull('valid_until')->orWhereDate('valid_until', '>=', $today);
            })
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
                'valid_from' => $promotion->valid_from?->toDateString(),
                'valid_until' => $promotion->valid_until?->toDateString(),
                'usage_limit' => $promotion->usage_limit,
                'code_unique' => $promotion->code_unique,
            ]);

        return response()->json($promotions);
    }
}
