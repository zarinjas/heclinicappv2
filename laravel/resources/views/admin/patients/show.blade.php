@extends('layouts.admin')

@section('title', $patient['name'] ?? 'Patient Detail')

@section('subtitle', 'Patient record from Plato')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.patients.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Patients
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $patient['name'] ?? 'Unknown' }}</h3>
                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium mt-2 bg-[#00C9A7]/10 text-[#00C9A7]">
                            {{ $patient['givenid'] ?? '—' }}
                        </span>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="{{ route('admin.patients.show', ['patient' => $patient['id'] ?? request()->route('patient'), 'sync' => 1]) }}"
                           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b89a] transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                            </svg>
                            Re-sync from Plato
                        </a>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Personal Info</p>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">NRIC</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['nric'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Date of Birth</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['dob'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Gender</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['gender'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Nationality</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['nationality'] ?? '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Contact</p>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Phone</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['phone'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Address</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['address'] ?? '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Medical</p>
                    <dl class="grid grid-cols-1 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Allergies</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if (!empty($patient['allergies']))
                                    @if (is_array($patient['allergies']))
                                        {{ implode(', ', $patient['allergies']) }}
                                    @else
                                        {{ $patient['allergies'] }}
                                    @endif
                                @else
                                    <span class="text-gray-400">None</span>
                                @endif
                            </dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Medical Notes</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if (!empty($patient['medical_notes'] ?? $patient['notes'] ?? null))
                                    {{ $patient['medical_notes'] ?? $patient['notes'] }}
                                @else
                                    <span class="text-gray-400">None</span>
                                @endif
                            </dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Vitals</p>
                    <dl class="grid grid-cols-1 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Vital Records</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if ($vitalsCount !== null)
                                    <span class="inline-flex items-center gap-1.5">
                                        <span class="w-2 h-2 rounded-full bg-green-500"></span>
                                        {{ $vitalsCount }} vital record{{ $vitalsCount !== 1 ? 's' : '' }} available
                                    </span>
                                @else
                                    <span class="text-gray-400 italic">Unavailable</span>
                                @endif
                            </dd>
                        </div>
                    </dl>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Patient ID: {{ $patient['id'] ?? 'Unknown' }}
                </p>
            </div>
        </div>
    </div>
@endsection
