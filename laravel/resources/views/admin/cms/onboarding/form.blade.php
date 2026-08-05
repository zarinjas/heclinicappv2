@php $isEdit = isset($onboarding) && $onboarding->exists; @endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Slide' : 'Add Slide')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.onboarding.update', $onboarding) : route('admin.cms.onboarding.store') }}"
          enctype="multipart/form-data"
          class="max-w-2xl">
        @csrf
        @if ($isEdit) @method('PUT') @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="image" class="block text-sm font-medium text-[#0F1B3D] mb-1">Slide Image</label>
                    <input type="file" name="image" id="image" accept="image/jpeg,image/png,image/webp"
                           class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror">
                    <p class="mt-1 text-xs text-gray-400">Optional. Max 5MB. JPEG, PNG, or WebP.</p>
                    <p class="mt-1 text-xs text-amber-600 font-medium">Recommended image size: 1080 × 1920 px (9:16 portrait). Safe area: keep important content within the center 1080 × 1500 px to avoid cropping on different devices.</p>
                    @error('image') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror

                    @if ($isEdit && $onboarding->image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $onboarding->image_url }}" alt="" class="w-64 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
                </div>

                <div>
                    <label for="video" class="block text-sm font-medium text-[#0F1B3D] mb-1">Slide Video (optional)</label>
                    <input type="file" name="video" id="video" accept="video/mp4,video/webm,video/quicktime"
                           class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('video') border-red-300 @enderror">
                    <p class="mt-1 text-xs text-gray-400">Optional. Max 50MB. MP4, MOV, or WebM. If a video is uploaded it plays automatically (muted, looping) as the slide background instead of the image.</p>
                    <p class="mt-1 text-xs text-amber-600 font-medium">Recommended: 1080 × 1920 px (9:16 portrait), MP4 H.264. Keep important content within the center 1080 × 1500 px to avoid cropping on different devices.</p>
                    @error('video') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror

                    @if ($isEdit && $onboarding->video_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current video:</p>
                            <video src="{{ $onboarding->video_url }}" controls playsinline class="w-64 rounded-lg border border-gray-200"></video>
                        </div>
                    @endif
                </div>

                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">Title <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $onboarding->title) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                           placeholder="e.g. Your Health, Simplified">
                    @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="subtitle" class="block text-sm font-medium text-[#0F1B3D] mb-1">Subtitle</label>
                    <textarea name="subtitle" id="subtitle" rows="3"
                              class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('subtitle') border-red-300 @enderror"
                              placeholder="e.g. Book appointments and track your health in one place">{{ old('subtitle', $onboarding->subtitle) }}</textarea>
                    @error('subtitle') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="gradient_start" class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient Start</label>
                        <input type="text" name="gradient_start" id="gradient_start" value="{{ old('gradient_start', $onboarding->gradient_start) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                               placeholder="#3B8DFF">
                    </div>
                    <div>
                        <label for="gradient_end" class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient End</label>
                        <input type="text" name="gradient_end" id="gradient_end" value="{{ old('gradient_end', $onboarding->gradient_end) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                               placeholder="#27F5A3">
                    </div>
                </div>

                <label class="inline-flex items-center gap-2 cursor-pointer">
                    <input type="hidden" name="is_active" value="0">
                    <input type="checkbox" name="is_active" id="is_active" value="1" {{ old('is_active', $onboarding->is_active ?? true) ? 'checked' : '' }}
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
