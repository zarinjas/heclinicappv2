@extends('layouts.admin')

@section('title', $branch->name)

@section('subtitle', 'Branch details')

@section('content')
    <div class="max-w-2xl">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.branches.index') }}"
               class="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-[#0F1B3D] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Branches
            </a>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6 space-y-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-[#0F1B3D]">{{ $branch->name }}</h3>
                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium mt-2 {{ $branch->is_active ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-500' }}">
                            <span class="w-1.5 h-1.5 rounded-full {{ $branch->is_active ? 'bg-green-500' : 'bg-gray-400' }}"></span>
                            {{ $branch->is_active ? 'Active' : 'Inactive' }}
                        </span>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="{{ route('admin.branches.edit', $branch) }}"
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
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Address</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branch->address ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Phone</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branch->phone ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">WhatsApp Number</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branch->whatsapp_number ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Plato Facility ID</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branch->plato_facility_id ?: '—' }}</dd>
                    </div>

                    <div class="sm:col-span-2">
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Operating Hours</dt>
                        <dd class="mt-1 text-sm text-[#0F1B3D]">{{ $branch->operating_hours ?: '—' }}</dd>
                    </div>

                    <div>
                        <dt class="text-xs font-medium text-gray-400 uppercase tracking-wider">Image</dt>
                        <dd class="mt-1 text-sm">
                            @if ($branch->image)
                                <a href="{{ $branch->image }}" target="_blank" class="text-[#00C9A7] hover:underline break-all">{{ $branch->image }}</a>
                            @else
                                <span class="text-gray-400">—</span>
                            @endif
                        </dd>
                    </div>
                </dl>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <p class="text-xs text-gray-400">
                    Created {{ $branch->created_at->format('d M Y, h:i A') }}
                    @if ($branch->updated_at->ne($branch->created_at))
                        &middot; Updated {{ $branch->updated_at->format('d M Y, h:i A') }}
                    @endif
                </p>
            </div>
        </div>
    </div>
@endsection
