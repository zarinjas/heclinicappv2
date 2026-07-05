@php
    $isEdit = isset($video) && $video->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Video' : 'Add Video')

@section('subtitle', $isEdit ? 'Update video title, URL, thumbnail, or status' : 'Add a TikTok video to the mobile app')

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const fetchBtn = document.getElementById('fetchBtn');
        const tiktokUrlInput = document.getElementById('tiktok_url');
        const titleInput = document.getElementById('title');
        const thumbnailPreview = document.getElementById('thumbnailPreview');
        const thumbnailInput = document.getElementById('thumbnail_url');
        const authorInput = document.getElementById('tiktok_author');
        const fetchStatus = document.getElementById('fetchStatus');
        const submitBtn = document.getElementById('submitBtn');

        fetchBtn.addEventListener('click', async function () {
            const url = tiktokUrlInput.value.trim();
            if (!url) {
                fetchStatus.textContent = 'Please enter a TikTok URL first.';
                fetchStatus.className = 'mt-2 text-xs text-red-500';
                return;
            }

            fetchBtn.disabled = true;
            fetchBtn.innerHTML = '<svg class="w-4 h-4 animate-spin inline" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg> Fetching...';
            fetchStatus.textContent = '';

            try {
                const response = await fetch('{{ route('admin.cms.videos.fetch-info') }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({ tiktok_url: url }),
                });

                const data = await response.json();

                if (data.success) {
                    titleInput.value = data.title || '';
                    thumbnailInput.value = data.thumbnail_url || '';
                    authorInput.value = data.tiktok_author || '';

                    if (data.thumbnail_url) {
                        thumbnailPreview.innerHTML = `<img src="${data.thumbnail_url}" alt="Thumbnail" class="w-48 h-auto rounded-lg border border-gray-200">`;
                    }

                    fetchStatus.textContent = 'Video info fetched successfully!';
                    fetchStatus.className = 'mt-2 text-xs text-green-600';
                } else {
                    fetchStatus.textContent = data.message || 'Failed to fetch video info.';
                    fetchStatus.className = 'mt-2 text-xs text-red-500';
                }
            } catch (err) {
                fetchStatus.textContent = 'Network error. Please try again.';
                fetchStatus.className = 'mt-2 text-xs text-red-500';
            } finally {
                fetchBtn.disabled = false;
                fetchBtn.innerHTML = 'Fetch Info';
            }
        });
    });
</script>
@endpush

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.videos.update', $video) : route('admin.cms.videos.store') }}"
          class="max-w-2xl">
        @csrf
        @if ($isEdit)
            @method('PUT')
        @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="tiktok_url" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        TikTok URL <span class="text-red-500">*</span>
                    </label>
                    <div class="flex gap-2">
                        <input
                            type="url"
                            name="tiktok_url"
                            id="tiktok_url"
                            value="{{ old('tiktok_url', $video->tiktok_url) }}"
                            class="flex-1 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('tiktok_url') border-red-300 @enderror"
                            placeholder="https://www.tiktok.com/@username/video/123456789"
                        >
                        <button type="button" id="fetchBtn"
                                class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1a2d5e] transition-colors whitespace-nowrap">
                            Fetch Info
                        </button>
                    </div>
                    <p class="mt-1 text-xs text-gray-400">Paste a TikTok URL and click "Fetch Info" to auto-populate title and thumbnail.</p>
                    <div id="fetchStatus"></div>
                    @error('tiktok_url')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div id="thumbnailPreview" class="@if (!$isEdit || !$video->thumbnail_url) hidden @endif">
                    <p class="text-xs text-gray-400 mb-1">Thumbnail Preview:</p>
                    @if ($isEdit && $video->thumbnail_url)
                        <img src="{{ $video->thumbnail_url }}" alt="Thumbnail" class="w-48 h-auto rounded-lg border border-gray-200">
                    @endif
                </div>

                <input type="hidden" name="thumbnail_url" id="thumbnail_url" value="{{ old('thumbnail_url', $video->thumbnail_url) }}">

                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Title <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="title"
                        id="title"
                        value="{{ old('title', $video->title) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="Auto-populated from TikTok, editable"
                    >
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="tiktok_author" class="block text-sm font-medium text-[#0F1B3D] mb-1">TikTok Author</label>
                    <input
                        type="text"
                        name="tiktok_author"
                        id="tiktok_author"
                        value="{{ old('tiktok_author', $video->tiktok_author) }}"
                        readonly
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg bg-gray-50 text-gray-500 outline-none"
                        placeholder="Auto-populated from TikTok"
                    >
                    @error('tiktok_author')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div>
                        <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                        <input
                            type="number"
                            name="sort_order"
                            id="sort_order"
                            value="{{ old('sort_order', $video->sort_order ?? 0) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('sort_order') border-red-300 @enderror"
                        >
                        @error('sort_order')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="published_at" class="block text-sm font-medium text-[#0F1B3D] mb-1">Published Date</label>
                        <input
                            type="datetime-local"
                            name="published_at"
                            id="published_at"
                            value="{{ old('published_at', $video->published_at ? $video->published_at->format('Y-m-d\TH:i') : '') }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('published_at') border-red-300 @enderror"
                        >
                        @error('published_at')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="status" class="block text-sm font-medium text-[#0F1B3D] mb-1">Status</label>
                        <select
                            name="status"
                            id="status"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('status') border-red-300 @enderror"
                        >
                            <option value="draft" {{ old('status', $video->status) === 'draft' ? 'selected' : '' }}>Draft</option>
                            <option value="published" {{ old('status', $video->status) === 'published' ? 'selected' : '' }}>Published</option>
                        </select>
                        @error('status')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit" id="submitBtn"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Video' : 'Create Video' }}
                </button>
                <a href="{{ route('admin.cms.videos.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
