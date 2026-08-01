@php $isEdit = isset($slide) && $slide->exists; @endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Slide' : 'Add Slide')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.onboarding.update', $slide) : route('admin.cms.onboarding.store') }}"
          class="max-w-2xl">
        @csrf
        @if ($isEdit) @method('PUT') @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">Title <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $slide->title) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                           placeholder="e.g. Your Health, Simplified">
                    @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="subtitle" class="block text-sm font-medium text-[#0F1B3D] mb-1">Subtitle</label>
                    <textarea name="subtitle" id="subtitle" rows="3"
                              class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('subtitle') border-red-300 @enderror"
                              placeholder="e.g. Book appointments and track your health in one place">{{ old('subtitle', $slide->subtitle) }}</textarea>
                    @error('subtitle') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="gradient_start" class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient Start</label>
                        <input type="text" name="gradient_start" id="gradient_start" value="{{ old('gradient_start', $slide->gradient_start) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                               placeholder="#3B8DFF">
                    </div>
                    <div>
                        <label for="gradient_end" class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient End</label>
                        <input type="text" name="gradient_end" id="gradient_end" value="{{ old('gradient_end', $slide->gradient_end) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                               placeholder="#27F5A3">
                    </div>
                </div>

                <div>
                    <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                    <input type="number" name="sort_order" id="sort_order" value="{{ old('sort_order', $slide->sort_order ?? 0) }}" min="0"
                           class="w-32 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                </div>

                <label class="inline-flex items-center gap-2 cursor-pointer">
                    <input type="hidden" name="is_active" value="0">
                    <input type="checkbox" name="is_active" id="is_active" value="1" {{ old('is_active', $slide->is_active ?? true) ? 'checked' : '' }}
                           class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]">
                    <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                </label>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit" class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093]">
                    {{ $isEdit ? 'Update Slide' : 'Create Slide' }}
                </button>
                <a href="{{ route('admin.cms.onboarding.index') }}" class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50">Cancel</a>
            </div>
        </div>
    </form>
@endsection
