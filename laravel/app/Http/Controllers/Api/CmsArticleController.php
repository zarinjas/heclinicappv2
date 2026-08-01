<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsArticle;
use App\Models\CmsArticleCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CmsArticleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $limit = min((int) $request->input('limit', 10), 20);
        $page = max((int) $request->input('page', 1), 1);

        $query = CmsArticle::query()
            ->where('status', 'published')
            ->orderByDesc('is_featured')
            ->orderBy('sort_order')
            ->orderBy('published_at', 'desc');

        if ($request->filled('featured') && filter_var($request->input('featured'), FILTER_VALIDATE_BOOLEAN)) {
            $query->where('is_featured', true);
        }

        if ($request->filled('category')) {
            $query->where(function ($q) use ($request) {
                $q->where('category', $request->input('category'))
                    ->orWhereHas('categoryRelation', fn ($cat) => $cat->where('name', $request->input('category')));
            });
        }

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $articles = $paginator->through(fn (CmsArticle $article) => [
            'id' => $article->id,
            'title' => $article->title,
            'slug' => $article->slug,
            'excerpt' => $article->excerpt,
            'featured_image' => $article->featured_image_url,
            'category' => $article->category,
            'is_featured' => $article->is_featured,
            'author_name' => $article->author_name,
            'published_at' => $article->published_at?->toISOString(),
        ])->values();

        return response()->json([
            'data' => $articles,
            'current_page' => $paginator->currentPage(),
            'last_page' => $paginator->lastPage(),
            'per_page' => $paginator->perPage(),
            'total' => $paginator->total(),
        ]);
    }

    public function categories(): JsonResponse
    {
        $categories = CmsArticleCategory::query()
            ->where('status', 'active')
            ->whereHas('articles', fn ($q) => $q->where('status', 'published'))
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get(['id', 'name', 'slug']);

        return response()->json($categories);
    }

    public function show(string $slug): JsonResponse
    {
        $article = CmsArticle::where('slug', $slug)
            ->where('status', 'published')
            ->firstOrFail();

        return response()->json([
            'id' => $article->id,
            'title' => $article->title,
            'slug' => $article->slug,
            'body' => $article->body,
            'excerpt' => $article->excerpt,
            'featured_image' => $article->featured_image_url,
            'category' => $article->category,
            'is_featured' => $article->is_featured,
            'author_name' => $article->author_name,
            'published_at' => $article->published_at?->toISOString(),
        ]);
    }
}
