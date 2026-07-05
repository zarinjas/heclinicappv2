<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsArticleRequest;
use App\Models\CmsArticle;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class CmsArticleController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsArticle::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

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
        return view('admin.cms.articles.form', ['article' => new CmsArticle]);
    }

    public function store(StoreCmsArticleRequest $request): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('featured_image')) {
            $data['featured_image'] = $request->file('featured_image')->store('articles', 'public');
        }

        $data['sort_order'] = $data['sort_order'] ?? 0;
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
        return view('admin.cms.articles.form', compact('article'));
    }

    public function update(StoreCmsArticleRequest $request, CmsArticle $article): RedirectResponse
    {
        $data = $request->validated();

        if ($request->hasFile('featured_image')) {
            if ($article->featured_image && Storage::disk('public')->exists($article->featured_image)) {
                Storage::disk('public')->delete($article->featured_image);
            }
            $data['featured_image'] = $request->file('featured_image')->store('articles', 'public');
        } else {
            unset($data['featured_image']);
        }

        $data['sort_order'] = $data['sort_order'] ?? $article->sort_order;

        if ($request->input('status') === 'published' && ! $article->published_at) {
            $data['published_at'] = now();
        }

        $article->update($data);

        return redirect()
            ->route('admin.cms.articles.index')
            ->with('success', 'Article updated successfully.');
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
