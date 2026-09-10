<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCmsVideoRequest;
use App\Models\CmsVideo;
use App\Services\TiktokOembedService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class CmsVideoController extends Controller
{
    public function index(Request $request): View
    {
        $query = CmsVideo::query()->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $videos = $query->paginate(15)->withQueryString();

        return view('admin.cms.videos.index', compact('videos'));
    }

    public function create(): View
    {
        return view('admin.cms.videos.form', ['video' => new CmsVideo]);
    }

    public function fetchInfo(Request $request, TiktokOembedService $oembedService): JsonResponse
    {
        $request->validate([
            'tiktok_url' => ['required', 'url'],
        ]);

        $info = $oembedService->fetch($request->input('tiktok_url'));

        if (! $info || ! ($info['title'] ?? null)) {
            return response()->json([
                'success' => false,
                'message' => 'Could not fetch video info. Please check the TikTok URL.',
            ], 422);
        }

        return response()->json([
            'success' => true,
            'title' => $info['title'],
            'thumbnail_url' => $info['thumbnail_url'],
            'tiktok_author' => $info['author_name'],
        ]);
    }

    public function fetchAllThumbnails(TiktokOembedService $oembedService): RedirectResponse
    {
        $videos = CmsVideo::whereNull('thumbnail_url')
            ->orWhere('thumbnail_url', '')
            ->get();

        if ($videos->isEmpty()) {
            return redirect()
                ->route('admin.cms.videos.index')
                ->with('success', 'All videos already have thumbnails.');
        }

        $updated = 0;
        $failed = 0;

        foreach ($videos as $video) {
            if (! $video->tiktok_url) {
                $failed++;

                continue;
            }

            $info = $oembedService->fetch($video->tiktok_url);

            if (! $info || ! ($info['thumbnail_url'] ?? null)) {
                $failed++;

                continue;
            }

            $video->update([
                'thumbnail_url' => $info['thumbnail_url'],
                'title' => $info['title'] ?? $video->title,
                'tiktok_author' => $info['author_name'] ?? $video->tiktok_author,
            ]);

            $updated++;
        }

        $message = "Fetched thumbnails for {$updated} video".($updated !== 1 ? 's' : '').'.';

        if ($failed > 0) {
            $message .= " {$failed} failed to fetch. Please retry or update manually.";
        }

        return redirect()
            ->route('admin.cms.videos.index')
            ->with($failed > 0 ? 'error' : 'success', $message);
    }

    public function store(StoreCmsVideoRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $data['created_by'] = auth()->id();

        if ($request->input('status') === 'published' && empty($data['published_at'])) {
            $data['published_at'] = now();
        }

        CmsVideo::create($data);

        return redirect()
            ->route('admin.cms.videos.index')
            ->with('success', 'Video created successfully.');
    }

    public function bulk(): View
    {
        return view('admin.cms.videos.bulk');
    }

    public function bulkStore(Request $request, TiktokOembedService $oembedService): RedirectResponse
    {
        $request->validate([
            'urls' => ['required', 'string'],
            'status' => ['nullable', 'in:draft,published'],
        ]);

        $status = $request->input('status', 'published');
        $urls = array_values(array_filter(array_map('trim', preg_split('/[\r\n,]+/', $request->input('urls')))));

        if (empty($urls)) {
            return redirect()
                ->route('admin.cms.videos.bulk')
                ->with('error', 'No URLs were provided. Paste at least one TikTok link.');
        }

        $created = 0;
        $skipped = [];

        foreach ($urls as $url) {
            if (! filter_var($url, FILTER_VALIDATE_URL) || ! str_contains($url, 'tiktok.com')) {
                $skipped[] = $url;

                continue;
            }

            if (CmsVideo::where('tiktok_url', $url)->exists()) {
                $skipped[] = $url;

                continue;
            }

            $info = $oembedService->fetch($url);

            if (! $info || ! ($info['title'] ?? null) || ! ($info['thumbnail_url'] ?? null)) {
                $skipped[] = $url;

                continue;
            }

            CmsVideo::create([
                'title' => $info['title'],
                'tiktok_url' => $url,
                'thumbnail_url' => $info['thumbnail_url'],
                'tiktok_author' => $info['author_name'],
                'status' => $status,
                'published_at' => $status === 'published' ? now() : null,
                'created_by' => auth()->id(),
            ]);

            $created++;
        }

        if ($created === 0) {
            return redirect()
                ->route('admin.cms.videos.bulk')
                ->with('error', 'No videos were added. Check the links (must be valid tiktok.com URLs) and try again.');
        }

        $message = "Added {$created} video".($created > 1 ? 's' : '').'.';

        if (count($skipped) > 0) {
            $message .= ' '.count($skipped).' link'.(count($skipped) > 1 ? 's' : '').' skipped (invalid, duplicate, or could not be fetched).';
        }

        return redirect()
            ->route('admin.cms.videos.index')
            ->with('success', $message);
    }

    public function edit(CmsVideo $video): View
    {
        return view('admin.cms.videos.form', compact('video'));
    }

    public function update(StoreCmsVideoRequest $request, CmsVideo $video): RedirectResponse
    {
        $data = $request->validated();

        if ($request->input('status') === 'published' && ! $video->published_at) {
            $data['published_at'] = now();
        }

        $video->update($data);

        return redirect()
            ->route('admin.cms.videos.index')
            ->with('success', 'Video updated successfully.');
    }

    public function destroy(CmsVideo $video): RedirectResponse
    {
        $video->delete();

        return redirect()
            ->route('admin.cms.videos.index')
            ->with('success', 'Video deleted successfully.');
    }
}
