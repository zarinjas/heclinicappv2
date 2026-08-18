<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsClinicInfoRequest;
use App\Models\CmsClinicInfo;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsClinicInfoController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsClinicInfo::query()->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('is_active', $request->boolean('status'));
        }

        $items = $query->paginate(15)->withQueryString();

        return view('admin.cms.clinic-info.index', compact('items'));
    }

    public function create(): View
    {
        return view('admin.cms.clinic-info.form', ['item' => new CmsClinicInfo]);
    }

    public function store(StoreCmsClinicInfoRequest $request): RedirectResponse
    {
        $data = $request->validated();

        $data['image'] = $request->file('image')->store('clinic-info', 'public');
        $data['is_active'] = $request->boolean('is_active');

        CmsClinicInfo::create($data);

        return redirect()
            ->route('admin.cms.clinic-info.index')
            ->with('success', 'Clinic info added successfully.');
    }

    public function edit(CmsClinicInfo $item): View
    {
        return view('admin.cms.clinic-info.form', compact('item'));
    }

    public function update(StoreCmsClinicInfoRequest $request, CmsClinicInfo $item): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($item->image && Storage::disk('public')->exists($item->image)) {
                Storage::disk('public')->delete($item->image);
            }
            $data['image'] = $request->file('image')->store('clinic-info', 'public');
        } else {
            unset($data['image']);
        }

        $data['is_active'] = $request->boolean('is_active');

        $item->update($data);

        return redirect()
            ->route('admin.cms.clinic-info.index')
            ->with('success', 'Clinic info updated successfully.');
    }

    public function destroy(CmsClinicInfo $item): RedirectResponse
    {
        if ($item->image && Storage::disk('public')->exists($item->image)) {
            Storage::disk('public')->delete($item->image);
        }

        $item->delete();

        return redirect()
            ->route('admin.cms.clinic-info.index')
            ->with('success', 'Clinic info deleted successfully.');
    }
}
