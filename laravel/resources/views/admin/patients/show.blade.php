@extends('layouts.admin')

@section('title', $patient['name'] ?? 'Patient Detail')

@section('subtitle', 'Patient record from Plato')

@section('content')
    <div class="mb-6">
        <a href="{{ route('admin.patients.index') }}" class="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-[#0F1B3D] transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
            Back to Patients
        </a>
    </div>

    <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $patient['name'] ?? 'Unknown' }}</h3>
                <p class="text-sm text-gray-400 mt-1">Given ID: {{ $patient['givenid'] ?? '—' }}</p>
            </div>
        </div>

        <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-8 gap-y-4">
            <div>
                <dt class="text-xs font-medium uppercase text-gray-400">NRIC</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['nric'] ?? '—' }}</dd>
            </div>
            <div>
                <dt class="text-xs font-medium uppercase text-gray-400">Phone</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['phone'] ?? '—' }}</dd>
            </div>
            <div>
                <dt class="text-xs font-medium uppercase text-gray-400">Date of Birth</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['dob'] ?? '—' }}</dd>
            </div>
            <div>
                <dt class="text-xs font-medium uppercase text-gray-400">Gender</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['gender'] ?? '—' }}</dd>
            </div>
            <div class="sm:col-span-2">
                <dt class="text-xs font-medium uppercase text-gray-400">Address</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['address'] ?? '—' }}</dd>
            </div>
            <div>
                <dt class="text-xs font-medium uppercase text-gray-400">Nationality</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['nationality'] ?? '—' }}</dd>
            </div>
            <div class="sm:col-span-2">
                <dt class="text-xs font-medium uppercase text-gray-400">Allergies</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['allergies'] ?? 'None' }}</dd>
            </div>
            <div class="sm:col-span-2">
                <dt class="text-xs font-medium uppercase text-gray-400">Medical Notes</dt>
                <dd class="text-sm text-[#0F1B3D] mt-1">{{ $patient['medical_notes'] ?? $patient['notes'] ?? 'None' }}</dd>
            </div>
        </dl>
    </div>
@endsection
