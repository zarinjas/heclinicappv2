@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 font-medium">Total Patients</p>
                    <p class="text-2xl font-bold text-[#0F1B3D] mt-1">{{ number_format($totalPatients) }}</p>
                </div>
                <div class="w-10 h-10 bg-[#00C9A7]/10 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-[#00C9A7]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                    </svg>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 font-medium">Appointments This Month</p>
                    <p class="text-2xl font-bold text-[#0F1B3D] mt-1">{{ number_format($totalAppointmentsThisMonth) }}</p>
                </div>
                <div class="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 font-medium">Notifications Sent</p>
                    <p class="text-2xl font-bold text-[#0F1B3D] mt-1">{{ number_format($totalNotifications) }}</p>
                </div>
                <div class="w-10 h-10 bg-purple-50 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                    </svg>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 font-medium">Delivery Rate</p>
                    <p class="text-2xl font-bold text-[#0F1B3D] mt-1">{{ $deliveryRate }}%</p>
                </div>
                <div class="w-10 h-10 bg-green-50 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                </div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <h3 class="text-lg font-semibold text-[#0F1B3D] mb-4">Appointment Trends (Last 30 Days)</h3>
            <div class="relative" style="height: 300px;">
                <canvas id="appointmentChart"></canvas>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <h3 class="text-lg font-semibold text-[#0F1B3D] mb-4">Quick Summary</h3>
            <div class="space-y-4">
                <div>
                    <p class="text-xs text-gray-400 uppercase tracking-wide">Logged In As</p>
                    <p class="text-sm font-medium text-[#0F1B3D]">{{ $user->name }}</p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase tracking-wide">Role</p>
                    <p class="text-sm font-medium text-[#00C9A7]">{{ str_replace('_', ' ', ucwords($user->role, '_')) }}</p>
                </div>
                @if($user->branch)
                    <div>
                        <p class="text-xs text-gray-400 uppercase tracking-wide">Branch</p>
                        <p class="text-sm font-medium text-[#0F1B3D]">{{ $user->branch->name }}</p>
                    </div>
                @endif
                <div>
                    <p class="text-xs text-gray-400 uppercase tracking-wide">Appt. Avg/Day</p>
                    <p class="text-sm font-medium text-[#0F1B3D]">
                        {{ $totalAppointmentsThisMonth > 0 && now()->day > 0
                            ? round($totalAppointmentsThisMonth / max(now()->day, 1), 1)
                            : '0' }}
                    </p>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const ctx = document.getElementById('appointmentChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: {!! json_encode($chartLabels) !!},
                datasets: [{
                    label: 'Appointments',
                    data: {!! json_encode($chartData) !!},
                    borderColor: '#00C9A7',
                    backgroundColor: 'rgba(0, 201, 167, 0.1)',
                    fill: true,
                    tension: 0.3,
                    pointRadius: 2,
                    pointHoverRadius: 6,
                    borderWidth: 2,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false,
                    },
                    tooltip: {
                        backgroundColor: '#0F1B3D',
                        titleColor: '#FFFFFF',
                        bodyColor: '#FFFFFF',
                        cornerRadius: 8,
                        padding: 12,
                    }
                },
                scales: {
                    x: {
                        grid: {
                            display: false,
                        },
                        ticks: {
                            maxTicksLimit: 10,
                            color: '#9CA3AF',
                            font: { size: 11 },
                        }
                    },
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: '#F3F4F6',
                        },
                        ticks: {
                            stepSize: 1,
                            color: '#9CA3AF',
                            font: { size: 11 },
                        }
                    }
                }
            }
        });
    });
</script>
@endpush
