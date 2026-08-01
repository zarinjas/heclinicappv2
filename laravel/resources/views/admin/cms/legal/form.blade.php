@php $isEdit = isset($page) && $page->exists; @endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Page' : 'Add Page')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.legal.update', $page) : route('admin.cms.legal.store') }}"
          class="max-w-2xl">
        @csrf
        @if ($isEdit) @method('PUT') @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="slug" class="block text-sm font-medium text-[#0F1B3D] mb-1">Slug <span class="text-red-500">*</span></label>
                    <input type="text" name="slug" id="slug" value="{{ old('slug', $page->slug) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('slug') border-red-300 @enderror"
                           placeholder="privacy or terms">
                    <p class="mt-1 text-xs text-gray-400">e.g. "privacy" or "terms" — used in the app URL</p>
                    @error('slug') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">Title <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $page->title) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                           placeholder="e.g. Privacy Policy">
                    @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="last_updated" class="block text-sm font-medium text-[#0F1B3D] mb-1">Last Updated</label>
                    <input type="date" name="last_updated" id="last_updated" value="{{ old('last_updated', $page->last_updated?->format('Y-m-d')) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                </div>

                <div>
                    <label for="sections_json" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sections (JSON)</label>
                    <textarea name="sections_json" id="sections_json" rows="10"
                              class="w-full px-4 py-2 text-sm font-mono border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('sections_json') border-red-300 @enderror"
                              placeholder='[{"heading": "Section Title", "body": "Content text here."}]'>{{ old('sections_json', $isEdit ? json_encode($page->sections, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) : '') }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">JSON array of {heading, body} objects. Each object becomes a section on the legal page.</p>
                    @error('sections_json') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <label class="inline-flex items-center gap-2 cursor-pointer">
                    <input type="hidden" name="is_active" value="0">
                    <input type="checkbox" name="is_active" id="is_active" value="1" {{ old('is_active', $page->is_active ?? true) ? 'checked' : '' }}
                           class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]">
                    <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                </label>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit" class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093]">
                    {{ $isEdit ? 'Update Page' : 'Create Page' }}
                </button>
                <a href="{{ route('admin.cms.legal.index') }}" class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50">Cancel</a>
            </div>
        </div>
    </form>
@endsection
