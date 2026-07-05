@extends('layouts.admin')

@php
    $isPlato = $appointment->from_plato ?? false;

    if ($isPlato) {
        $title = $appointment->patient_name ?? 'Unknown Patient';
        $patientName = $appointment->patient_name ?? '—';
        $patientNric = $appointment->patient_nric ?? '—';
        $patientPhone = $appointment->patient_phone ?? '—';
        $apptDate = $appointment->appointment_date ?? '—';
        $apptTime = $appointment->appointment_time ?? '—';
        $doctorName = $appointment->doctor_name ?? '—';
        $branchName = $appointment->branch_name ?? '—';
        $calendarColorId = $appointment->calendar_color_id ?? '—';
        $notes = $appointment->notes ?? '';
        $apptStatus = strtolower($appointment->status ?? '');
        $platoAppointmentId = $appointment->id ?? '—';
        $createdAt = null;
        $updatedAt = null;
        $notifiedAt = null;
        $patientPlatoUid = $appointment->patient_id ?? null;
    } else {
        $title = $appointment->patient_name ?? 'Unknown Patient';
        $patientName = $appointment->patient_name ?? '—';
        $patientNric = $appointment->patient_nric ?? '—';
        $patientPhone = $appointment->patient_phone ?? '—';
        $apptDate = $appointment->appointment_date?->format('Y-m-d') ?? '—';
        $apptTime = $appointment->appointment_time ?? '—';
        $doctorName = $appointment->doctor_name ?? $appointment->doctor?->name ?? '—';
        $branchName = $appointment->branch_name ?? $appointment->branch?->name ?? '—';
        $calendarColorId = $appointment->calendar_color_id ?? '—';
        $notes = $appointment->notes ?? '';
        $apptStatus = strtolower($appointment->status ?? '');
        $platoAppointmentId = $appointment->plato_appointment_id ?? '—';
        $createdAt = $appointment->created_at;
        $updatedAt = $appointment->updated_at;
        $notifiedAt = $appointment->notified_at;
        $patientPlatoUid = $appointment->plato_response['patient_id'] ?? null;
    }

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

@section('title', $title . ' — Appointment Detail')

@section('subtitle', 'View appointment details')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.appointments.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Appointments
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $title }}</h3>
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium border mt-2 {{ $statusChip }}">
                            <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                            {{ ucfirst($apptStatus ?: '—') }}
                        </span>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h4 class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Patient Info</h4>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Name</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patientName }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">NRIC</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patientNric }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Phone</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patientPhone }}</dd>
                        </div>
                        @if ($patientPlatoUid)
                            <div>
                                <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Profile</dt>
                                <dd class="mt-1 text-sm">
                                    <a href="{{ route('admin.patients.show', ['patient' => $patientPlatoUid]) }}"
                                       class="text-[#00C9A7] hover:underline">
                                        View Patient Profile →
                                    </a>
                                </dd>
                            </div>
                        @endif
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h4 class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Appointment Details</h4>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Date</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $apptDate }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Time</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $apptTime }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Status</dt>
                            <dd class="mt-1 text-sm">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium border {{ $statusChip }}">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $dot }}"></span>
                                    {{ ucfirst($apptStatus ?: '—') }}
                                </span>
                            </dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Plato Appointment ID</dt>
                            <dd class="mt-1 text-sm font-mono text-[#0F1B3D] break-all">{{ $platoAppointmentId }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h4 class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Assignment</h4>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Doctor</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $doctorName }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Branch</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branchName }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Calendar Color ID</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $calendarColorId }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h4 class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Notes</h4>
                    <div class="text-sm text-[#0F1B3D]">
                        @if ($notes)
                            {{ $notes }}
                        @else
                            <span class="text-gray-400 italic">No notes</span>
                        @endif
                    </div>
                </div>

                @if (! $isPlato)
                <hr class="border-gray-100">

                <div>
                    <h4 class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Local Record</h4>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Created At</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                {{ $createdAt ? $createdAt->format('d M Y, h:i A') : '—' }}
                            </dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Updated At</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                {{ $updatedAt ? $updatedAt->format('d M Y, h:i A') : '—' }}
                            </dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Notification Sent</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                {{ $notifiedAt ? $notifiedAt->format('d M Y, h:i A') : 'Not yet' }}
                            </dd>
                        </div>
                    </dl>
                </div>
                @endif
            </div>

            @if (! $isPlato)
                <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                    <p class="text-xs text-gray-400">
                        Created {{ $createdAt?->format('d M Y, h:i A') ?? '—' }}
                        @if ($updatedAt && $createdAt && $updatedAt->ne($createdAt))
                            &middot; Updated {{ $updatedAt->format('d M Y, h:i A') }}
                        @endif
                    </p>
                </div>
            @endif
        </div>
    </div>
@endsection
