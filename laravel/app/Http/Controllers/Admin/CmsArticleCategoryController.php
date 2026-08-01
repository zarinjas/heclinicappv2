<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CmsArticle;
use App\Models\CmsArticleCategory;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class CmsArticleCategoryController extends Controller
{
    public function index(): View
    {
        $categories = CmsArticleCategory::query()
            ->withCount('articles')
            ->orderBy('created_at', 'desc')
            ->orderBy('name')
            ->paginate(15);

        return view('admin.cms.article_categories.index', compact('categories'));
    }

    public function create(): View
    {
        return view('admin.cms.article_categories.form', ['category' => new CmsArticleCategory]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validateData($request);

        CmsArticleCategory::create($data);

        return redirect()
            ->route('admin.cms.article-categories.index')
            ->with('success', 'Category created successfully.');
    }

    public function edit(CmsArticleCategory $category): View
    {
        return view('admin.cms.article_categories.form', compact('category'));
    }

    public function update(Request $request, CmsArticleCategory $category): RedirectResponse
    {
        $data = $this->validateData($request);

        $category->update($data);

        return redirect()
            ->route('admin.cms.article-categories.index')
            ->with('success', 'Category updated successfully.');
    }

    public function destroy(CmsArticleCategory $category): RedirectResponse
    {
        CmsArticle::where('category_id', $category->id)->update([
            'category_id' => null,
            'category' => null,
        ]);

        $category->delete();

        return redirect()
            ->route('admin.cms.article-categories.index')
            ->with('success', 'Category deleted successfully.');
    }

    private function validateData(Request $request): array
    {
        $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'slug' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        return $request->only(['name', 'slug', 'status']);
    }
}
