<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsVideo;
use App\Services\TiktokOembedService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class CmsVideoController extends Controller
{
    private const THUMBNAIL_CACHE_HOURS = 12;

    public function index(Request $request): JsonResponse
    {
        $limit = min((int) $request->input('limit', 10), 20);
        $page = max((int) $request->input('page', 1), 1);

        $query = CmsVideo::query()
            ->where('status', 'published')
            ->orderBy('published_at', 'desc');

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $proxyOrigin = $request->getSchemeAndHttpHost();

        $videos = $paginator->through(fn (CmsVideo $video) => [
            'id' => $video->id,
            'title' => $video->title,
            'tiktok_url' => $video->tiktok_url,
            // Serve thumbnails through our own proxy so the app never hits
            // TikTok's CDN directly: oEmbed URLs expire and TikTok's CDN
            // blocks non-browser clients (403) and can fail SSL on iOS.
            'thumbnail_url' => ($video->thumbnail_url || $video->tiktok_url)
                ? $proxyOrigin.route('cms.videos.thumbnail', $video->id, false)
                : null,
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

    public function thumbnail(CmsVideo $video): Response
    {
        if (! $video->tiktok_url && ! $video->thumbnail_url) {
            abort(404);
        }

        $cacheKey = 'video_thumbnail_'.$video->id;

        $cached = Cache::get($cacheKey);
        if (! is_array($cached) || empty($cached['bytes'])) {
            $cached = $this->fetchThumbnail($this->resolveFreshThumbnailUrl($video));
            // Only cache a successful fetch. Failed/expired fetches are retried
            // on the next request instead of being stuck for N hours.
            if (! empty($cached['bytes'])) {
                Cache::put($cacheKey, $cached, now()->addHours(self::THUMBNAIL_CACHE_HOURS));
            }
        }

        if (empty($cached['bytes'])) {
            abort(404);
        }

        return response($cached['bytes'], 200, [
            'Content-Type' => $cached['type'] ?? 'image/jpeg',
            'Cache-Control' => 'public, max-age=86400',
            'Content-Length' => (string) strlen($cached['bytes']),
        ]);
    }

    /**
     * TikTok CDN thumbnail URLs from oEmbed carry an `x-expires`/`x-signature`
     * and go stale after a few hours. Ask TikTok's oEmbed endpoint for a fresh
     * URL (using the stored video link) and only fall back to the stored URL if
     * that fails.
     */
    private function resolveFreshThumbnailUrl(CmsVideo $video): ?string
    {
        if ($video->tiktok_url) {
            try {
                $info = app(TiktokOembedService::class)->fetch($video->tiktok_url);
                if (! empty($info['thumbnail_url'])) {
                    return $info['thumbnail_url'];
                }
            } catch (\Throwable $e) {
                // fall through to the stored URL
            }
        }

        return $video->thumbnail_url ?: null;
    }

    /**
     * Downloads the thumbnail from TikTok's CDN using a browser User-Agent so
     * the CDN does not answer with a 403.
     */
    private function fetchThumbnail(?string $url): array
    {
        if (! $url) {
            return ['bytes' => '', 'type' => 'image/jpeg'];
        }

        try {
            $response = Http::timeout(15)
                ->withHeaders([
                    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
                ])
                ->get($url);

            return [
                'bytes' => $response->successful() ? $response->body() : '',
                'type' => $response->header('Content-Type') ?: 'image/jpeg',
            ];
        } catch (\Throwable $e) {
            return ['bytes' => '', 'type' => 'image/jpeg'];
        }
    }
}
