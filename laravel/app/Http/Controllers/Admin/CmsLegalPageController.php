<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsLegalPageRequest;
use App\Models\CmsLegalPage;

class CmsLegalPageController extends Controller
{
    public function index()
    {
        $pages = CmsLegalPage::orderBy('slug')->paginate(20);
        return view('admin.cms.legal.index', compact('pages'));
    }

    public function create()
    {
        return view('admin.cms.legal.form', ['page' => new CmsLegalPage]);
    }

    public function store(StoreCmsLegalPageRequest $request)
    {
        $data = $request->validated();
        $data['sections'] = json_decode($request->sections_json, true) ?? [];
        CmsLegalPage::create($data);
        return redirect()->route('admin.cms.legal.index')->with('success', 'Page created.');
    }

    public function edit(CmsLegalPage $page)
    {
        return view('admin.cms.legal.form', compact('page'));
    }

    public function update(StoreCmsLegalPageRequest $request, CmsLegalPage $page)
    {
        $data = $request->validated();
        $data['sections'] = json_decode($request->sections_json, true) ?? [];
        $page->update($data);
        return redirect()->route('admin.cms.legal.index')->with('success', 'Page updated.');
    }

    public function destroy(CmsLegalPage $page)
    {
        $page->delete();
        return redirect()->route('admin.cms.legal.index')->with('success', 'Page deleted.');
    }
}
