@extends('layouts.admin')

@section('title', 'CMS — Bulk Add Videos')

@section('subtitle', 'Paste multiple TikTok links at once. Thumbnails and titles are fetched automatically.')

@section('content')
    <form method="POST" action="{{ route('admin.cms.videos.bulk-store') }}" class="max-w-2xl">
        @csrf

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="urls" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        TikTok URLs <span class="text-red-500">*</span>
                    </label>
                    <textarea
                        name="urls"
                        id="urls"
                        rows="12"
                        required
                        placeholder="https://www.tiktok.com/@heclinic/video/123456789&#10;https://www.tiktok.com/@heclinic/video/987654321&#10;https://www.tiktok.com/@heclinic/video/...&#10;&#10;One link per line."
                        class="w-full px-4 py-3 text-sm font-mono border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('urls') border-red-300 @enderror"
                    >{{ old('urls') }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">
                        Paste one TikTok link per line. You can paste all links at once — thumbnails, titles and authors will be fetched automatically in the order you paste them.
                    </p>
                    @error('urls')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="status" class="block text-sm font-medium text-[#0F1B3D] mb-1">Status</label>
                        <select
                            name="status"
                            id="status"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                        >
                            <option value="published" {{ old('status', 'published') === 'published' ? 'selected' : '' }}>Published</option>
                            <option value="draft" {{ old('status') === 'draft' ? 'selected' : '' }}>Draft</option>
                        </select>
                        <p class="mt-1 text-xs text-gray-400">Videos appear in the app in the same order you paste the links.</p>
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit" id="submitBtn"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Fetch &amp; Add All
                </button>
                <a href="{{ route('admin.cms.videos.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
