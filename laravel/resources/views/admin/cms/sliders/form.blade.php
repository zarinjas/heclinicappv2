@php
    $isEdit = isset($slider) && $slider->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Slider' : 'Add Slider')

@section('subtitle', $isEdit ? 'Update slider image, title, link, or status' : 'Upload a new hero slider image')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.sliders.update', $slider) : route('admin.cms.sliders.store') }}"
          enctype="multipart/form-data"
          class="max-w-2xl">
        @csrf
        @if ($isEdit)
            @method('PUT')
        @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="image" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Slider Image {{ $isEdit ? '' : '<span class="text-red-500">*</span>' }}
                    </label>
                    <input
                        type="file"
                        name="image"
                        id="image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Recommended size: 1200×400px (full-width banner). Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $slider->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $slider->image_url }}" alt="" class="w-64 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
                </div>

                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">Title</label>
                    <input
                        type="text"
                        name="title"
                        id="title"
                        value="{{ old('title', $slider->title) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="Optional slide title"
                    >
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="link_url" class="block text-sm font-medium text-[#0F1B3D] mb-1">Link URL</label>
                    <input
                        type="url"
                        name="link_url"
                        id="link_url"
                        value="{{ old('link_url', $slider->link_url) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('link_url') border-red-300 @enderror"
                        placeholder="https://example.com/page"
                    >
                    <p class="mt-1 text-xs text-gray-400">Where the user goes when they tap the slider. Leave empty for no action.</p>
                    @error('link_url')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                    <input
                        type="number"
                        name="sort_order"
                        id="sort_order"
                        value="{{ old('sort_order', $slider->sort_order ?? 0) }}"
                        min="0"
                        class="w-32 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('sort_order') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Lower numbers appear first in the slider carousel.</p>
                    @error('sort_order')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="inline-flex items-center gap-2 cursor-pointer">
                        <input
                            type="hidden"
                            name="is_active"
                            value="0"
                        >
                        <input
                            type="checkbox"
                            name="is_active"
                            id="is_active"
                            value="1"
                            {{ old('is_active', $slider->is_active ?? true) ? 'checked' : '' }}
                            class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                        >
                        <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-400 ml-6">Inactive sliders are hidden from the mobile app. Deactivate instead of deleting to keep for later.</p>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Slider' : 'Create Slider' }}
                </button>
                <a href="{{ route('admin.cms.sliders.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
