@extends('layouts.admin')

@section('title', $calendar->name ?: 'Calendar ' . $calendar->plato_calendar_color_id)

@section('subtitle', 'Calendar mapping details')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.calendars.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Calendar Setup
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">
                            {{ $calendar->name ?: 'Calendar ' . $calendar->plato_calendar_color_id }}
                        </h3>
                        <div class="flex items-center gap-2 mt-1">
                            <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $calendar->is_active ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">
                                <span class="w-1.5 h-1.5 rounded-full {{ $calendar->is_active ? 'bg-green-500' : 'bg-red-500' }}"></span>
                                {{ $calendar->is_active ? 'Active' : 'Inactive' }}
                            </span>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="{{ route('admin.calendars.edit', $calendar) }}"
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
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Plato Calendar Color ID</dt>
                        <dd class="mt-1 text-sm font-mono text-[#0F1B3D]">{{ $calendar->plato_calendar_color_id }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Doctor</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">
                            @if ($calendar->doctor)
                                {{ $calendar->doctor->name }}
                                @if ($calendar->doctor->branch)
                                    <span class="text-gray-400">({{ $calendar->doctor->branch->name }})</span>
                                @endif
                            @else
                                <span class="text-gray-400">Unmapped</span>
                            @endif
                        </dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Calendar Name</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $calendar->name ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Status</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $calendar->is_active ? 'Active' : 'Inactive' }}</dd>
                    </div>

                    @if ($calendar->doctor)
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Doctor Branch</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $calendar->doctor->branch?->name ?: '—' }}</dd>
                        </div>

                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Doctor Visible in App</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $calendar->doctor->is_visible_in_app ? 'Yes' : 'No' }}</dd>
                        </div>
                    @endif
                </dl>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Created {{ $calendar->created_at->format('d M Y, h:i A') }}
                    @if ($calendar->updated_at->ne($calendar->created_at))
                        &middot; Updated {{ $calendar->updated_at->format('d M Y, h:i A') }}
                    @endif
                </p>
            </div>
        </div>
    </div>
@endsection
