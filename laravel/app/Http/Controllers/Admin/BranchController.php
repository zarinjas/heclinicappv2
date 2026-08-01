<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBranchRequest;
use App\Http\Requests\UpdateBranchRequest;
use App\Models\Branch;
use App\Services\PlatoSyncService;
use App\Traits\BranchScoped;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class BranchController extends Controller
{
    use BranchScoped;

    public function index(Request $request): View
    {
        $query = Branch::query();
        $query = $this->scopeToUserBranch($query);

        if ($request->filled('search')) {
            $search = $request->string('search')->trim();
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%")
                    ->orWhere('plato_facility_id', 'like', "%{$search}%");
            });
        }

        if ($request->has('visible')) {
            $query->where('is_visible_in_app', $request->boolean('visible'));
        }

        if ($request->filled('sort') && $request->filled('direction')) {
            $query->orderBy($request->string('sort'), $request->string('direction'));
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $branches = $query->paginate(10)->withQueryString();

        return view('admin.branches.index', compact('branches'));
    }

    public function syncFromPlato(PlatoSyncService $sync): RedirectResponse
    {
        $result = $sync->syncAll();

        $message = $result['success']
            ? $result['message']." Branches: {$result['branches_created']} created, {$result['branches_updated']} updated. Doctors: {$result['doctors_created']} created, {$result['doctors_updated']} updated."
            : $result['message'];

        return redirect()
            ->route('admin.branches.index')
            ->with($result['success'] ? 'success' : 'error', $message);
    }

    public function create(): View
    {
        return view('admin.branches.create');
    }

    public function store(StoreBranchRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('branches', 'public');
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['is_visible_in_app'] = $request->boolean('is_visible_in_app');

        Branch::create($data);

        return redirect()
            ->route('admin.branches.index')
            ->with('success', 'Branch created successfully.');
    }

    public function show(Branch $branch): View
    {
        return view('admin.branches.show', compact('branch'));
    }

    public function edit(Branch $branch): View
    {
        return view('admin.branches.edit', compact('branch'));
    }

    public function update(UpdateBranchRequest $request, Branch $branch): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($branch->image && Storage::disk('public')->exists($branch->image)) {
                Storage::disk('public')->delete($branch->image);
            }
            $data['image'] = $request->file('image')->store('branches', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['is_visible_in_app'] = $request->boolean('is_visible_in_app');

        $branch->update($data);

        return redirect()
            ->route('admin.branches.index')
            ->with('success', 'Branch updated successfully.');
    }

    public function destroy(Branch $branch): RedirectResponse
    {
        if ($branch->image && Storage::disk('public')->exists($branch->image)) {
            Storage::disk('public')->delete($branch->image);
        }

        $branch->delete();

        return redirect()
            ->route('admin.branches.index')
            ->with('success', 'Branch deleted successfully.');
    }
}
