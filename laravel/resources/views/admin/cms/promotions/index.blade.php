@extends('layouts.admin')

@section('title', 'CMS — Promotions')

@section('subtitle', 'Manage promotions, offers, and vouchers displayed in the mobile app')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex gap-2">
            <a href="{{ route('admin.cms.promotions.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('status') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            <a href="{{ route('admin.cms.promotions.index', ['status' => '1']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === '1' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Active
            </a>
            <a href="{{ route('admin.cms.promotions.index', ['status' => '0']) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === '0' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Inactive
            </a>
        </div>

        <a href="{{ route('admin.cms.promotions.create') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Add Promotion
        </a>
    </div>

    @if ($promotions->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No promotions found.</p>
            <a href="{{ route('admin.cms.promotions.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add First Promotion
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Title</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">CTA</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Promo Code</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Valid</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($promotions as $promotion)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        @if ($promotion->image_url)
                                            <img src="{{ $promotion->image_url }}" alt="" class="w-10 h-10 object-cover rounded border border-gray-200">
                                        @endif
                                        <div>
                                            <p class="font-medium text-[#0F1B3D]">{{ $promotion->title }}</p>
                                            <p class="text-xs text-gray-400">{{ Str::limit($promotion->description, 60) }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $promotion->cta_text ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    @if ($promotion->promo_code)
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-mono font-medium bg-blue-50 text-blue-700">
                                            {{ $promotion->promo_code }}
                                        </span>
                                    @else
                                        <span class="text-gray-400">—</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-gray-500">
                                    @if ($promotion->valid_from || $promotion->valid_until)
                                        <span class="text-xs">
                                            {{ $promotion->valid_from?->format('d M') ?: '—' }} – {{ $promotion->valid_until?->format('d M') ?: '∞' }}
                                        </span>
                                        @if ($promotion->usage_limit)
                                            <br><span class="text-xs text-gray-400">Max {{ $promotion->usage_limit }} uses</span>
                                        @endif
                                    @else
                                        <span class="text-gray-400">—</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $promotion->is_active ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $promotion->is_active ? 'bg-green-500' : 'bg-gray-400' }}"></span>
                                        {{ $promotion->is_active ? 'Active' : 'Inactive' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.cms.promotions.edit', $promotion) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        <form method="POST" action="{{ route('admin.cms.promotions.destroy', $promotion) }}"
                                              onsubmit="return confirm('Delete this promotion? This cannot be undone.');"
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

            @if ($promotions->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $promotions->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $promotions->firstItem() ?: 0 }}–{{ $promotions->lastItem() ?: 0 }} of {{ $promotions->total() }} promotions
        </p>
    @endif
@endsection
