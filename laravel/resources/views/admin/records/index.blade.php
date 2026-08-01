@extends('layouts.admin')

@section('title', 'Records')

@section('subtitle', 'All uploaded patient documents — admin and patient uploads')

@section('content')
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.records.index') }}" class="flex flex-wrap items-center gap-2 flex-1">
            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                placeholder="Search patient name, NRIC or filename..."
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-auto sm:flex-1 max-w-xs"
            >
            <select
                name="source"
                class="px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
            >
                <option value="">All sources</option>
                <option value="patient" {{ request('source') === 'patient' ? 'selected' : '' }}>Patient uploads</option>
                <option value="admin" {{ request('source') === 'admin' ? 'selected' : '' }}>Admin uploads</option>
            </select>
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('search') || request('source'))
                <a href="{{ route('admin.records.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>

        <details class="bg-white rounded-lg border border-gray-200 shadow-sm lg:w-80">
            <summary class="px-4 py-2 text-sm font-medium text-[#0F1B3D] cursor-pointer select-none">
                Notification email settings
            </summary>
            <div class="p-4 border-t border-gray-100">
                <p class="text-xs text-gray-400 mb-2">
                    Default email that receives notifications when a patient uploads a document. Each branch can override this with its own email.
                </p>
                <form method="POST" action="{{ route('admin.records.email.update') }}" class="flex flex-col gap-2">
                    @csrf
                    <input
                        type="email"
                        name="document_upload_admin_email"
                        value="{{ $defaultEmail }}"
                        placeholder="admin@heclinic.com"
                        class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                    >
                    <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                        Save Default Email
                    </button>
                </form>
            </div>
        </details>
    </div>

    @if (count($records) === 0)
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <p class="text-sm text-gray-500">No records found.</p>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Patient</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">NRIC</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">File</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Source</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Title</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Branch</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Uploaded</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($records as $record)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <a href="{{ route('admin.patients.show', $record->patient_plato_uid) }}"
                                       class="font-medium text-[#0F1B3D] hover:text-[#00C9A7] transition-colors">
                                        {{ $record->patient_name ?: 'Unknown' }}
                                    </a>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $record->patient_nric ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-2 max-w-[220px]">
                                        @if (str_starts_with($record->mime_type, 'image/'))
                                            <span class="text-purple-500">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                                </svg>
                                            </span>
                                        @else
                                            <span class="text-red-500">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                                                </svg>
                                            </span>
                                        @endif
                                        <span class="text-gray-700 truncate" title="{{ $record->original_name }}">{{ $record->original_name }}</span>
                                        <span class="text-xs text-gray-400 whitespace-nowrap">{{ $record->size_kb }} KB</span>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    @if ($record->source === 'patient')
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-50 text-blue-600">Patient</span>
                                    @else
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-50 text-green-600">Admin</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-gray-500 max-w-[160px] truncate" title="{{ $record->title }}">{{ $record->title ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $record->branch_name ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ \Carbon\Carbon::parse($record->created_at)->format('d M Y, H:i') }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ $record->url }}"
                                           target="_blank"
                                           class="p-1.5 text-gray-400 hover:text-[#0F1B3D] transition-colors"
                                           title="View">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                            </svg>
                                        </a>
                                        <form action="{{ route('admin.records.destroy', $record->id) }}"
                                              method="POST"
                                              onsubmit="return confirm('Delete this record?')">
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

            @if ($records->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $records->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $records->firstItem() ?: 0 }}–{{ $records->lastItem() ?: 0 }} of {{ $records->total() }} records
        </p>
    @endif
@endsection
