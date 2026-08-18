<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsClinicInfo;
use Illuminate\Http\JsonResponse;

class CmsClinicInfoController extends Controller
{
    public function index(): JsonResponse
    {
        $items = CmsClinicInfo::query()
            ->where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (CmsClinicInfo $item) => [
                'id' => $item->id,
                'image' => $item->image_url,
            ]);

        return response()->json($items);
    }
}
