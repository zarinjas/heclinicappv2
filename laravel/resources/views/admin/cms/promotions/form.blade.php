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
                    <p class="mt-1 text-xs text-gray-400">Optional hero image. Recommended size <strong>1200×600px (2:1 ratio)</strong> for a clean look in the app. Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $promotion->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image (previewed at 2:1 as shown in the app):</p>
                            <img src="{{ $promotion->image_url }}" alt="" class="w-64 h-32 object-cover rounded-lg border border-gray-200">
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
                    <label for="promo_code" class="block text-sm font-medium text-[#0F1B3D] mb-1">Voucher / Promo Code</label>
                    <input
                        type="text"
                        name="promo_code"
                        id="promo_code"
                        value="{{ old('promo_code', $promotion->promo_code) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('promo_code') border-red-300 @enderror"
                        placeholder="e.g. BASIC99"
                    >
                    <p class="mt-1 text-xs text-gray-400">Code shown to users to redeem at the clinic. Leave empty if this is a display-only offer.</p>
                    @error('promo_code')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>
            </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="valid_from" class="block text-sm font-medium text-[#0F1B3D] mb-1">Valid From</label>
                        <input
                            type="date"
                            name="valid_from"
                            id="valid_from"
                            value="{{ old('valid_from', $promotion->valid_from?->toDateString()) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('valid_from') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Optional. Offer only shows from this date.</p>
                        @error('valid_from')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="valid_until" class="block text-sm font-medium text-[#0F1B3D] mb-1">Valid Until</label>
                        <input
                            type="date"
                            name="valid_until"
                            id="valid_until"
                            value="{{ old('valid_until', $promotion->valid_until?->toDateString()) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('valid_until') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Optional. Offer hidden after this date.</p>
                        @error('valid_until')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="usage_limit" class="block text-sm font-medium text-[#0F1B3D] mb-1">Usage Limit</label>
                        <input
                            type="number"
                            name="usage_limit"
                            id="usage_limit"
                            value="{{ old('usage_limit', $promotion->usage_limit) }}"
                            min="1"
                            class="w-40 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('usage_limit') border-red-300 @enderror"
                            placeholder="Unlimited"
                        >
                        <p class="mt-1 text-xs text-gray-400">Optional. How many times this voucher can be used. Empty = unlimited.</p>
                        @error('usage_limit')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="inline-flex items-center gap-2 cursor-pointer pt-6">
                            <input
                                type="hidden"
                                name="code_unique"
                                value="0"
                            >
                            <input
                                type="checkbox"
                                name="code_unique"
                                id="code_unique"
                                value="1"
                                {{ old('code_unique', $promotion->code_unique ?? false) ? 'checked' : '' }}
                                class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                            >
                            <span class="text-sm font-medium text-[#0F1B3D]">Unique code per redemption</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400 ml-6">When enabled, each redemption must use a unique code (validated against Plato).</p>
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
