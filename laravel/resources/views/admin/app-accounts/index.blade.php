@extends('layouts.admin')

@section('title', 'App Accounts')

@section('subtitle', 'Local app accounts (signups), linked status and duplicate detection')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.app-accounts.index') }}" class="flex flex-wrap gap-2 flex-1">
            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                placeholder="Search by name, NRIC, email or phone..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-xs"
            >
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('search') || in_array(request('view'), ['linked', 'not_linked'], true))
                <a href="{{ route('admin.app-accounts.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>
    </div>

    <div class="flex flex-wrap items-center gap-3 mb-4">
        @foreach ([
            'all' => 'All',
            'linked' => 'Linked',
            'not_linked' => 'Not Linked',
        ] as $value => $label)
            <a href="{{ $value === 'all'
                    ? route('admin.app-accounts.index', request()->except('view', 'page'))
                    : route('admin.app-accounts.index', array_merge(request()->except('view', 'page'), ['view' => $value])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-full transition-colors {{ $view === $value ? 'bg-[#00C9A7] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
                {{ $label }}
            </a>
        @endforeach
    </div>

    @if (count($duplicateGroups) > 0)
        <div class="mb-6 bg-amber-50 border border-amber-200 rounded-xl p-5 shadow-sm">
            <div class="flex items-center gap-2 mb-3">
                <svg class="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                <h3 class="text-sm font-semibold text-amber-800">Possible duplicate accounts ({{ count($duplicateGroups) }} groups)</h3>
            </div>
            <div class="space-y-3">
                @foreach ($duplicateGroups as $group)
                    @php
                        $fieldLabels = [
                            'nric' => 'Same NRIC',
                            'email' => 'Same email',
                            'telephone' => 'Same phone',
                        ];
                    @endphp
                    <div class="bg-white border border-amber-100 rounded-lg p-4">
                        <div class="text-xs font-medium text-gray-500 mb-2">
                            {{ $fieldLabels[$group['field']] ?? $group['field'] }}:
                            <span class="text-amber-700 font-semibold">{{ $group['value'] }}</span>
                        </div>
                        <div class="flex flex-wrap items-center gap-2">
                            @foreach ($group['patients'] as $dupPatient)
                                <a href="{{ route('admin.app-accounts.show', $dupPatient) }}"
                                   class="inline-flex items-center gap-1.5 px-3 py-1 text-xs font-medium text-[#0F1B3D] border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $dupPatient->idplato ? 'bg-blue-500' : 'bg-amber-500' }}"></span>
                                    {{ $dupPatient->name }}
                                    <span class="text-gray-400">#{{ $dupPatient->id }}</span>
                                    @if ($dupPatient->idplato)
                                        <span class="text-blue-500">Linked</span>
                                    @endif
                                </a>
                            @endforeach
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @endif

    @if ($accounts->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
            <p class="text-sm text-gray-500">No app accounts found.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Name</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">NRIC</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Phone</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Email</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">App Account</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Sign-up</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($accounts as $account)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 rounded-full bg-[#0F1B3D] text-white flex items-center justify-center text-xs font-bold">
                                            {{ strtoupper(substr($account->name, 0, 1)) }}
                                        </div>
                                        <div>
                                            <span class="font-medium text-[#0F1B3D]">{{ $account->name }}</span>
                                            <div class="text-xs text-gray-400">#{{ $account->id }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $account->nric ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $account->telephone ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $account->email ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    @if ($account->idplato)
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-600">
                                            <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
                                            App Linked
                                        </span>
                                    @else
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-600">
                                            <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                            Not Linked
                                        </span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">{{ $account->created_at?->format('d M Y') ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.app-accounts.show', $account) }}"
                                           class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-[#0F1B3D] border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                                           title="View account">
                                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                            </svg>
                                            View
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($accounts->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $accounts->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $accounts->firstItem() ?: 0 }}–{{ $accounts->lastItem() ?: 0 }} of {{ $accounts->total() }} accounts
        </p>
    @endif
@endsection
