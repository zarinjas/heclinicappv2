@extends('layouts.admin')

@section('title', 'Notification #' . $notification->id)

@section('subtitle', $notification->title)

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.notifications.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Notifications
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $notification->title }}</h3>
                        <div class="flex items-center gap-2 mt-2">
                            @php
                                $typeColors = [
                                    'manual' => 'bg-purple-50 text-purple-700',
                                    'appointment_confirmed' => 'bg-blue-50 text-blue-700',
                                    'appointment_reminder' => 'bg-yellow-50 text-yellow-700',
                                    'document_uploaded' => 'bg-green-50 text-green-700',
                                ];
                                $typeLabels = [
                                    'manual' => 'Manual',
                                    'appointment_confirmed' => 'Appointment Confirmed',
                                    'appointment_reminder' => 'Appointment Reminder',
                                    'document_uploaded' => 'Document Uploaded',
                                ];
                                $statusColors = [
                                    'draft' => 'bg-gray-100 text-gray-500',
                                    'pending' => 'bg-yellow-50 text-yellow-700',
                                    'sent' => 'bg-green-50 text-green-700',
                                    'failed' => 'bg-red-50 text-red-700',
                                ];
                                $statusDots = [
                                    'draft' => 'bg-gray-400',
                                    'pending' => 'bg-yellow-500',
                                    'sent' => 'bg-green-500',
                                    'failed' => 'bg-red-500',
                                ];
                            @endphp
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {{ $typeColors[$notification->type] ?? 'bg-gray-100 text-gray-600' }}">
                                {{ $typeLabels[$notification->type] ?? $notification->type }}
                            </span>
                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium {{ $statusColors[$notification->status] ?? 'bg-gray-100 text-gray-500' }}">
                                <span class="w-1.5 h-1.5 rounded-full {{ $statusDots[$notification->status] ?? 'bg-gray-400' }}"></span>
                                {{ ucfirst($notification->status) }}
                            </span>
                        </div>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">Message Body</dt>
                    <dd class="text-sm text-[#0F1B3D] whitespace-pre-wrap bg-gray-50 rounded-lg p-4">{{ $notification->body }}</dd>
                </div>

                <hr class="border-gray-100">

                <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Target Type</dt>
                        <dd class="mt-1">
                            @php
                                $targetColors = [
                                    'all' => 'bg-slate-100 text-slate-600',
                                    'branch' => 'bg-indigo-50 text-indigo-600',
                                    'doctor' => 'bg-cyan-50 text-cyan-600',
                                    'appointment_date_range' => 'bg-amber-50 text-amber-600',
                                    'specific_patient' => 'bg-pink-50 text-pink-600',
                                ];
                                $targetLabels = [
                                    'all' => 'All Users',
                                    'branch' => 'By Branch',
                                    'doctor' => 'By Doctor',
                                    'appointment_date_range' => 'By Appointment Date Range',
                                    'specific_patient' => 'Specific Patient',
                                ];
                            @endphp
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {{ $targetColors[$notification->target_type] ?? 'bg-gray-100 text-gray-600' }}">
                                {{ $targetLabels[$notification->target_type] ?? $notification->target_type }}
                            </span>
                        </dd>
                    </div>

                    @if ($notification->target_ids && is_array($notification->target_ids) && count($notification->target_ids) > 0)
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Target IDs</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ implode(', ', $notification->target_ids) }}</dd>
                        </div>
                    @endif

                    @if ($notification->target_date_from)
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Date Range From</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $notification->target_date_from->format('d M Y') }}</dd>
                        </div>
                    @endif

                    @if ($notification->target_date_to)
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Date Range To</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $notification->target_date_to->format('d M Y') }}</dd>
                        </div>
                    @endif

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Channels</dt>
                        <dd class="mt-1">
                            <div class="flex items-center gap-2">
                                @if (is_array($notification->channels))
                                    @if (in_array('push', $notification->channels))
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-blue-50 text-blue-600">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                                            </svg>
                                            Push
                                        </span>
                                    @endif
                                    @if (in_array('email', $notification->channels))
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-emerald-50 text-emerald-600">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                            </svg>
                                            Email
                                        </span>
                                    @endif
                                    @if (in_array('in_app', $notification->channels))
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-violet-50 text-violet-600">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                            </svg>
                                            In-App
                                        </span>
                                    @endif
                                @endif
                            </div>
                        </dd>
                    </div>

                    @if ($notification->image_url)
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Image URL</dt>
                            <dd class="mt-1 text-sm">
                                <a href="{{ $notification->image_url }}" target="_blank" class="text-[#00C9A7] hover:underline break-all">{{ $notification->image_url }}</a>
                            </dd>
                        </div>
                    @endif

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Sent At</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $notification->sent_at ? $notification->sent_at->format('d M Y, h:i A') : '—' }}</dd>
                    </div>
                </dl>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Created {{ $notification->created_at->format('d M Y, h:i A') }}
                    @if ($notification->updated_at->ne($notification->created_at))
                        &middot; Updated {{ $notification->updated_at->format('d M Y, h:i A') }}
                    @endif
                </p>
            </div>
        </div>
    </div>
@endsection
