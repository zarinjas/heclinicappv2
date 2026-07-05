<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDoctorRequest;
use App\Http\Requests\UpdateDoctorRequest;
use App\Models\Branch;
use App\Models\Doctor;
use App\Traits\BranchScoped;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class DoctorController extends Controller
{
    use BranchScoped;

    public function index(Request $request): View
    {
        $query = Doctor::query()->with('branch');
        $query = $this->scopeToUserBranch($query);

        if ($request->filled('search')) {
            $search = $request->string('search')->trim();
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('specialty', 'like', "%{$search}%")
                  ->orWhere('plato_facility_id', 'like', "%{$search}%");
            });
        }

        if ($request->filled('branch_id')) {
            $query->where('branch_id', $request->integer('branch_id'));
        }

        if ($request->has('visible')) {
            $query->where('is_visible_in_app', $request->boolean('visible'));
        }

        if ($request->filled('sort') && $request->filled('direction')) {
            $query->orderBy($request->string('sort'), $request->string('direction'));
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $doctors = $query->paginate(10)->withQueryString();
        $branches = Branch::where('is_active', true)->orderBy('name')->get();

        return view('admin.doctors.index', compact('doctors', 'branches'));
    }

    public function create(): View
    {
        $branches = Branch::where('is_active', true)->orderBy('name')->get();

        return view('admin.doctors.create', compact('branches'));
    }

    public function store(StoreDoctorRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('photo')) {
            $data['photo'] = $request->file('photo')->store('doctors', 'public');
        }

        $data['is_visible_in_app'] = $request->boolean('is_visible_in_app');
        $data['is_active'] = $request->boolean('is_active');

        Doctor::create($data);

        return redirect()
            ->route('admin.doctors.index')
            ->with('success', 'Doctor created successfully.');
    }

    public function show(Doctor $doctor): View
    {
        $doctor->load('branch');

        return view('admin.doctors.show', compact('doctor'));
    }

    public function edit(Doctor $doctor): View
    {
        $branches = Branch::where('is_active', true)->orderBy('name')->get();

        return view('admin.doctors.edit', compact('doctor', 'branches'));
    }

    public function update(UpdateDoctorRequest $request, Doctor $doctor): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('photo')) {
            if ($doctor->photo && Storage::disk('public')->exists($doctor->photo)) {
                Storage::disk('public')->delete($doctor->photo);
            }
            $data['photo'] = $request->file('photo')->store('doctors', 'public');
        }

        $data['is_visible_in_app'] = $request->boolean('is_visible_in_app');
        $data['is_active'] = $request->boolean('is_active');

        $doctor->update($data);

        return redirect()
            ->route('admin.doctors.index')
            ->with('success', 'Doctor updated successfully.');
    }

    public function destroy(Doctor $doctor): RedirectResponse
    {
        if ($doctor->photo && Storage::disk('public')->exists($doctor->photo)) {
            Storage::disk('public')->delete($doctor->photo);
        }

        $doctor->delete();

        return redirect()
            ->route('admin.doctors.index')
            ->with('success', 'Doctor deleted successfully.');
    }
}
