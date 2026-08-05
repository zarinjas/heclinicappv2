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
        return view('admin.cms.article_categories.form', ['article_category' => new CmsArticleCategory]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validateData($request);

        CmsArticleCategory::create($data);

        return redirect()
            ->route('admin.cms.article-categories.index')
            ->with('success', 'Category created successfully.');
    }

    public function edit(CmsArticleCategory $article_category): View
    {
        return view('admin.cms.article_categories.form', compact('article_category'));
    }

    public function update(Request $request, CmsArticleCategory $article_category): RedirectResponse
    {
        $data = $this->validateData($request);

        $article_category->update($data);

        return redirect()
            ->route('admin.cms.article-categories.index')
            ->with('success', 'Category updated successfully.');
    }

    public function destroy(CmsArticleCategory $article_category): RedirectResponse
    {
        CmsArticle::where('category_id', $article_category->id)->update([
            'category_id' => null,
            'category' => null,
        ]);

        $article_category->delete();

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
