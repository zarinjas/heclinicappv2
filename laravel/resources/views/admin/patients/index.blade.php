@extends('layouts.admin')

@section('title', 'Patients')

@section('subtitle', 'View and search patient records from Plato')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.patients.index') }}" class="flex flex-wrap gap-2 flex-1">
            <input
                type="text"
                name="search_name"
                value="{{ request('search_name') }}"
                placeholder="Search by name..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-xs"
            >
            <input
                type="text"
                name="search_nric"
                value="{{ request('search_nric') }}"
                placeholder="Search by NRIC..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-xs"
            >
            <input
                type="text"
                name="search_phone"
                value="{{ request('search_phone') }}"
                placeholder="Search by phone..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-xs"
            >
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('search_name') || request('search_nric') || request('search_phone'))
                <a href="{{ route('admin.patients.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>
    </div>

    @if (count($patients) === 0)
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
            <p class="text-sm text-gray-500">No patients found.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">#</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Name</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">NRIC</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Phone</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">App Account</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($patients as $index => $patient)
                            @php
                                $patientId = $patient['_id'] ?? $patient['id'] ?? null;
                                $patientName = $patient['name'] ?? 'Unknown';
                                $patientNric = $patient['nric'] ?? '—';
                                $patientPhone = $patient['telephone'] ?? $patient['phone'] ?? '—';
                                $isLinked = $patientId && in_array($patientId, $linked ?? [], true);
                            @endphp
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4 text-gray-400">{{ ($patients->currentPage() - 1) * 20 + $index + 1 }}</td>
                                <td class="px-6 py-4 font-medium text-[#0F1B3D]">{{ $patientName }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $patientNric }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $patientPhone }}</td>
                                <td class="px-6 py-4">
                                    @if ($isLinked)
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
                                <td class="px-6 py-4">
                                    @if ($patientId)
                                        <div class="flex items-center justify-end gap-2">
                                            <a href="{{ route('admin.patients.show', $patientId) }}"
                                               class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-[#0F1B3D] border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                                               title="View Patient">
                                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                                </svg>
                                                View
                                            </a>
                                            <form action="{{ route('admin.patients.reset-password', $patientId) }}" method="POST"
                                                  onsubmit="return confirm('Reset password for {{ addslashes($patientName) }}? A temporary password will be generated.')">
                                                @csrf
                                                <button type="submit"
                                                        class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors"
                                                        title="Reset Password">
                                                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                                                    </svg>
                                                    Reset
                                                </button>
                                            </form>
                                        </div>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($patients->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $patients->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $patients->firstItem() ?: 0 }}–{{ $patients->lastItem() ?: 0 }} of {{ $patients->total() }} patients
        </p>
    @endif
@endsection
