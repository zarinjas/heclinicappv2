@extends('layouts.admin')

@section('title', 'Patient Duplicates')
@section('subtitle', 'Read-only report of Plato patients sharing an NRIC or phone number')

@section('content')
    @php
        $hasSnapshot = ! empty($snapshot);
        $snapshotFresh = $hasSnapshot
            ? \Illuminate\Support\Carbon::parse($snapshot['scanned_at'])->diffForHumans()
            : null;
        $queryForExport = array_filter([
            'signal' => $signal,
            'app' => $app,
            'search' => $search !== '' ? $search : null,
        ]);
    @endphp

    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between mb-6">
        <form method="GET" action="{{ route('admin.patient-duplicates.index') }}" class="flex flex-wrap gap-2 flex-1">
            <input
                type="text"
                name="search"
                value="{{ $search }}"
                placeholder="Search name, NRIC, phone, email or Plato ID..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-sm"
            >
            <select name="signal" class="px-4 py-2 text-sm border border-gray-200 rounded-lg bg-white outline-none focus:ring-2 focus:ring-[#00C9A7]">
                <option value="">All signals</option>
                <option value="same_ic" @selected($signal === 'same_ic')>Same IC</option>
                <option value="same_phone" @selected($signal === 'same_phone')>Same phone</option>
            </select>
            <select name="app" class="px-4 py-2 text-sm border border-gray-200 rounded-lg bg-white outline-none focus:ring-2 focus:ring-[#00C9A7]">
                <option value="">All accounts</option>
                <option value="linked" @selected($app === 'linked')>Linked to app</option>
                <option value="not_linked" @selected($app === 'not_linked')>Not linked</option>
            </select>
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Filter
            </button>
            @if ($search !== '' || $signal || $app)
                <a href="{{ route('admin.patient-duplicates.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>

        <div class="flex items-center gap-2">
            <form method="POST" action="{{ route('admin.patient-duplicates.scan') }}">
                @csrf
                <button type="submit" class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-[#0F1B3D] border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    Scan now
                </button>
            </form>
            @if ($hasSnapshot)
                <a href="{{ route('admin.patient-duplicates.export', $queryForExport) }}"
                   class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b096] transition-colors">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                    </svg>
                    Export CSV
                </a>
            @endif
        </div>
    </div>

    @if ($hasSnapshot)
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm">
                <p class="text-xs font-medium text-gray-400 uppercase">Last scan</p>
                <p class="text-lg font-semibold text-[#0F1B3D] mt-1">{{ $snapshotFresh }}</p>
                <p class="text-xs text-gray-400 mt-0.5">{{ \Illuminate\Support\Carbon::parse($snapshot['scanned_at'])->format('d M Y, H:i') }}</p>
            </div>
            <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm">
                <p class="text-xs font-medium text-gray-400 uppercase">Patients scanned</p>
                <p class="text-lg font-semibold text-[#0F1B3D] mt-1">{{ number_format($snapshot['total_scanned']) }}</p>
            </div>
            <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm">
                <p class="text-xs font-medium text-gray-400 uppercase">Duplicate clusters</p>
                <p class="text-lg font-semibold text-amber-600 mt-1">{{ number_format($snapshot['cluster_count']) }}</p>
            </div>
        </div>
    @else
        <div class="mb-6 bg-blue-50 border border-blue-200 rounded-xl p-5 text-sm text-blue-800 shadow-sm">
            No scan has been run yet. Click <strong>Scan now</strong> to fetch Plato patients and detect duplicates,
            or run <code class="px-1.5 py-0.5 bg-white/70 rounded">php artisan plato:scan-duplicates</code> on the server.
        </div>
    @endif

    @if ($hasSnapshot && count($clusters) === 0)
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            @if ($search !== '' || $signal || $app)
                <p class="text-sm text-gray-500">No duplicate clusters match the current filter.</p>
            @else
                <p class="text-sm text-gray-500">No duplicate patients found.</p>
            @endif
        </div>
    @endif

    @if (count($clusters) > 0)
        <div class="space-y-4">
            @foreach ($clusters as $cluster)
                @php
                    $clusterIds = collect($cluster['records'])
                        ->map(fn ($r) => $r['plato_id'].' ('.($r['name'] ?: 'no name').')')
                        ->implode("\n");
                @endphp
                <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
                    <div class="flex flex-wrap items-center justify-between gap-3 px-5 py-3 border-b border-gray-100 bg-gray-50/60">
                        <div class="flex items-center gap-3">
                            @php
                                $isIc = in_array('same_ic', $cluster['signals'], true);
                            @endphp
                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium
                                {{ $isIc ? 'bg-red-50 text-red-600' : 'bg-amber-50 text-amber-600' }}">
                                <span class="w-1.5 h-1.5 rounded-full {{ $isIc ? 'bg-red-500' : 'bg-amber-500' }}"></span>
                                {{ $cluster['signal_label'] }}
                            </span>
                            <span class="text-xs text-gray-400">{{ count($cluster['records']) }} records · {{ $cluster['id'] }}</span>
                        </div>
                        <button type="button"
                                class="copy-ids inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-[#0F1B3D] border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                                data-ids="{{ $clusterIds }}">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                            </svg>
                            <span class="copy-ids-label">Copy IDs</span>
                        </button>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b border-gray-100 text-left text-gray-500">
                                    <th class="px-5 py-2.5 font-medium">Name</th>
                                    <th class="px-5 py-2.5 font-medium">NRIC</th>
                                    <th class="px-5 py-2.5 font-medium">Phone</th>
                                    <th class="px-5 py-2.5 font-medium">Email</th>
                                    <th class="px-5 py-2.5 font-medium">Created</th>
                                    <th class="px-5 py-2.5 font-medium">App account</th>
                                    <th class="px-5 py-2.5 font-medium">Plato ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($cluster['records'] as $record)
                                    <tr class="border-b border-gray-50 last:border-0 hover:bg-gray-50/40">
                                        <td class="px-5 py-3 font-medium text-[#0F1B3D]">{{ $record['name'] ?: '—' }}</td>
                                        <td class="px-5 py-3 text-gray-600">{{ $record['nric'] ?: '—' }}</td>
                                        <td class="px-5 py-3 text-gray-600">{{ $record['phone'] ?: '—' }}</td>
                                        <td class="px-5 py-3 text-gray-600">{{ $record['email'] ?: '—' }}</td>
                                        <td class="px-5 py-3 text-gray-500 whitespace-nowrap">{{ $record['created_on'] ?: '—' }}</td>
                                        <td class="px-5 py-3">
                                            @if ($record['app_account_id'])
                                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-600">
                                                    <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
                                                    Linked #{{ $record['app_account_id'] }}
                                                </span>
                                            @else
                                                <span class="text-xs text-gray-400">—</span>
                                            @endif
                                        </td>
                                        <td class="px-5 py-3 text-gray-400 font-mono text-xs">{{ $record['plato_id'] }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            @endforeach
        </div>

        <p class="text-xs text-gray-400 mt-6">
            Showing {{ count($clusters) }} cluster(s). This report is read-only — merge records manually inside Plato.
            Records marked <span class="text-blue-500 font-medium">Linked</span> are tied to an app account: reconcile the app before deleting them in Plato.
        </p>
    @endif
@endsection

@push('scripts')
    <script>
        document.querySelectorAll('.copy-ids').forEach(function (button) {
            button.addEventListener('click', function () {
                const text = button.getAttribute('data-ids') || '';
                const label = button.querySelector('.copy-ids-label');

                const done = function () {
                    if (!label) return;
                    label.textContent = 'Copied!';
                    setTimeout(function () { label.textContent = 'Copy IDs'; }, 1500);
                };

                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(text).then(done).catch(function () {});
                } else {
                    const area = document.createElement('textarea');
                    area.value = text;
                    document.body.appendChild(area);
                    area.select();
                    document.execCommand('copy');
                    document.body.removeChild(area);
                    done();
                }
            });
        });
    </script>
@endpush
