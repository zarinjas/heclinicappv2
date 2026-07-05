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
            ->orderBy('sort_order')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (CmsServicePackage $package) => [
                'id' => $package->id,
                'name' => $package->name,
                'description' => $package->description,
                'image' => $package->image_url,
                'sort_order' => $package->sort_order,
            ]);

        return response()->json($packages);
    }
}
