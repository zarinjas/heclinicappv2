@extends('layouts.admin')

@section('title', 'Voucher Claims')

@section('subtitle', 'See which patients have claimed vouchers and mark them as used after applying the discount manually')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex gap-2 flex-wrap">
            <a href="{{ route('admin.voucher-claims.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('status') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            <a href="{{ route('admin.voucher-claims.index', array_merge(request()->query(), ['status' => 'active'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'active' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Active
            </a>
            <a href="{{ route('admin.voucher-claims.index', array_merge(request()->query(), ['status' => 'used'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'used' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Used
            </a>
            <a href="{{ route('admin.voucher-claims.index', array_merge(request()->query(), ['status' => 'expired'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'expired' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Expired
            </a>
        </div>

        <form method="GET" action="{{ route('admin.voucher-claims.index') }}" class="flex items-center gap-2">
            @if (request('status'))
                <input type="hidden" name="status" value="{{ request('status') }}">
            @endif
            <input type="text" name="q" value="{{ request('q') }}" placeholder="Search patient, NRIC, phone or code"
                   class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-64">
            <button type="submit"
                    class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('q') || request('status'))
                <a href="{{ route('admin.voucher-claims.index') }}"
                   class="px-3 py-2 text-sm text-gray-500 hover:text-gray-700 transition-colors">Clear</a>
            @endif
        </form>
    </div>

    @if ($vouchers->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/>
            </svg>
            <p class="text-sm text-gray-500">No voucher claims found.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Patient</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Promotion</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Code</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Claimed</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Expires</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($vouchers as $voucher)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <p class="font-medium text-[#0F1B3D]">{{ $voucher->patient?->name ?: '—' }}</p>
                                    <p class="text-xs text-gray-400">{{ $voucher->patient?->nric ?: '—' }}</p>
                                </td>
                                <td class="px-6 py-4">
                                    <p class="text-[#0F1B3D]">{{ $voucher->promotion?->title ?: '—' }}</p>
                                    <p class="text-xs text-gray-400">{{ $voucher->promotion?->cta_text ?: '' }}</p>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-mono font-medium bg-blue-50 text-blue-700">
                                        {{ $voucher->code }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    @php
                                        $badge = match ($voucher->status) {
                                            'used' => 'bg-gray-100 text-gray-600',
                                            'expired' => 'bg-red-50 text-red-600',
                                            default => 'bg-green-50 text-green-700',
                                        };
                                        $dot = match ($voucher->status) {
                                            'used' => 'bg-gray-400',
                                            'expired' => 'bg-red-500',
                                            default => 'bg-green-500',
                                        };
                                    @endphp
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $badge }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                                        {{ ucfirst($voucher->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $voucher->created_at?->format('d M Y, g:i A') ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $voucher->expires_at?->format('d M Y') ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end">
                                        @if ($voucher->isActive())
                                            <form method="POST" action="{{ route('admin.voucher-claims.used', $voucher) }}"
                                                  onsubmit="return confirm('Mark this voucher as used? Apply the discount manually in Plato first.');"
                                                  class="inline">
                                                @csrf
                                                <button type="submit"
                                                        class="px-3 py-1.5 text-xs font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                                                    Mark Used
                                                </button>
                                            </form>
                                        @else
                                            <span class="text-xs text-gray-400">—</span>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($vouchers->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $vouchers->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $vouchers->firstItem() ?: 0 }}–{{ $vouchers->lastItem() ?: 0 }} of {{ $vouchers->total() }} voucher claims
        </p>
    @endif
@endsection
