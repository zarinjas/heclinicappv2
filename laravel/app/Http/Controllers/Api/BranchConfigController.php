<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use Illuminate\Http\JsonResponse;

class BranchConfigController extends Controller
{
    public function index(): JsonResponse
    {
        $branches = Branch::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get()
            ->map(fn (Branch $branch) => [
                'id' => $branch->id,
                'name' => $branch->name,
                'address' => $branch->address,
                'phone' => $branch->phone,
                'whatsapp_number' => $branch->whatsapp_number,
                'image' => $branch->image ? asset('storage/' . $branch->image) : null,
                'operating_hours' => $branch->operating_hours,
                'google_maps_link' => $branch->google_maps_link,
                'plato_facility_id' => $branch->plato_facility_id,
            ]);

        return response()->json($branches);
    }
}
