@php
    $isEdit = isset($article_category) && $article_category->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Category' : 'Add Category')

@section('subtitle', $isEdit ? 'Update category name, slug, or status' : 'Create a new article category')

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.article-categories.update', $article_category) : route('admin.cms.article-categories.store') }}"
          class="max-w-2xl">
        @csrf
        @if ($isEdit)
            @method('PUT')
        @endif

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="name" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Name <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="name"
                        id="name"
                        value="{{ old('name', $article_category->name) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('name') border-red-300 @enderror"
                        placeholder="e.g. Health Tips, Nutrition, News"
                    >
                    @error('name')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="slug" class="block text-sm font-medium text-[#0F1B3D] mb-1">Slug</label>
                    <input
                        type="text"
                        name="slug"
                        id="slug"
                        value="{{ old('slug', $article_category->slug) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('slug') border-red-300 @enderror"
                        placeholder="auto-generated-from-name"
                    >
                    <p class="mt-1 text-xs text-gray-400">Auto-generated from the name. You can customize it manually.</p>
                    @error('slug')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="status" class="block text-sm font-medium text-[#0F1B3D] mb-1">Status</label>
                        <select
                            name="status"
                            id="status"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('status') border-red-300 @enderror"
                        >
                            <option value="active" {{ old('status', $article_category->status) === 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ old('status', $article_category->status) === 'inactive' ? 'selected' : '' }}>Inactive</option>
                        </select>
                        @error('status')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Category' : 'Create Category' }}
                </button>
                <a href="{{ route('admin.cms.article-categories.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
