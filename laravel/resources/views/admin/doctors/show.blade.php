@extends('layouts.admin')

@section('title', $doctor->name)

@section('subtitle', 'Doctor details')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.doctors.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Doctors
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div class="flex items-center gap-4">
                        @if ($doctor->photo)
                            <img src="{{ Storage::disk('public')->url($doctor->photo) }}" alt="{{ $doctor->name }}" class="w-16 h-16 rounded-xl object-cover border border-gray-200">
                        @else
                            <div class="w-16 h-16 rounded-xl bg-[#00C9A7]/10 flex items-center justify-center text-[#00C9A7] text-xl font-bold">
                                {{ strtoupper(substr($doctor->name, 0, 2)) }}
                            </div>
                        @endif
                        <div>
                            <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $doctor->name }}</h3>
                            <div class="flex items-center gap-2 mt-1">
                                <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $doctor->is_visible_in_app ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                                    @if ($doctor->is_visible_in_app)
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                        </svg>
                                        Visible in App
                                    @else
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
                                        </svg>
                                        Hidden in App
                                    @endif
                                </span>
                                <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $doctor->is_active ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $doctor->is_active ? 'bg-green-500' : 'bg-red-500' }}"></span>
                                    {{ $doctor->is_active ? 'Active' : 'Inactive' }}
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="{{ route('admin.doctors.edit', $doctor) }}"
                           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                            </svg>
                            Edit
                        </a>
                    </div>
                </div>

                <hr class="border-gray-100">

                <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Specialty</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $doctor->specialty ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Branch</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $doctor->branch?->name ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Plato Facility ID</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $doctor->plato_facility_id ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Linked Calendars</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $doctor->platoCalendars->count() }}</dd>
                    </div>

                    <div class="sm:col-span-2">
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Bio</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D] whitespace-pre-wrap">{{ $doctor->bio ?: 'No bio provided.' }}</dd>
                    </div>
                </dl>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Created {{ $doctor->created_at->format('d M Y, h:i A') }}
                    @if ($doctor->updated_at->ne($doctor->created_at))
                        &middot; Updated {{ $doctor->updated_at->format('d M Y, h:i A') }}
                    @endif
                </p>
            </div>
        </div>
    </div>
@endsection
