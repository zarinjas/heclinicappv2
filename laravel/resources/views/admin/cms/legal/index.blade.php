@extends('layouts.admin')

@section('title', 'Legal Pages')

@section('content')
    <div class="mb-6 flex items-center justify-between">
        <div>
            <h1 class="text-xl font-bold text-[#0F1B3D]">Legal Pages</h1>
            <p class="text-sm text-gray-400 mt-1">Manage Privacy Policy and Terms of Service content</p>
        </div>
        <a href="{{ route('admin.cms.legal.create') }}" class="px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093]">+ Add Page</a>
    </div>

    <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Slug</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Title</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Last Updated</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Status</th>
                    <th class="text-right px-4 py-3 font-medium text-gray-500">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($pages as $page)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 font-mono text-xs text-[#0F1B3D]">{{ $page->slug }}</td>
                        <td class="px-4 py-3 font-medium text-[#0F1B3D]">{{ $page->title }}</td>
                        <td class="px-4 py-3 text-gray-500">{{ $page->last_updated?->format('M Y') }}</td>
                        <td class="px-4 py-3">
                            <span class="px-2 py-1 text-xs rounded-full {{ $page->is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                                {{ $page->is_active ? 'Active' : 'Inactive' }}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-right">
                            <a href="{{ route('admin.cms.legal.edit', $page) }}" class="text-[#00C9A7] hover:underline mr-2">Edit</a>
                            <form action="{{ route('admin.cms.legal.destroy', $page) }}" method="POST" class="inline" onsubmit="return confirm('Delete?')">
                                @csrf @method('DELETE')
                                <button class="text-red-400 hover:text-red-600">Delete</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="5" class="px-4 py-8 text-center text-gray-400">No pages yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="mt-4">{{ $pages->links() }}</div>
@endsection
