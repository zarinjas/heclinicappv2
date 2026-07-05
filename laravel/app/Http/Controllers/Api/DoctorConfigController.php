<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Doctor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class DoctorConfigController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Doctor::query()
            ->with('branch')
            ->where('is_active', true)
            ->where('is_visible_in_app', true);

        if ($request->filled('branch_id')) {
            $branchId = $request->string('branch_id')->trim();
            $branch = Branch::where('plato_facility_id', $branchId)->first();

            if ($branch) {
                $query->where('branch_id', $branch->id);
            } else {
                $query->where('branch_id', -1);
            }
        }

        if ($request->has('visible')) {
            $query->where('is_visible_in_app', $request->boolean('visible'));
        }

        $doctors = $query->orderBy('name')->get();

        $data = $doctors->map(fn (Doctor $doctor) => [
            'id' => $doctor->plato_facility_id ?? (string) $doctor->id,
            'name' => $doctor->name,
            'specialty' => $doctor->specialty,
            'photo' => $doctor->photo ? asset('storage/' . $doctor->photo) : null,
            'is_visible_in_app' => $doctor->is_visible_in_app,
            'branch_id' => $doctor->branch?->plato_facility_id,
            'branch_name' => $doctor->branch?->name,
        ]);

        return response()->json($data);
    }
}
