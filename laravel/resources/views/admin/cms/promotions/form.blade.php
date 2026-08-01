@php
    $isEdit = isset($promotion) && $promotion->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Promotion' : 'Add Promotion')

@section('subtitle', $isEdit ? 'Update promotion details, image, and status' : 'Create a new promotion or offer for the mobile app')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.promotions.update', $promotion) : route('admin.cms.promotions.store') }}"
          enctype="multipart/form-data"
          class="max-w-2xl">
        @csrf
        @if ($isEdit)
            @method('PUT')
        @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Title <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="title"
                        id="title"
                        value="{{ old('title', $promotion->title) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="e.g. Pakej Kesihatan Asas"
                    >
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="description" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Description <span class="text-red-500">*</span>
                    </label>
                    <textarea
                        name="description"
                        id="description"
                        rows="4"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('description') border-red-300 @enderror"
                        placeholder="Describe what the promotion includes..."
                    >{{ old('description', $promotion->description) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">Full description of the promotion package.</p>
                    @error('description')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="image" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Promotion Image
                    </label>
                    <input
                        type="file"
                        name="image"
                        id="image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Optional hero image. Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $promotion->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $promotion->image_url }}" alt="" class="w-64 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="cta_text" class="block text-sm font-medium text-[#0F1B3D] mb-1">CTA Button Text</label>
                        <input
                            type="text"
                            name="cta_text"
                            id="cta_text"
                            value="{{ old('cta_text', $promotion->cta_text) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('cta_text') border-red-300 @enderror"
                            placeholder="e.g. RM 99"
                        >
                        @error('cta_text')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="promo_code" class="block text-sm font-medium text-[#0F1B3D] mb-1">Promo Code</label>
                        <input
                            type="text"
                            name="promo_code"
                            id="promo_code"
                            value="{{ old('promo_code', $promotion->promo_code) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('promo_code') border-red-300 @enderror"
                            placeholder="e.g. BASIC99"
                        >
                        @error('promo_code')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label for="cta_link" class="block text-sm font-medium text-[#0F1B3D] mb-1">CTA Link URL</label>
                    <input
                        type="url"
                        name="cta_link"
                        id="cta_link"
                        value="{{ old('cta_link', $promotion->cta_link) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('cta_link') border-red-300 @enderror"
                        placeholder="https://heclinic.com/promo"
                    >
                    <p class="mt-1 text-xs text-gray-400">Optional. Where the user goes when they tap the CTA button.</p>
                    @error('cta_link')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                    <input
                        type="number"
                        name="sort_order"
                        id="sort_order"
                        value="{{ old('sort_order', $promotion->sort_order ?? 0) }}"
                        min="0"
                        class="w-32 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('sort_order') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Lower numbers appear first.</p>
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
                            {{ old('is_active', $promotion->is_active ?? true) ? 'checked' : '' }}
                            class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                        >
                        <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-400 ml-6">Inactive promotions are hidden from the mobile app.</p>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Promotion' : 'Create Promotion' }}
                </button>
                <a href="{{ route('admin.cms.promotions.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
