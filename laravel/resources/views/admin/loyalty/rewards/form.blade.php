@php
    $isEdit = isset($reward) && $reward->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Reward' : 'Add Reward')

@section('subtitle', $isEdit ? 'Update reward details, image, and points cost' : 'Create a product or service reward patients can redeem with points')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.loyalty.rewards.update', $reward) : route('admin.loyalty.rewards.store') }}"
          enctype="multipart/form-data"
          class="max-w-2xl">
        @csrf
        @if ($isEdit)
            @method('PUT')
        @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="name" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Title <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="name"
                        id="name"
                        value="{{ old('name', $reward->name) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('name') border-red-300 @enderror"
                        placeholder="e.g. ESWT Package"
                    >
                    @error('name')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="description" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Description
                    </label>
                    <textarea
                        name="description"
                        id="description"
                        rows="4"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('description') border-red-300 @enderror"
                        placeholder="Describe what the patient gets with this reward..."
                    >{{ old('description', $reward->description) }}</textarea>
                    @error('description')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="type" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Type <span class="text-red-500">*</span>
                        </label>
                        <select
                            name="type"
                            id="type"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white @error('type') border-red-300 @enderror"
                        >
                            @foreach (['product' => 'Product (physical item)', 'service' => 'Service / Package', 'discount' => 'Discount (RM off)'] as $value => $label)
                                <option value="{{ $value }}" {{ old('type', $reward->type) === $value ? 'selected' : '' }}>{{ $label }}</option>
                            @endforeach
                        </select>
                        @error('type')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="points_cost" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Points Cost <span class="text-red-500">*</span>
                        </label>
                        <input
                            type="number"
                            name="points_cost"
                            id="points_cost"
                            value="{{ old('points_cost', $reward->points_cost) }}"
                            min="1"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('points_cost') border-red-300 @enderror"
                            placeholder="e.g. 1000"
                        >
                        <p class="mt-1 text-xs text-gray-400">How many points this reward costs.</p>
                        @error('points_cost')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="service_package_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Linked Service Package
                        </label>
                        <select
                            name="service_package_id"
                            id="service_package_id"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white @error('service_package_id') border-red-300 @enderror"
                        >
                            <option value="">— None —</option>
                            @foreach ($packages as $package)
                                <option value="{{ $package->id }}" {{ (string) old('service_package_id', $reward->service_package_id) === (string) $package->id ? 'selected' : '' }}>{{ $package->name }}</option>
                            @endforeach
                        </select>
                        <p class="mt-1 text-xs text-gray-400">Optional. Link a service package (from CMS → Service Packages).</p>
                        @error('service_package_id')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="stock" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Stock
                        </label>
                        <input
                            type="number"
                            name="stock"
                            id="stock"
                            value="{{ old('stock', $reward->stock) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('stock') border-red-300 @enderror"
                            placeholder="Unlimited"
                        >
                        <p class="mt-1 text-xs text-gray-400">For products only. Empty = unlimited stock.</p>
                        @error('stock')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label for="cta_text" class="block text-sm font-medium text-[#0F1B3D] mb-1">CTA Button Text</label>
                    <input
                        type="text"
                        name="cta_text"
                        id="cta_text"
                        value="{{ old('cta_text', $reward->cta_text) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('cta_text') border-red-300 @enderror"
                        placeholder="e.g. Redeem Now"
                    >
                    <p class="mt-1 text-xs text-gray-400">Button label shown in the app. Defaults to "Redeem".</p>
                    @error('cta_text')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="image" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Reward Image
                    </label>
                    <input
                        type="file"
                        name="image"
                        id="image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Optional image. Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $reward->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $reward->image_url }}" alt="" class="w-48 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                        <input
                            type="number"
                            name="sort_order"
                            id="sort_order"
                            value="{{ old('sort_order', $reward->sort_order) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('sort_order') border-red-300 @enderror"
                            placeholder="0"
                        >
                        <p class="mt-1 text-xs text-gray-400">Lower numbers appear first in the app.</p>
                        @error('sort_order')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="inline-flex items-center gap-2 cursor-pointer pt-6">
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
                                {{ old('is_active', $reward->is_active ?? true) ? 'checked' : '' }}
                                class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                            >
                            <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400 ml-6">Inactive rewards are hidden from the mobile app.</p>
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Reward' : 'Create Reward' }}
                </button>
                <a href="{{ route('admin.loyalty.rewards.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
