@extends('layouts.admin')

@section('title', 'Appointments')

@section('subtitle', 'View and filter all clinic appointments from Plato')

@section('content')
    <div class="flex flex-col gap-4 mb-6">
        <form method="GET" action="{{ route('admin.appointments.index') }}" class="flex flex-wrap items-end gap-3">
            <div class="flex flex-col gap-1">
                <label for="date_from" class="text-xs font-medium text-gray-500">From</label>
                <input
                    type="date"
                    id="date_from"
                    name="date_from"
                    value="{{ request('date_from') }}"
                    class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
            </div>

            <div class="flex flex-col gap-1">
                <label for="date_to" class="text-xs font-medium text-gray-500">To</label>
                <input
                    type="date"
                    id="date_to"
                    name="date_to"
                    value="{{ request('date_to') }}"
                    class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
            </div>

            <div class="flex flex-col gap-1">
                <label for="doctor_id" class="text-xs font-medium text-gray-500">Doctor</label>
                <select
                    id="doctor_id"
                    name="doctor_id"
                    class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white"
                >
                    <option value="">All Doctors</option>
                    @foreach ($doctors as $doctor)
                        <option value="{{ $doctor->plato_facility_id ?? $doctor->id }}" {{ request('doctor_id') == ($doctor->plato_facility_id ?? $doctor->id) ? 'selected' : '' }}>
                            {{ $doctor->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="flex flex-col gap-1">
                <label for="facility_id" class="text-xs font-medium text-gray-500">Branch</label>
                <select
                    id="facility_id"
                    name="facility_id"
                    class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white"
                >
                    <option value="">All Branches</option>
                    @foreach ($branches as $branch)
                        <option value="{{ $branch->plato_facility_id }}" {{ request('facility_id') == $branch->plato_facility_id ? 'selected' : '' }}>
                            {{ $branch->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="flex flex-col gap-1">
                <label for="status" class="text-xs font-medium text-gray-500">Status</label>
                <select
                    id="status"
                    name="status"
                    class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white"
                >
                    <option value="">All Statuses</option>
                    <option value="confirmed" {{ request('status') === 'confirmed' ? 'selected' : '' }}>Confirmed</option>
                    <option value="pending" {{ request('status') === 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="cancelled" {{ request('status') === 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                    <option value="completed" {{ request('status') === 'completed' ? 'selected' : '' }}>Completed</option>
                </select>
            </div>

            <div class="flex gap-2">
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                    Filter
                </button>
                @if (request('date_from') || request('date_to') || request('doctor_id') || request('facility_id') || request('status'))
                    <a href="{{ route('admin.appointments.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                        Clear
                    </a>
                @endif
            </div>
        </form>

        <div class="flex items-center justify-between">
            <p class="text-xs text-gray-400">
                @if ($appointments->total() > 0)
                    Showing {{ $appointments->firstItem() ?: 0 }}–{{ $appointments->lastItem() ?: 0 }} of {{ $appointments->total() }} appointments
                @endif
            </p>
            <a href="{{ route('admin.appointments.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                New Walk-In Appointment
            </a>
        </div>
    </div>

    @if (count($appointments) === 0)
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
            </svg>
            <p class="text-sm text-gray-500">No appointments found matching your filters.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Date</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Time</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Patient Name</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">NRIC</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Doctor</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Branch</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($appointments as $appointment)
                            @php
                                $apptDate = $appointment['appointment_date'] ?? '—';
                                $apptTime = $appointment['appointment_time'] ?? '—';
                                $patientName = $appointment['patient_name'] ?? 'Unknown';
                                $patientNric = $appointment['patient_nric'] ?? '—';
                                $doctorName = $appointment['doctor_name'] ?? '—';
                                $branchName = $appointment['branch_name'] ?? '—';
                                $apptStatus = strtolower($appointment['status'] ?? '');

                                $statusColors = [
                                    'confirmed' => 'bg-green-50 text-green-700 border-green-200',
                                    'pending' => 'bg-amber-50 text-amber-700 border-amber-200',
                                    'cancelled' => 'bg-red-50 text-red-700 border-red-200',
                                    'completed' => 'bg-blue-50 text-blue-700 border-blue-200',
                                ];
                                $statusDot = [
                                    'confirmed' => 'bg-green-500',
                                    'pending' => 'bg-amber-500',
                                    'cancelled' => 'bg-red-500',
                                    'completed' => 'bg-blue-500',
                                ];
                                $statusChip = $statusColors[$apptStatus] ?? 'bg-gray-50 text-gray-500 border-gray-200';
                                $dot = $statusDot[$apptStatus] ?? 'bg-gray-400';
                            @endphp
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">{{ $apptDate }}</td>
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">{{ $apptTime }}</td>
                                <td class="px-6 py-4 font-medium text-[#0F1B3D]">{{ $patientName }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $patientNric }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $doctorName }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $branchName }}</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium border {{ $statusChip }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                                        {{ ucfirst($apptStatus ?: '—') }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <button
                                            class="p-1.5 text-gray-300 cursor-not-allowed"
                                            disabled
                                            title="Appointment detail coming soon">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                            </svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($appointments->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $appointments->links() }}
                </div>
            @endif
        </div>
    @endif
@endsection
