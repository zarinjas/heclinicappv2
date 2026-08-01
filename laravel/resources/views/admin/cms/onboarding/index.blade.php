@extends('layouts.admin')

@section('title', 'Onboarding Slides')

@section('content')
    <div class="mb-6 flex items-center justify-between">
        <div>
            <h1 class="text-xl font-bold text-[#0F1B3D]">Onboarding Slides</h1>
            <p class="text-sm text-gray-400 mt-1">Manage the intro slides users see when they first open the app</p>
        </div>
        <a href="{{ route('admin.cms.onboarding.create') }}" class="px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093]">+ Add Slide</a>
    </div>

    <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Preview</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Title</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Subtitle</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Gradient</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Status</th>
                    <th class="text-right px-4 py-3 font-medium text-gray-500">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($slides as $slide)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3">
                            @if ($slide->image_url)
                                <img src="{{ $slide->image_url }}" alt="" class="w-16 h-10 object-cover rounded border border-gray-200">
                            @else
                                <div class="w-16 h-10 bg-gray-100 rounded border border-gray-200 flex items-center justify-center">
                                    <span class="text-xs text-gray-400">No img</span>
                                </div>
                            @endif
                        </td>
                        <td class="px-4 py-3 font-medium text-[#0F1B3D]">{{ $slide->title }}</td>
                        <td class="px-4 py-3 text-gray-500">{{ Str::limit($slide->subtitle, 60) }}</td>
                        <td class="px-4 py-3">
                            <div class="flex items-center gap-1">
                                <span class="w-4 h-4 rounded" style="background:{{ $slide->gradient_start }}"></span>
                                <span class="text-xs text-gray-400">{{ $slide->gradient_start }}</span>
                            </div>
                        </td>
                        <td class="px-4 py-3">
                            <span class="px-2 py-1 text-xs rounded-full {{ $slide->is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                                {{ $slide->is_active ? 'Active' : 'Inactive' }}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-right">
                            <a href="{{ route('admin.cms.onboarding.edit', $slide) }}" class="text-[#00C9A7] hover:underline mr-2">Edit</a>
                            <form action="{{ route('admin.cms.onboarding.destroy', $slide) }}" method="POST" class="inline" onsubmit="return confirm('Delete this slide?')">
                                @csrf @method('DELETE')
                                <button class="text-red-400 hover:text-red-600">Delete</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="6" class="px-4 py-8 text-center text-gray-400">No slides yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="mt-4">{{ $slides->links() }}</div>
@endsection
