@extends('layouts.admin')

@section('title', 'CMS — Videos')

@section('subtitle', 'Manage TikTok video content displayed in the mobile app')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex gap-2">
            <a href="{{ route('admin.cms.videos.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('status') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            <a href="{{ route('admin.cms.videos.index', ['status' => 'published']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'published' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Published
            </a>
            <a href="{{ route('admin.cms.videos.index', ['status' => 'draft']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'draft' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Drafts
            </a>
        </div>

        <a href="{{ route('admin.cms.videos.create') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Add Video
        </a>
    </div>

    @if ($videos->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No videos found.</p>
            <a href="{{ route('admin.cms.videos.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add First Video
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500 w-20">Preview</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Title</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">TikTok Author</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Published</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Sort</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($videos as $video)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    @if ($video->thumbnail_url)
                                        <img src="{{ $video->thumbnail_url }}" alt="" class="w-16 h-10 object-cover rounded border border-gray-200">
                                    @else
                                        <div class="w-16 h-10 bg-gray-100 rounded border border-gray-200 flex items-center justify-center">
                                            <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                                            </svg>
                                        </div>
                                    @endif
                                </td>
                                <td class="px-6 py-4 font-medium text-[#0F1B3D] max-w-[200px] truncate">{{ $video->title }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $video->tiktok_author ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">
                                    {{ $video->published_at ? $video->published_at->format('d M Y') : '—' }}
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $video->sort_order }}</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $video->status === 'published' ? 'bg-green-50 text-green-700' : 'bg-yellow-50 text-yellow-700' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $video->status === 'published' ? 'bg-green-500' : 'bg-yellow-500' }}"></span>
                                        {{ ucfirst($video->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.cms.videos.edit', $video) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        <form method="POST" action="{{ route('admin.cms.videos.destroy', $video) }}"
                                              onsubmit="return confirm('Delete this video? This cannot be undone.');"
                                              class="inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit"
                                                    class="p-1.5 text-gray-400 hover:text-red-500 transition-colors"
                                                    title="Delete">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($videos->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $videos->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $videos->firstItem() ?: 0 }}–{{ $videos->lastItem() ?: 0 }} of {{ $videos->total() }} videos
        </p>
    @endif
@endsection
