<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsArticleRequest;
use App\Models\CmsArticle;
use App\Models\CmsArticleCategory;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsArticleController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsArticle::query()
            ->with('categoryRelation')
            ->orderByDesc('is_featured')
            ->orderBy('sort_order')
            ->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->input('search') . '%');
        }

        $articles = $query->paginate(15)->withQueryString();

        return view('admin.cms.articles.index', compact('articles'));
    }

    public function create(): View
    {
        $categories = CmsArticleCategory::where('status', 'active')->orderBy('sort_order')->orderBy('name')->get();

        return view('admin.cms.articles.form', ['article' => new CmsArticle, 'categories' => $categories]);
    }

    public function store(StoreCmsArticleRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $data['is_featured'] = $request->boolean('is_featured');

        if ($request->hasFile('featured_image')) {
            $data['featured_image'] = $request->file('featured_image')->store('articles', 'public');
        }

        $this->syncCategory($data);

        $data['sort_order'] = $data['sort_order'] ?? (int) CmsArticle::max('sort_order') + 1;
        $data['created_by'] = auth()->id();

        if ($request->input('status') === 'published' && empty($data['published_at'])) {
            $data['published_at'] = now();
        }

        CmsArticle::create($data);

        return redirect()
            ->route('admin.cms.articles.index')
            ->with('success', 'Article created successfully.');
    }

    public function edit(CmsArticle $article): View
    {
        $categories = CmsArticleCategory::where('status', 'active')->orderBy('sort_order')->orderBy('name')->get();

        return view('admin.cms.articles.form', compact('article', 'categories'));
    }

    public function update(StoreCmsArticleRequest $request, CmsArticle $article): RedirectResponse
    {
        $data = $request->validated();
        $data['is_featured'] = $request->boolean('is_featured');

        if ($request->hasFile('featured_image')) {
            if ($article->featured_image && Storage::disk('public')->exists($article->featured_image)) {
                Storage::disk('public')->delete($article->featured_image);
            }
            $data['featured_image'] = $request->file('featured_image')->store('articles', 'public');
        } else {
            unset($data['featured_image']);
        }

        $this->syncCategory($data);

        $data['sort_order'] = $data['sort_order'] ?? $article->sort_order;

        if ($request->input('status') === 'published' && ! $article->published_at) {
            $data['published_at'] = now();
        }

        $article->update($data);

        return redirect()
            ->route('admin.cms.articles.index')
            ->with('success', 'Article updated successfully.');
    }

    private function syncCategory(array &$data): void
    {
        if (! empty($data['category_id'])) {
            $category = CmsArticleCategory::find($data['category_id']);
            if ($category) {
                $data['category'] = $category->name;
            }
        } elseif (empty($data['category'])) {
            $data['category'] = null;
            $data['category_id'] = null;
        }
    }

    public function destroy(CmsArticle $article): RedirectResponse
    {
        if ($article->featured_image && Storage::disk('public')->exists($article->featured_image)) {
            Storage::disk('public')->delete($article->featured_image);
        }

        $article->delete();

        return redirect()
            ->route('admin.cms.articles.index')
            ->with('success', 'Article deleted successfully.');
    }
}
