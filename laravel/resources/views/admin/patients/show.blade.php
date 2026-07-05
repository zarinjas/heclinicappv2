@extends('layouts.admin')

@section('title', $patient['name'] ?? 'Patient Detail')

@section('subtitle', 'Patient record from Plato')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.patients.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Patients
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $patient['name'] ?? 'Unknown' }}</h3>
                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium mt-2 bg-[#00C9A7]/10 text-[#00C9A7]">
                            {{ $patient['givenid'] ?? '—' }}
                        </span>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="{{ route('admin.patients.show', ['patient' => $patient['id'] ?? request()->route('patient'), 'sync' => 1]) }}"
                           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b89a] transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                            </svg>
                            Re-sync from Plato
                        </a>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Personal Info</p>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">NRIC</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['nric'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Date of Birth</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['dob'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Gender</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['gender'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Nationality</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['nationality'] ?? '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Contact</p>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Phone</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['phone'] ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Address</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $patient['address'] ?? '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Medical</p>
                    <dl class="grid grid-cols-1 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Allergies</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if (!empty($patient['allergies']))
                                    @if (is_array($patient['allergies']))
                                        {{ implode(', ', $patient['allergies']) }}
                                    @else
                                        {{ $patient['allergies'] }}
                                    @endif
                                @else
                                    <span class="text-gray-400">None</span>
                                @endif
                            </dd>
                        </div>
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Medical Notes</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if (!empty($patient['medical_notes'] ?? $patient['notes'] ?? null))
                                    {{ $patient['medical_notes'] ?? $patient['notes'] }}
                                @else
                                    <span class="text-gray-400">None</span>
                                @endif
                            </dd>
                        </div>
                    </dl>
                </div>

                <hr class="border-gray-100">

                <div>
                    <p class="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">Vitals</p>
                    <dl class="grid grid-cols-1 gap-6">
                        <div>
                            <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Vital Records</dt>
                            <dd class="mt-1 text-sm text-[#0F1B3D]">
                                @if ($vitalsCount !== null)
                                    <span class="inline-flex items-center gap-1.5">
                                        <span class="w-2 h-2 rounded-full bg-green-500"></span>
                                        {{ $vitalsCount }} vital record{{ $vitalsCount !== 1 ? 's' : '' }} available
                                    </span>
                                @else
                                    <span class="text-gray-400 italic">Unavailable</span>
                                @endif
                            </dd>
                        </div>
                    </dl>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Patient ID: {{ $patient['id'] ?? 'Unknown' }}
                </p>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden mt-6">
            <div class="p-6">
                <h3 class="text-lg font-semibold text-[#0F1B3D] mb-4">Documents</h3>

                <form action="{{ route('admin.patients.documents.upload', request()->route('patient')) }}" method="POST" enctype="multipart/form-data" class="mb-6">
                    @csrf
                    <div class="flex flex-col sm:flex-row items-start gap-3">
                        <div class="flex-1 w-full">
                            <input
                                type="file"
                                name="document"
                                accept=".pdf"
                                required
                                class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7]/10 file:text-[#00C9A7] hover:file:bg-[#00C9A7]/20 file:transition-colors"
                            >
                            @error('document')
                                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <input
                            type="text"
                            name="title"
                            placeholder="Title (optional)"
                            class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none w-full sm:w-48"
                        >
                        @error('title')
                            <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                        @enderror
                        <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors whitespace-nowrap">
                            Upload
                        </button>
                    </div>
                </form>

                @if (count($documents) > 0)
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-gray-50 border-b border-gray-100">
                                    <th class="text-left px-4 py-3 font-medium text-gray-500">Title</th>
                                    <th class="text-left px-4 py-3 font-medium text-gray-500">Filename</th>
                                    <th class="text-left px-4 py-3 font-medium text-gray-500">Size</th>
                                    <th class="text-left px-4 py-3 font-medium text-gray-500">Uploaded</th>
                                    <th class="text-right px-4 py-3 font-medium text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($documents as $doc)
                                    <tr class="border-b border-gray-50">
                                        <td class="px-4 py-3 text-[#0F1B3D]">{{ $doc->title ?? '—' }}</td>
                                        <td class="px-4 py-3 text-gray-500 max-w-[200px] truncate" title="{{ $doc->original_name }}">{{ $doc->original_name }}</td>
                                        <td class="px-4 py-3 text-gray-500">{{ $doc->size_kb }} KB</td>
                                        <td class="px-4 py-3 text-gray-500">{{ \Carbon\Carbon::parse($doc->created_at)->format('d M Y, H:i') }}</td>
                                        <td class="px-4 py-3">
                                            <div class="flex items-center justify-end gap-2">
                                                <a href="{{ $doc->url }}"
                                                   target="_blank"
                                                   class="p-1.5 text-gray-400 hover:text-[#0F1B3D] transition-colors"
                                                   title="Download">
                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                                                    </svg>
                                                </a>
                                                <form action="{{ route('admin.patients.documents.delete', ['patient' => request()->route('patient'), 'filename' => $doc->filename]) }}"
                                                      method="POST"
                                                      onsubmit="return confirm('Delete this document?')">
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
                @else
                    <div class="text-center py-8">
                        <svg class="w-10 h-10 text-gray-300 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                        </svg>
                        <p class="text-sm text-gray-400">No documents uploaded yet</p>
                    </div>
                @endif
            </div>
        </div>
    </div>
@endsection
