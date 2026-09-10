@extends('layouts.admin')

@section('title', 'Redeem at Counter')

@section('subtitle', 'Search any code (voucher or points) and mark it as fulfilled when the patient uses it at the counter')

@section('content')
    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 mb-6 text-sm text-blue-800">
        <p class="font-medium mb-1">How to process a redemption</p>
        <ol class="list-decimal list-inside space-y-1 text-blue-700">
            <li>Ask the patient for their <strong>code</strong> (shown in their app).</li>
            <li>Type it into the search box below.</li>
            <li>Check the status — it should be <strong>Active</strong> (voucher) or <strong>Pending</strong> (points).</li>
            <li>Apply the discount / hand over the reward in Plato manually.</li>
            <li>Click <strong>Fulfill</strong>. Use <strong>Cancel</strong> only if you made a mistake.</li>
        </ol>
    </div>

    <form method="GET" action="{{ route('admin.redeem-at-counter') }}" class="flex items-center gap-2 mb-6">
        <input type="text" name="q" value="{{ $query }}" placeholder="Enter code, patient name, NRIC or phone"
               autofocus
               class="flex-1 px-5 py-3 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
        <button type="submit"
                class="px-6 py-3 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
            Search
        </button>
        @if ($query !== '')
            <a href="{{ route('admin.redeem-at-counter') }}"
               class="px-4 py-3 text-sm text-gray-500 hover:text-gray-700 transition-colors">Clear</a>
        @endif
    </form>

    @if ($query === '')
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
            <p class="text-sm text-gray-500">Type a redemption code to get started.</p>
        </div>
    @elseif ($results->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <p class="text-sm text-gray-500">No voucher or redemption found for "{{ $query }}".</p>
        </div>
    @else
        <div class="space-y-4">
            @foreach ($results as $r)
                @php
                    $isVoucher = $r['type'] === 'voucher';
                    $badge = match (true) {
                        $r['is_fulfillable'] => 'bg-green-50 text-green-700 border-green-200',
                        $r['status'] === 'cancelled' => 'bg-red-50 text-red-600 border-red-200',
                        default => 'bg-gray-100 text-gray-600 border-gray-200',
                    };
                    $dot = $r['is_fulfillable'] ? 'bg-green-500' : ($r['status'] === 'cancelled' ? 'bg-red-500' : 'bg-gray-400');
                @endphp
                <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
                    <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                        <div class="flex-1">
                            <div class="flex items-center gap-2 mb-2">
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold {{ $isVoucher ? 'bg-blue-50 text-blue-700' : 'bg-purple-50 text-purple-700' }}">
                                    {{ $r['kind'] }}
                                </span>
                                <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium border {{ $badge }}">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                                    {{ ucfirst($r['status']) }}
                                </span>
                            </div>
                            <p class="text-lg font-semibold text-[#0F1B3D]">{{ $r['title'] }}</p>
                            <p class="text-sm text-gray-500 mt-0.5">
                                {{ $r['patient_name'] }} · {{ $r['patient_nric'] }}
                            </p>
                            <p class="mt-2">
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-sm font-mono font-medium bg-blue-50 text-blue-700">
                                    {{ $r['code'] }}
                                </span>
                            </p>
                        </div>
                        <div class="text-right shrink-0">
                            <p class="text-2xl font-bold text-[#00C9A7]">{{ $r['value'] }}</p>
                            <p class="text-xs text-gray-400 mt-1">
                                Redeemed {{ $r['created_at']?->format('d M Y, g:i A') }}
                                @if ($r['expires_at']) · Expires {{ $r['expires_at']->format('d M Y') }} @endif
                            </p>
                        </div>
                    </div>

                    <div class="flex items-center gap-2 mt-4 pt-4 border-t border-gray-100">
                        @if ($r['is_fulfillable'])
                            <form method="POST" action="{{ route('admin.redeem-at-counter.fulfill', ['type' => $r['type'], 'id' => $r['id']]) }}"
                                  onsubmit="return confirm('Fulfill {{ $r['code'] }}? Confirm the patient received the reward/discount.');">
                                @csrf
                                <button type="submit"
                                        class="px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                                    Fulfill
                                </button>
                            </form>
                        @endif
                        @if ($r['is_cancelable'])
                            <form method="POST" action="{{ route('admin.redeem-at-counter.cancel', ['type' => $r['type'], 'id' => $r['id']]) }}"
                                  onsubmit="return confirm('Cancel {{ $r['code'] }}?{{ $isVoucher ? '' : ' Points will be refunded.' }}');">
                                @csrf
                                <button type="submit"
                                        class="px-4 py-2 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                                    Cancel
                                </button>
                            </form>
                        @endif
                        <a href="{{ $r['print_url'] }}" target="_blank"
                           class="inline-flex items-center gap-1 px-4 py-2 text-sm font-medium text-[#0F1B3D] bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                            </svg>
                            Print
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
