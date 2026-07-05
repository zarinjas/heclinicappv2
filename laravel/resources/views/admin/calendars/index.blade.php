@extends('layouts.admin')

@section('title', 'Calendar Setup')

@section('subtitle', 'Map doctors to Plato calendar color IDs')

@section('content')
    <div class="bg-white rounded-xl border border-gray-100 shadow-sm mb-6">
        <div class="p-6">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h3 class="text-sm font-medium text-[#0F1B3D]">Plato Calendar Sync</h3>
                    @if ($lastSync)
                        <p class="text-xs text-gray-400 mt-1">Last synced: {{ \Carbon\Carbon::parse($lastSync)->format('d M Y, h:i A') }}</p>
                    @else
                        <p class="text-xs text-gray-400 mt-1">Never synced</p>
                    @endif
                </div>
                <form method="POST" action="{{ route('admin.calendars.sync') }}" class="inline">
                    @csrf
                    <button type="submit"
                            class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                        Sync Calendars from Plato
                    </button>
                </form>
            </div>

            @if (session('sync_calendars'))
                @php $syncData = session('sync_calendars'); @endphp
                <div class="mt-4 p-4 bg-[#00C9A7]/5 border border-[#00C9A7]/20 rounded-lg">
                    <p class="text-sm font-medium text-[#0F1B3D] mb-3">Available Plato Calendars ({{ count($syncData) }})</p>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                        @foreach ($syncData as $cal)
                            <div class="flex items-center justify-between p-2 bg-white rounded border border-gray-100 text-sm">
                                <span class="text-[#0F1B3D] font-medium">{{ $cal['name'] }}</span>
                                <code class="text-xs text-gray-400 bg-gray-50 px-2 py-0.5 rounded">{{ $cal['plato_calendar_color_id'] }}</code>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endif
        </div>
    </div>

    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.calendars.index') }}" class="flex flex-wrap gap-2 flex-1">
            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                placeholder="Search by calendar name, color ID, or doctor..."
                class="w-full sm:w-auto sm:flex-1 max-w-xs px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
            >
            <select
                name="doctor_id"
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                onchange="this.form.submit()"
            >
                <option value="">All Doctors</option>
                @foreach ($doctors as $doctor)
                    <option value="{{ $doctor->id }}" {{ request('doctor_id') == $doctor->id ? 'selected' : '' }}>
                        {{ $doctor->name }}
                    </option>
                @endforeach
            </select>
            <select
                name="is_active"
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                onchange="this.form.submit()"
            >
                <option value="">All Status</option>
                <option value="1" {{ request('is_active') === '1' ? 'selected' : '' }}>Active</option>
                <option value="0" {{ request()->has('is_active') && request('is_active') === '0' ? 'selected' : '' }}>Inactive</option>
            </select>
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Filter
            </button>
            @if (request('search') || request('doctor_id') || request()->has('is_active'))
                <a href="{{ route('admin.calendars.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>

        <a href="{{ route('admin.calendars.create') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Map Calendar
        </a>
    </div>

    @if ($unmappedDoctors > 0)
        <div class="bg-amber-50 border border-amber-200 text-amber-700 rounded-lg px-4 py-3 mb-6 text-sm">
            <span class="font-medium">Warning:</span> {{ $unmappedDoctors }} active doctor{{ $unmappedDoctors > 1 ? 's have' : ' has' }} no calendar mapping. Doctors without a calendar mapping cannot accept appointments.
        </div>
    @endif

    @if ($calendars->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No calendars synced yet. Click Sync to fetch from Plato.</p>
            <form method="POST" action="{{ route('admin.calendars.sync') }}" class="inline">
                @csrf
                <button type="submit"
                        class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    Sync Calendars from Plato
                </button>
            </form>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">
                                <a href="{{ route('admin.calendars.index', array_merge(request()->query(), ['sort' => 'name', 'direction' => request('sort') === 'name' && request('direction') === 'asc' ? 'desc' : 'asc'])) }}"
                                   class="inline-flex items-center gap-1 hover:text-[#0F1B3D]">
                                    Calendar
                                    @if (request('sort') === 'name')
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ request('direction') === 'asc' ? 'M5 15l7-7 7 7' : 'M19 9l-7 7-7-7' }}"/>
                                        </svg>
                                    @endif
                                </a>
                            </th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Doctor</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Plato Color ID</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Status</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($calendars as $calendar)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4 font-medium text-[#0F1B3D]">
                                    {{ $calendar->name ?: 'Calendar ' . $calendar->plato_calendar_color_id }}
                                </td>
                                <td class="px-6 py-4 text-gray-500">
                                    @if ($calendar->doctor)
                                        <div class="flex items-center gap-2">
                                            <div class="w-6 h-6 rounded-full bg-[#00C9A7]/10 flex items-center justify-center text-[#00C9A7] text-xs font-bold">
                                                {{ strtoupper(substr($calendar->doctor->name, 0, 2)) }}
                                            </div>
                                            {{ $calendar->doctor->name }}
                                        </div>
                                    @else
                                        <span class="text-gray-400">—</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <code class="text-xs bg-gray-50 text-gray-600 px-2 py-0.5 rounded">{{ $calendar->plato_calendar_color_id }}</code>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium {{ $calendar->is_active ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">
                                        <span class="w-1.5 h-1.5 rounded-full {{ $calendar->is_active ? 'bg-green-500' : 'bg-red-500' }}"></span>
                                        {{ $calendar->is_active ? 'Active' : 'Inactive' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.calendars.show', $calendar) }}"
                                           class="p-1.5 text-gray-400 hover:text-[#0F1B3D] transition-colors"
                                           title="View">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                            </svg>
                                        </a>
                                        <a href="{{ route('admin.calendars.edit', $calendar) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        <form method="POST" action="{{ route('admin.calendars.destroy', $calendar) }}"
                                              onsubmit="return confirm('Are you sure you want to remove this calendar mapping?');"
                                              class="inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit"
                                                    class="p-1.5 text-gray-400 hover:text-red-500 transition-colors"
                                                    title="Delete">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($calendars->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $calendars->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $calendars->firstItem() ?: 0 }}–{{ $calendars->lastItem() ?: 0 }} of {{ $calendars->total() }} calendar mappings
        </p>
    @endif
@endsection
