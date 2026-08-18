@php
    $isEdit = isset($item) && $item->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Clinic Info' : 'Add Clinic Info')

@section('subtitle', $isEdit ? 'Update clinic info image or status' : 'Upload a new clinic info image')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.clinic-info.update', $item) : route('admin.cms.clinic-info.store') }}"
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
                        Image {{ $isEdit ? '' : '<span class="text-red-500">*</span>' }}
                    </label>
                    <input
                        type="file"
                        name="image"
                        id="image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Square or portrait images work best, e.g. 1080×1080px (social media post). Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $item->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $item->image_url }}" alt="" class="w-48 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
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
                            {{ old('is_active', $item->is_active ?? true) ? 'checked' : '' }}
                            class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                        >
                        <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-400 ml-6">Inactive images are hidden from the mobile app. Deactivate instead of deleting to keep for later.</p>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Image' : 'Create Image' }}
                </button>
                <a href="{{ route('admin.cms.clinic-info.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
