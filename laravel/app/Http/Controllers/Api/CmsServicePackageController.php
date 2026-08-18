<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsServicePackage;
use Illuminate\Http\JsonResponse;

class CmsServicePackageController extends Controller
{
    public function index(): JsonResponse
    {
        $packages = CmsServicePackage::query()
            ->where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (CmsServicePackage $package) => [
                'id' => $package->id,
                'name' => $package->name,
                'description' => $package->description,
                'items' => $package->items ?? [],
                'image' => $package->image_url,
                'gallery' => $package->gallery_urls,
                'whatsapp_number' => $package->whatsapp_number,
            ]);

        return response()->json($packages);
    }
}
