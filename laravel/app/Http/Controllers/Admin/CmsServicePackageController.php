<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsServicePackageRequest;
use App\Models\CmsServicePackage;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsServicePackageController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsServicePackage::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('is_active', $request->boolean('status'));
        }

        $packages = $query->paginate(15)->withQueryString();

        return view('admin.cms.service-packages.index', compact('packages'));
    }

    public function create(): View
    {
        return view('admin.cms.service-packages.form', ['package' => new CmsServicePackage]);
    }

    public function store(StoreCmsServicePackageRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('service-packages', 'public');
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? 0;

        CmsServicePackage::create($data);

        return redirect()
            ->route('admin.cms.service-packages.index')
            ->with('success', 'Service package created successfully.');
    }

    public function edit(CmsServicePackage $service_package): View
    {
        return view('admin.cms.service-packages.form', ['package' => $service_package]);
    }

    public function update(StoreCmsServicePackageRequest $request, CmsServicePackage $service_package): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($service_package->image && Storage::disk('public')->exists($service_package->image)) {
                Storage::disk('public')->delete($service_package->image);
            }
            $data['image'] = $request->file('image')->store('service-packages', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');
        $data['sort_order'] = $data['sort_order'] ?? $service_package->sort_order;

        $service_package->update($data);

        return redirect()
            ->route('admin.cms.service-packages.index')
            ->with('success', 'Service package updated successfully.');
    }

    public function destroy(CmsServicePackage $service_package): RedirectResponse
    {
        if ($service_package->image && Storage::disk('public')->exists($service_package->image)) {
            Storage::disk('public')->delete($service_package->image);
        }

        $service_package->delete();

        return redirect()
            ->route('admin.cms.service-packages.index')
            ->with('success', 'Service package deleted successfully.');
    }
}
