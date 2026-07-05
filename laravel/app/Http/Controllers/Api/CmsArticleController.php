<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsArticle;
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
            ->orderBy('sort_order')
            ->orderBy('published_at', 'desc');

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $articles = $paginator->through(fn (CmsArticle $article) => [
            'id' => $article->id,
            'title' => $article->title,
            'slug' => $article->slug,
            'excerpt' => $article->excerpt,
            'featured_image' => $article->featured_image_url,
            'category' => $article->category,
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
            'author_name' => $article->author_name,
            'published_at' => $article->published_at?->toISOString(),
        ]);
    }
}
