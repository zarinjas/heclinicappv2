@extends('layouts.admin')

@section('title', 'Loyalty — He Rewards')

@section('subtitle', 'Manage the rewards patients can redeem with their points (products and services)')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex gap-2 flex-wrap">
            <a href="{{ route('admin.loyalty.rewards.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('type') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            @foreach (['product' => 'Products', 'service' => 'Services', 'discount' => 'Discounts'] as $type => $label)
                <a href="{{ route('admin.loyalty.rewards.index', ['type' => $type]) }}"
                   class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('type') === $type ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                    {{ $label }}
                </a>
            @endforeach
        </div>

        <a href="{{ route('admin.loyalty.rewards.create') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Add Reward
        </a>
    </div>

    @if ($rewards->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No rewards yet.</p>
            <a href="{{ route('admin.loyalty.rewards.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add First Reward
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Reward</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Type</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Points</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Stock</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">CTA</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($rewards as $reward)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        @if ($reward->image_url)
                                            <img src="{{ $reward->image_url }}" alt="" class="w-10 h-10 object-cover rounded border border-gray-200">
                                        @endif
                                        <div>
                                            <p class="font-medium text-[#0F1B3D]">{{ $reward->name }}</p>
                                            <p class="text-xs text-gray-400">{{ Str::limit($reward->description, 50) }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-xs text-gray-600 capitalize">{{ $reward->type }}</span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-mono font-medium bg-purple-50 text-purple-700">
                                        {{ number_format($reward->points_cost) }} pts
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500">
                                    @if ($reward->type === 'product')
                                        {{ $reward->stock !== null ? $reward->stock : 'Unlimited' }}
                                    @else
                                        <span class="text-gray-400">—</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $reward->cta_text ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $reward->is_active ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $reward->is_active ? 'bg-green-500' : 'bg-gray-400' }}"></span>
                                        {{ $reward->is_active ? 'Active' : 'Inactive' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.loyalty.rewards.edit', $reward) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        <form method="POST" action="{{ route('admin.loyalty.rewards.destroy', $reward) }}"
                                              onsubmit="return confirm('Delete this reward? This cannot be undone.');"
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

            @if ($rewards->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $rewards->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $rewards->firstItem() ?: 0 }}–{{ $rewards->lastItem() ?: 0 }} of {{ $rewards->total() }} rewards
        </p>
    @endif
@endsection
