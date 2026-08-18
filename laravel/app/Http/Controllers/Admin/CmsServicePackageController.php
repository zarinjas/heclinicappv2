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
        $query = CmsServicePackage::query()->orderBy('created_at', 'desc');

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

        $data['gallery'] = $this->storeGallery($request);

        $data['items'] = $this->parseItems($request->input('items'));

        $data['is_active'] = $request->boolean('is_active');

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

        $data['gallery'] = $this->storeGallery($request, $service_package);

        $data['items'] = $this->parseItems($request->input('items'));

        $data['is_active'] = $request->boolean('is_active');

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

        foreach ($service_package->gallery ?? [] as $path) {
            if ($path && Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
        }

        $service_package->delete();

        return redirect()
            ->route('admin.cms.service-packages.index')
            ->with('success', 'Service package deleted successfully.');
    }

    private function parseItems(?string $items): array
    {
        if (! $items) {
            return [];
        }

        return array_values(array_filter(
            array_map('trim', preg_split('/\r\n|\r|\n/', $items)),
            fn (string $line) => $line !== ''
        ));
    }

    private function storeGallery(Request $request, ?CmsServicePackage $service_package = null): array
    {
        $kept = array_values(array_filter($request->input('keep_gallery', [])));

        if (! $request->hasFile('gallery')) {
            return $service_package ? array_values(array_intersect($service_package->gallery ?? [], $kept)) : $kept;
        }

        $new = [];
        foreach ($request->file('gallery') as $file) {
            $new[] = $file->store('service-packages', 'public');
        }

        $merged = array_values(array_unique(array_merge($kept, $new)));

        if (! $service_package) {
            return $merged;
        }

        foreach ($service_package->gallery ?? [] as $path) {
            if ($path && ! in_array($path, $kept, true) && ! in_array($path, $new, true)
                && Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
        }

        return $merged;
    }
}
