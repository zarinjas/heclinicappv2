<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsVideo;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CmsVideoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $limit = min((int) $request->input('limit', 10), 20);
        $page = max((int) $request->input('page', 1), 1);

        $query = CmsVideo::query()
            ->where('status', 'published')
            ->orderBy('sort_order')
            ->orderBy('published_at', 'desc');

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $videos = $paginator->through(fn (CmsVideo $video) => [
            'id' => $video->id,
            'title' => $video->title,
            'tiktok_url' => $video->tiktok_url,
            'thumbnail_url' => $video->thumbnail_url,
            'tiktok_author' => $video->tiktok_author,
            'published_at' => $video->published_at?->toISOString(),
        ])->values();

        return response()->json([
            'data' => $videos,
            'current_page' => $paginator->currentPage(),
            'last_page' => $paginator->lastPage(),
            'per_page' => $paginator->perPage(),
            'total' => $paginator->total(),
        ]);
    }
}
