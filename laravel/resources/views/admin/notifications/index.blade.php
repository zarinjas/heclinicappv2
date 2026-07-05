@extends('layouts.admin')

@section('title', 'Notification History')

@section('subtitle', 'View all sent and drafted notifications')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.notifications.index') }}" class="flex flex-wrap items-end gap-3 flex-1">
            <div class="flex-1 min-w-[200px]">
                <label for="search" class="block text-xs font-medium text-gray-400 mb-1">Search</label>
                <input
                    type="text"
                    name="search"
                    id="search"
                    value="{{ request('search') }}"
                    placeholder="Search by title or body..."
                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
            </div>

            <div>
                <label for="status" class="block text-xs font-medium text-gray-400 mb-1">Status</label>
                <select name="status" id="status"
                        class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    <option value="">All</option>
                    <option value="draft" {{ request('status') === 'draft' ? 'selected' : '' }}>Draft</option>
                    <option value="pending" {{ request('status') === 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="sent" {{ request('status') === 'sent' ? 'selected' : '' }}>Sent</option>
                    <option value="failed" {{ request('status') === 'failed' ? 'selected' : '' }}>Failed</option>
                </select>
            </div>

            <div>
                <label for="type" class="block text-xs font-medium text-gray-400 mb-1">Type</label>
                <select name="type" id="type"
                        class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    <option value="">All</option>
                    <option value="manual" {{ request('type') === 'manual' ? 'selected' : '' }}>Manual</option>
                    <option value="appointment_confirmed" {{ request('type') === 'appointment_confirmed' ? 'selected' : '' }}>Appt Confirmed</option>
                    <option value="appointment_reminder" {{ request('type') === 'appointment_reminder' ? 'selected' : '' }}>Appt Reminder</option>
                    <option value="document_uploaded" {{ request('type') === 'document_uploaded' ? 'selected' : '' }}>Doc Uploaded</option>
                </select>
            </div>

            <div>
                <label for="date_from" class="block text-xs font-medium text-gray-400 mb-1">From</label>
                <input
                    type="date"
                    name="date_from"
                    id="date_from"
                    value="{{ request('date_from') }}"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
            </div>

            <div>
                <label for="date_to" class="block text-xs font-medium text-gray-400 mb-1">To</label>
                <input
                    type="date"
                    name="date_to"
                    id="date_to"
                    value="{{ request('date_to') }}"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                >
            </div>

            <div class="flex items-end gap-2">
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                    Filter
                </button>
                @if (request('search') || request('status') || request('type') || request('date_from') || request('date_to'))
                    <a href="{{ route('admin.notifications.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                        Clear
                    </a>
                @endif
            </div>
        </form>

        <a href="{{ route('admin.notifications.compose') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Compose New
        </a>
    </div>

    @if ($notifications->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No notifications found.</p>
            <a href="{{ route('admin.notifications.compose') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Create First Notification
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100 sticky top-0">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">
                                <a href="{{ route('admin.notifications.index', array_merge(request()->query(), ['sort' => 'id', 'direction' => request('sort') === 'id' && request('direction') === 'asc' ? 'desc' : 'asc'])) }}"
                                   class="inline-flex items-center gap-1 hover:text-[#0F1B3D]">
                                    #
                                    @if (request('sort') === 'id')
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ request('direction') === 'asc' ? 'M5 15l7-7 7 7' : 'M19 9l-7 7-7-7' }}"/>
                                        </svg>
                                    @endif
                                </a>
                            </th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Type</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Title</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Target</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Channels</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($notifications as $notification)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors cursor-pointer"
                                onclick="window.location='{{ route('admin.notifications.show', $notification) }}'">
                                <td class="px-6 py-4 font-mono text-xs text-gray-400">{{ $notification->id }}</td>
                                <td class="px-6 py-4">
                                    @php
                                        $typeColors = [
                                            'manual' => 'bg-purple-50 text-purple-700',
                                            'appointment_confirmed' => 'bg-blue-50 text-blue-700',
                                            'appointment_reminder' => 'bg-yellow-50 text-yellow-700',
                                            'document_uploaded' => 'bg-green-50 text-green-700',
                                        ];
                                        $typeLabels = [
                                            'manual' => 'Manual',
                                            'appointment_confirmed' => 'Appt Confirmed',
                                            'appointment_reminder' => 'Appt Reminder',
                                            'document_uploaded' => 'Doc Uploaded',
                                        ];
                                    @endphp
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {{ $typeColors[$notification->type] ?? 'bg-gray-100 text-gray-600' }}">
                                        {{ $typeLabels[$notification->type] ?? $notification->type }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 font-medium text-[#0F1B3D] max-w-xs">
                                    <span class="truncate block">{{ \Illuminate\Support\Str::limit($notification->title, 50) }}</span>
                                </td>
                                <td class="px-6 py-4">
                                    @php
                                        $targetColors = [
                                            'all' => 'bg-slate-100 text-slate-600',
                                            'branch' => 'bg-indigo-50 text-indigo-600',
                                            'doctor' => 'bg-cyan-50 text-cyan-600',
                                            'appointment_date_range' => 'bg-amber-50 text-amber-600',
                                            'specific_patient' => 'bg-pink-50 text-pink-600',
                                        ];
                                        $targetLabels = [
                                            'all' => 'All',
                                            'branch' => 'Branch',
                                            'doctor' => 'Doctor',
                                            'appointment_date_range' => 'Date Range',
                                            'specific_patient' => 'Patient',
                                        ];
                                    @endphp
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {{ $targetColors[$notification->target_type] ?? 'bg-gray-100 text-gray-600' }}">
                                        {{ $targetLabels[$notification->target_type] ?? $notification->target_type }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-1">
                                        @if (is_array($notification->channels))
                                            @if (in_array('push', $notification->channels))
                                                <span class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-50 text-blue-600" title="Push">
                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                                                    </svg>
                                                </span>
                                            @endif
                                            @if (in_array('email', $notification->channels))
                                                <span class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-emerald-50 text-emerald-600" title="Email">
                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                                    </svg>
                                                </span>
                                            @endif
                                            @if (in_array('in_app', $notification->channels))
                                                <span class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-violet-50 text-violet-600" title="In-App">
                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                                    </svg>
                                                </span>
                                            @endif
                                        @endif
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    @php
                                        $statusColors = [
                                            'draft' => 'bg-gray-100 text-gray-500',
                                            'pending' => 'bg-yellow-50 text-yellow-700',
                                            'sent' => 'bg-green-50 text-green-700',
                                            'failed' => 'bg-red-50 text-red-700',
                                        ];
                                    @endphp
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $statusColors[$notification->status] ?? 'bg-gray-100 text-gray-500' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $notification->status === 'sent' ? 'bg-green-500' : ($notification->status === 'failed' ? 'bg-red-500' : ($notification->status === 'pending' ? 'bg-yellow-500' : 'bg-gray-400')) }}"></span>
                                        {{ ucfirst($notification->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500 text-xs whitespace-nowrap">
                                    {{ $notification->sent_at ? $notification->sent_at->format('d M Y, h:i A') : $notification->created_at->format('d M Y, h:i A') }}
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($notifications->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $notifications->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $notifications->firstItem() ?: 0 }}–{{ $notifications->lastItem() ?: 0 }} of {{ $notifications->total() }} notifications
        </p>
    @endif
@endsection
