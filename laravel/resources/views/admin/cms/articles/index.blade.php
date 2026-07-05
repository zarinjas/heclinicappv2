@extends('layouts.admin')

@section('title', 'CMS — Articles')

@section('subtitle', 'Manage health articles, blog posts, and educational content')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex flex-wrap gap-2">
            <a href="{{ route('admin.cms.articles.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('status') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            <a href="{{ route('admin.cms.articles.index', ['status' => 'published']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'published' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Published
            </a>
            <a href="{{ route('admin.cms.articles.index', ['status' => 'draft']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'draft' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Drafts
            </a>
        </div>

        <div class="flex gap-2">
            <form method="GET" action="{{ route('admin.cms.articles.index') }}" class="relative">
                @if (request('status'))
                    <input type="hidden" name="status" value="{{ request('status') }}">
                @endif
                <input
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    placeholder="Search by title..."
                    class="w-48 sm:w-64 pl-9 pr-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
                <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
            </form>

            <a href="{{ route('admin.cms.articles.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add Article
            </a>
        </div>
    </div>

    @if ($articles->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">
                {{ request('search') ? 'No articles matching "' . request('search') . '".' : 'No articles found.' }}
            </p>
            <a href="{{ route('admin.cms.articles.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add First Article
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500 w-20">Preview</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Title</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Category</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Published</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Sort</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($articles as $article)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    @if ($article->featured_image_url)
                                        <img src="{{ $article->featured_image_url }}" alt="" class="w-16 h-10 object-cover rounded border border-gray-200">
                                    @else
                                        <div class="w-16 h-10 bg-gray-100 rounded border border-gray-200 flex items-center justify-center">
                                            <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"/>
                                            </svg>
                                        </div>
                                    @endif
                                </td>
                                <td class="px-6 py-4 font-medium text-[#0F1B3D] max-w-[250px] truncate">{{ $article->title }}</td>
                                <td class="px-6 py-4 text-gray-500">
                                    <span class="px-2 py-0.5 text-xs bg-blue-50 text-blue-600 rounded-full">{{ $article->category ?: 'Uncategorized' }}</span>
                                </td>
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">
                                    {{ $article->published_at ? $article->published_at->format('d M Y') : '—' }}
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $article->sort_order }}</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $article->status === 'published' ? 'bg-green-50 text-green-700' : 'bg-yellow-50 text-yellow-700' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $article->status === 'published' ? 'bg-green-500' : 'bg-yellow-500' }}"></span>
                                        {{ ucfirst($article->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.cms.articles.edit', $article) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        <form method="POST" action="{{ route('admin.cms.articles.destroy', $article) }}"
                                              onsubmit="return confirm('Delete this article? This cannot be undone.');"
                                              class="inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit"
                                                    class="p-1.5 text-gray-400 hover:text-red-500 transition-colors"
                                                    title="Delete">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($articles->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $articles->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $articles->firstItem() ?: 0 }}–{{ $articles->lastItem() ?: 0 }} of {{ $articles->total() }} articles
        </p>
    @endif
@endsection
