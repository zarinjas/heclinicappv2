@php
    $isEdit = isset($article) && $article->exists;
@endphp

@extends('layouts.admin')

@section('title', $isEdit ? 'Edit Article' : 'Add Article')

@section('subtitle', $isEdit ? 'Update article content, image, category, or status' : 'Write a new health article or blog post')

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/@tiptap/core@2.9.1/dist/index.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tiptap/starter-kit@2.9.1/dist/index.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tiptap/extension-link@2.9.1/dist/index.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tiptap/extension-image@2.9.1/dist/index.umd.min.js"></script>
<style>
    .tiptap-editor { min-height: 300px; }
    .tiptap-editor p.is-editor-empty:first-child::before {
        color: #adb5bd; content: attr(data-placeholder); float: left; height: 0; pointer-events: none;
    }
    .tiptap-editor h1 { font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem; }
    .tiptap-editor h2 { font-size: 1.5rem; font-weight: 600; margin-bottom: 0.5rem; }
    .tiptap-editor h3 { font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem; }
    .tiptap-editor p { margin-bottom: 0.5rem; }
    .tiptap-editor ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.5rem; }
    .tiptap-editor ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.5rem; }
    .tiptap-editor blockquote { border-left: 3px solid #e5e7eb; padding-left: 1rem; color: #6b7280; margin-bottom: 0.5rem; }
    .tiptap-editor a { color: #00C9A7; text-decoration: underline; }
    .tiptap-editor img { max-width: 100%; height: auto; border-radius: 0.5rem; margin: 0.5rem 0; }
    .tiptap-editor strong { font-weight: 600; }
    .tiptap-editor em { font-style: italic; }
    .tiptap-editor code { background: #f3f4f6; padding: 0.125rem 0.25rem; border-radius: 0.25rem; font-size: 0.875em; }
    .tiptap-editor pre { background: #1f2937; color: #f9fafb; padding: 1rem; border-radius: 0.5rem; margin-bottom: 0.5rem; overflow-x: auto; }
    .tiptap-editor pre code { background: none; padding: 0; color: inherit; }
</style>
@endpush

@section('content')
    <form method="POST"
          action="{{ $isEdit ? route('admin.cms.articles.update', $article) : route('admin.cms.articles.store') }}"
          enctype="multipart/form-data"
          class="max-w-4xl">
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
                        value="{{ old('title', $article->title) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="e.g. Understanding Common Cold Symptoms"
                    >
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="slug" class="block text-sm font-medium text-[#0F1B3D] mb-1">Slug</label>
                    <div class="flex items-center gap-2">
                        <input
                            type="text"
                            name="slug"
                            id="slug"
                            value="{{ old('slug', $article->slug) }}"
                            class="flex-1 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('slug') border-red-300 @enderror"
                            placeholder="auto-generated-from-title"
                        >
                        <button type="button" id="generateSlugBtn"
                                class="px-3 py-2 text-sm text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors whitespace-nowrap">
                            Generate
                        </button>
                    </div>
                    <p class="mt-1 text-xs text-gray-400">Auto-generated from title. You can customize it manually.</p>
                    @error('slug')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="body" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Content <span class="text-red-500">*</span>
                    </label>
                    <div class="border border-gray-200 rounded-lg @error('body') border-red-300 @enderror">
                        <div id="editor-toolbar" class="flex flex-wrap items-center gap-1 px-3 py-2 border-b border-gray-200 bg-gray-50 rounded-t-lg">
                            <button type="button" data-action="bold" class="p-1.5 rounded hover:bg-gray-200" title="Bold">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 4h8a4 4 0 014 4 4 4 0 01-4 4H6z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 12h9a4 4 0 014 4 4 4 0 01-4 4H6z"/></svg>
                            </button>
                            <button type="button" data-action="italic" class="p-1.5 rounded hover:bg-gray-200" title="Italic">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 4h4m-2 0v16m-4 0h8"/></svg>
                            </button>
                            <span class="w-px h-5 bg-gray-300 mx-1"></span>
                            <button type="button" data-action="heading-1" class="p-1.5 rounded hover:bg-gray-200" title="Heading 1">H1</button>
                            <button type="button" data-action="heading-2" class="p-1.5 rounded hover:bg-gray-200" title="Heading 2">H2</button>
                            <button type="button" data-action="heading-3" class="p-1.5 rounded hover:bg-gray-200" title="Heading 3">H3</button>
                            <span class="w-px h-5 bg-gray-300 mx-1"></span>
                            <button type="button" data-action="bullet-list" class="p-1.5 rounded hover:bg-gray-200" title="Bullet List">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"/></svg>
                            </button>
                            <button type="button" data-action="ordered-list" class="p-1.5 rounded hover:bg-gray-200" title="Numbered List">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 6h14M7 10h6m-6 4h14M7 18h6"/></svg>
                            </button>
                            <button type="button" data-action="blockquote" class="p-1.5 rounded hover:bg-gray-200" title="Quote">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 11V8a4 4 0 00-4-4H3m7 7v4a4 4 0 01-4 4H3m14-14v4a4 4 0 01-4 4h-1m6-4v4a4 4 0 01-4 4h-1"/></svg>
                            </button>
                            <button type="button" data-action="code-block" class="p-1.5 rounded hover:bg-gray-200" title="Code Block">&lt;/&gt;</button>
                        </div>
                        <div id="editor" class="tiptap-editor px-4 py-3 focus:outline-none prose prose-sm max-w-none">{!! old('body', $article->body ?? '') !!}</div>
                    </div>
                    <input type="hidden" name="body" id="body-input" value="{{ old('body', $article->body ?? '') }}">
                    @error('body')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="category" class="block text-sm font-medium text-[#0F1B3D] mb-1">Category</label>
                        <input
                            type="text"
                            name="category"
                            id="category"
                            value="{{ old('category', $article->category) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('category') border-red-300 @enderror"
                            placeholder="e.g. Health Tips, News, COVID-19"
                        >
                        @error('category')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="author_name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Author Name</label>
                        <input
                            type="text"
                            name="author_name"
                            id="author_name"
                            value="{{ old('author_name', $article->author_name) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('author_name') border-red-300 @enderror"
                            placeholder="e.g. Dr. Ahmad"
                        >
                        @error('author_name')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label for="excerpt" class="block text-sm font-medium text-[#0F1B3D] mb-1">Excerpt</label>
                    <textarea
                        name="excerpt"
                        id="excerpt"
                        rows="2"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('excerpt') border-red-300 @enderror"
                        placeholder="Brief summary of the article (auto-generated if left empty)"
                    >{{ old('excerpt', $article->excerpt) }}</textarea>
                    @error('excerpt')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="featured_image" class="block text-sm font-medium text-[#0F1B3D] mb-1">Featured Image</label>
                    <input
                        type="file"
                        name="featured_image"
                        id="featured_image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('featured_image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Recommended size: 1200×600px. Max 5MB. JPEG, PNG, or WebP.</p>
                    @error('featured_image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror

                    @if ($isEdit && $article->featured_image_url)
                        <div class="mt-3">
                            <p class="text-xs text-gray-400 mb-1">Current image:</p>
                            <img src="{{ $article->featured_image_url }}" alt="" class="w-64 h-auto rounded-lg border border-gray-200">
                        </div>
                    @endif
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div>
                        <label for="sort_order" class="block text-sm font-medium text-[#0F1B3D] mb-1">Sort Order</label>
                        <input
                            type="number"
                            name="sort_order"
                            id="sort_order"
                            value="{{ old('sort_order', $article->sort_order ?? 0) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('sort_order') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Lower numbers appear first.</p>
                        @error('sort_order')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="published_at" class="block text-sm font-medium text-[#0F1B3D] mb-1">Published Date</label>
                        <input
                            type="datetime-local"
                            name="published_at"
                            id="published_at"
                            value="{{ old('published_at', $article->published_at ? $article->published_at->format('Y-m-d\TH:i') : '') }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('published_at') border-red-300 @enderror"
                        >
                        @error('published_at')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="status" class="block text-sm font-medium text-[#0F1B3D] mb-1">Status</label>
                        <select
                            name="status"
                            id="status"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('status') border-red-300 @enderror"
                        >
                            <option value="draft" {{ old('status', $article->status) === 'draft' ? 'selected' : '' }}>Draft</option>
                            <option value="published" {{ old('status', $article->status) === 'published' ? 'selected' : '' }}>Published</option>
                        </select>
                        <p class="mt-1 text-xs text-gray-400">Drafts are only visible in the admin panel.</p>
                        @error('status')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    {{ $isEdit ? 'Update Article' : 'Create Article' }}
                </button>
                <a href="{{ route('admin.cms.articles.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const { Editor } = window['@tiptap/core'];
            const { StarterKit } = window['@tiptap/starter-kit'];
            const { Link } = window['@tiptap/extension-link'];

            const editor = new Editor({
                element: document.getElementById('editor'),
                extensions: [
                    StarterKit.configure({
                        heading: { levels: [1, 2, 3] },
                    }),
                    Link.configure({ openOnClick: false }),
                ],
                content: document.getElementById('body-input').value,
                editorProps: {
                    attributes: {
                        class: 'focus:outline-none min-h-[300px]',
                    },
                },
                onUpdate: function ({ editor }) {
                    document.getElementById('body-input').value = editor.getHTML();
                },
            });

            document.querySelectorAll('#editor-toolbar [data-action]').forEach(function (btn) {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    var action = this.dataset.action;
                    var chain = editor.chain().focus();
                    switch (action) {
                        case 'bold': chain.toggleBold().run(); break;
                        case 'italic': chain.toggleItalic().run(); break;
                        case 'heading-1': chain.toggleHeading({ level: 1 }).run(); break;
                        case 'heading-2': chain.toggleHeading({ level: 2 }).run(); break;
                        case 'heading-3': chain.toggleHeading({ level: 3 }).run(); break;
                        case 'bullet-list': chain.toggleBulletList().run(); break;
                        case 'ordered-list': chain.toggleOrderedList().run(); break;
                        case 'blockquote': chain.toggleBlockquote().run(); break;
                        case 'code-block': chain.toggleCodeBlock().run(); break;
                    }
                    btn.classList.toggle('bg-gray-200', editor.isActive(action) || editor.isActive(action.replace('-', '')));
                });
            });

            var titleInput = document.getElementById('title');
            var slugInput = document.getElementById('slug');
            var generateBtn = document.getElementById('generateSlugBtn');

            function slugify(text) {
                return text.toString().toLowerCase().trim()
                    .replace(/\s+/g, '-').replace(/[^\w\-]+/g, '')
                    .replace(/\-\-+/g, '-').replace(/^-+/, '').replace(/-+$/, '');
            }

            generateBtn.addEventListener('click', function () {
                slugInput.value = slugify(titleInput.value);
            });

            titleInput.addEventListener('input', function () {
                if (!slugInput.dataset.manualEdit || slugInput.value === slugify(titleInput.value)) {
                    slugInput.value = slugify(this.value);
                }
            });

            slugInput.addEventListener('input', function () {
                slugInput.dataset.manualEdit = '1';
            });
        });
    </script>
@endsection
