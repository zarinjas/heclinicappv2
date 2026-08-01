@extends('layouts.admin')

@section('title', 'Users')

@section('subtitle', 'Manage admin panel users and roles')

@section('content')
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <form method="GET" action="{{ route('admin.users.index') }}" class="flex gap-2 flex-1 max-w-md">
            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                placeholder="Search by name or email..."
                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
            >
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                Search
            </button>
            @if (request('search') || request('role'))
                <a href="{{ route('admin.users.index') }}" class="px-4 py-2 text-sm font-medium text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Clear
                </a>
            @endif
        </form>

        <a href="{{ route('admin.users.create') }}"
           class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors whitespace-nowrap">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Add User
        </a>
    </div>

    <div class="flex flex-wrap items-center gap-3 mb-4">
        <a href="{{ route('admin.users.index', request()->except('role')) }}"
           class="px-3 py-1.5 text-xs font-medium rounded-full transition-colors {{ !request('role') ? 'bg-[#00C9A7] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
            All
        </a>
        @foreach (['super_admin' => 'Super Admin', 'branch_admin' => 'Branch Admin', 'staff' => 'Staff'] as $value => $label)
            <a href="{{ route('admin.users.index', array_merge(request()->except('role'), ['role' => $value])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-full transition-colors {{ request('role') === $value ? 'bg-[#00C9A7] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
                {{ $label }}
            </a>
        @endforeach
    </div>

    @if ($users->isEmpty())
        <div class="bg-white rounded-xl border border-gray-100 p-12 text-center shadow-sm">
            <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
            <p class="text-sm text-gray-500 mb-4">No users found.</p>
            <a href="{{ route('admin.users.create') }}"
               class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Add First User
            </a>
        </div>
    @else
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Name</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Email</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Role</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Branch</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Created</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($users as $user)
                            <tr class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="w-9 h-9 rounded-full bg-[#0F1B3D] text-white flex items-center justify-center text-xs font-bold">
                                            {{ strtoupper(substr($user->name, 0, 1)) }}
                                        </div>
                                        <span class="font-medium text-[#0F1B3D]">{{ $user->name }}</span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $user->email }}</td>
                                <td class="px-6 py-4">
                                    @php
                                        $roleStyles = [
                                            'super_admin' => 'bg-purple-50 text-purple-700',
                                            'branch_admin' => 'bg-blue-50 text-blue-700',
                                            'staff' => 'bg-gray-100 text-gray-600',
                                        ];
                                        $roleLabels = [
                                            'super_admin' => 'Super Admin',
                                            'branch_admin' => 'Branch Admin',
                                            'staff' => 'Staff',
                                        ];
                                    @endphp
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {{ $roleStyles[$user->role] ?? 'bg-gray-100 text-gray-600' }}">
                                        {{ $roleLabels[$user->role] ?? ucfirst($user->role) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $user->branch?->name ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $user->created_at?->format('d M Y') ?: '—' }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="{{ route('admin.users.edit', $user) }}"
                                           class="p-1.5 text-gray-400 hover:text-blue-500 transition-colors"
                                           title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                            </svg>
                                        </a>
                                        @if ($user->id !== auth()->id())
                                            <form method="POST" action="{{ route('admin.users.destroy', $user) }}"
                                                  onsubmit="return confirm('Are you sure you want to delete {{ addslashes($user->name) }}?');"
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
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if ($users->hasPages())
                <div class="px-6 py-4 border-t border-gray-100">
                    {{ $users->links() }}
                </div>
            @endif
        </div>

        <p class="text-xs text-gray-400 mt-4">
            Showing {{ $users->firstItem() ?: 0 }}–{{ $users->lastItem() ?: 0 }} of {{ $users->total() }} users
        </p>
    @endif
@endsection
