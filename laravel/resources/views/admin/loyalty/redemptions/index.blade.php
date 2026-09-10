@extends('layouts.admin')

@section('title', 'Loyalty — Redemptions')

@section('subtitle', 'Verify redemption codes and mark them as fulfilled when a patient uses their points at the counter')

@section('content')
    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 mb-6 text-sm text-blue-800">
        <p class="font-medium mb-1">How to process a redemption (quick guide)</p>
        <ol class="list-decimal list-inside space-y-1 text-blue-700">
            <li>Ask the patient for their <strong>redemption code</strong> (shown in their app).</li>
            <li>Type the code (or patient name / NRIC / phone) into the search box above.</li>
            <li>Check the status shows <strong>Pending</strong> and it is not expired.</li>
            <li>Apply the discount / hand over the product / deliver the service.</li>
            <li>Click <strong>Fulfill</strong>. (Click <strong>Cancel</strong> only if the patient changes their mind — points will be refunded.)</li>
        </ol>
    </div>

    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div class="flex gap-2 flex-wrap">
            <a href="{{ route('admin.loyalty.redemptions.index') }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ !request('status') ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                All
            </a>
            <a href="{{ route('admin.loyalty.redemptions.index', array_merge(request()->query(), ['status' => 'pending'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'pending' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Pending
            </a>
            <a href="{{ route('admin.loyalty.redemptions.index', array_merge(request()->query(), ['status' => 'fulfilled'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'fulfilled' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Fulfilled
            </a>
            <a href="{{ route('admin.loyalty.redemptions.index', array_merge(request()->query(), ['status' => 'cancelled'])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg {{ request('status') === 'cancelled' ? 'bg-[#0F1B3D] text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200' }}">
                Cancelled
            </a>
        </div>

        <form method="GET" action="{{ route('admin.loyalty.redemptions.index') }}" class="flex items-center gap-2">
            @if (request('status'))
                <input type="hidden" name="status" value="{{ request('status') }}">
            @endif
            <input type="text" name="q" value="{{ request('q') }}" placeholder="Search code, patient, NRIC or phone"
                   class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-64">
            <button type="submit"
                    class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('q') || request('status'))
                <a href="{{ route('admin.loyalty.redemptions.index') }}"
                   class="px-3 py-2 text-sm text-gray-500 hover:text-gray-700 transition-colors">Clear</a>
            @endif
            <a href="{{ route('admin.loyalty.redemptions.print-all', array_filter(['q' => request('q'), 'status' => request('status')])) }}"
               target="_blank"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-[#0F1B3D] bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors whitespace-nowrap">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                </svg>
                Print All
            </a>
        </form>
    </div>

    @if ($redemptions->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/>
            </svg>
            <p class="text-sm text-gray-500">No redemptions found.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Patient</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Reward</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Code</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Points</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Redeemed</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Expires</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($redemptions as $redemption)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <p class="font-medium text-[#0F1B3D]">{{ $redemption->patient?->name ?: '—' }}</p>
                                    <p class="text-xs text-gray-400">{{ $redemption->patient?->nric ?: '—' }}</p>
                                </td>
                                <td class="px-6 py-4">
                                    @if ($redemption->reward)
                                        <p class="text-[#0F1B3D]">{{ $redemption->reward->name }}</p>
                                        <p class="text-xs text-gray-400">{{ ucfirst($redemption->reward->type) }}</p>
                                    @else
                                        <p class="text-[#0F1B3D]">Points discount</p>
                                        @if ($redemption->discount_value !== null)
                                            <p class="text-xs text-gray-400">RM {{ number_format($redemption->discount_value, 2) }} off</p>
                                        @endif
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-mono font-medium bg-blue-50 text-blue-700">
                                        {{ $redemption->redemption_code }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ number_format(abs($redemption->points)) }} pts</td>
                                <td class="px-6 py-4">
                                    @php
                                        $badge = match ($redemption->status) {
                                            'fulfilled' => 'bg-gray-100 text-gray-600',
                                            'cancelled' => 'bg-red-50 text-red-600',
                                            default => 'bg-green-50 text-green-700',
                                        };
                                        $dot = match ($redemption->status) {
                                            'fulfilled' => 'bg-gray-400',
                                            'cancelled' => 'bg-red-500',
                                            default => 'bg-green-500',
                                        };
                                    @endphp
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $badge }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                                        {{ ucfirst($redemption->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $redemption->created_at?->format('d M Y, g:i A') ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $redemption->expires_at?->format('d M Y') ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.loyalty.redemptions.print', $redemption) }}"
                                           target="_blank"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Print / view record">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                                            </svg>
                                        </a>
                                        @if ($redemption->isPending())
                                            <form method="POST" action="{{ route('admin.loyalty.redemptions.fulfill', $redemption) }}"
                                                  onsubmit="return confirm('Mark {{ $redemption->redemption_code }} as fulfilled? This confirms the patient received the reward/discount.');"
                                                  class="inline">
                                                @csrf
                                                <button type="submit"
                                                        class="px-3 py-1.5 text-xs font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                                                    Fulfill
                                                </button>
                                            </form>
                                            <form method="POST" action="{{ route('admin.loyalty.redemptions.cancel', $redemption) }}"
                                                  onsubmit="return confirm('Cancel {{ $redemption->redemption_code }} and refund the points?');"
                                                  class="inline">
                                                @csrf
                                                <button type="submit"
                                                        class="px-3 py-1.5 text-xs font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                                                    Cancel
                                                </button>
                                            </form>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($redemptions->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $redemptions->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $redemptions->firstItem() ?: 0 }}–{{ $redemptions->lastItem() ?: 0 }} of {{ $redemptions->total() }} redemptions
        </p>
    @endif
@endsection
