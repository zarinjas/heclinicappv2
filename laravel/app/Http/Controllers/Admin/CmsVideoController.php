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
        $query = CmsVideo::query()->orderBy('sort_order')->orderBy('created_at', 'desc');

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

    public function store(StoreCmsVideoRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $data['sort_order'] = $data['sort_order'] ?? 0;
        $data['created_by'] = auth()->id();

        if ($request->input('status') === 'published' && empty($data['published_at'])) {
            $data['published_at'] = now();
        }

        CmsVideo::create($data);

        return redirect()
            ->route('admin.cms.videos.index')
            ->with('success', 'Video created successfully.');
    }

    public function edit(CmsVideo $video): View
    {
        return view('admin.cms.videos.form', compact('video'));
    }

    public function update(StoreCmsVideoRequest $request, CmsVideo $video): RedirectResponse
    {
        $data = $request->validated();
        $data['sort_order'] = $data['sort_order'] ?? $video->sort_order;

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
