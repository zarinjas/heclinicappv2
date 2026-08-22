@extends('layouts.admin')

@section('title', 'Account #'.$account->id)

@section('subtitle', $account->name)

@section('content')
    @if ($errors->any())
        <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 mb-6 text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-11 h-11 rounded-full bg-[#0F1B3D] text-white flex items-center justify-center font-bold">
                        {{ strtoupper(substr($account->name, 0, 1)) }}
                    </div>
                    <div>
                        <h3 class="font-semibold text-[#0F1B3D]">{{ $account->name }}</h3>
                        <p class="text-xs text-gray-400">Account ID #{{ $account->id }}</p>
                    </div>
                </div>
                <div>
                    @if ($account->idplato)
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-600">
                            <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
                            App Linked
                        </span>
                    @else
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-600">
                            <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                            Not Linked
                        </span>
                    @endif
                </div>
            </div>

            <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 px-6 py-5 text-sm">
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">NRIC / Passport</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->nric ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">NRIC Type</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->nric_type ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Phone</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->telephone ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Email</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->email ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Plato ID</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->idplato ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Apple Sub</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->apple_sub ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Date of Birth</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->dob?->format('d M Y') ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Sex</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->sex ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Nationality</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->nationality ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Referral</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->referred_by ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Signed up</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->created_at?->format('d M Y, h:i A') ?: '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs font-medium text-gray-400 uppercase">Last updated</dt>
                    <dd class="mt-1 text-gray-700">{{ $account->updated_at?->format('d M Y, h:i A') ?: '—' }}</dd>
                </div>
            </dl>
        </div>

        <div class="space-y-6">
            <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
                <h3 class="text-sm font-semibold text-[#0F1B3D] mb-1">Merge account</h3>
                <p class="text-xs text-gray-500 mb-4">
                    Duplicate accounts share the same NRIC, email or phone. Merge them so data and login access land on one account.
                </p>

                @if ($candidates->isEmpty())
                    <p class="text-sm text-gray-500">No other accounts share this account's NRIC, email or phone.</p>
                @else
                    <form method="POST" action="{{ route('admin.app-accounts.merge') }}"
                          onsubmit="return confirm('Merge the selected account into {{ addslashes($account->name) }}? The other account will be soft-deleted and signed out.')">
                        @csrf
                        <input type="hidden" name="primary_id" value="{{ $account->id }}">
                        <label for="merge-in" class="block text-xs font-medium text-gray-600 mb-1.5">
                            Merge this account <span class="text-gray-400">into</span> another (keep the other):
                        </label>
                        <select name="duplicate_id" id="merge-in"
                                class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none mb-2">
                            @foreach ($candidates as $candidate)
                                <option value="{{ $candidate->id }}">
                                    #{{ $candidate->id }} — {{ $candidate->name }} ({{ $candidate->nric ?: 'no IC' }}{{ $candidate->idplato ? ', Linked' : '' }})
                                </option>
                            @endforeach
                        </select>
                        <button type="submit"
                                class="w-full px-4 py-2 text-sm font-medium text-white bg-amber-600 rounded-lg hover:bg-amber-700 transition-colors">
                            Merge into selected account
                        </button>
                    </form>

                    <div class="my-4 flex items-center gap-3 text-xs text-gray-400">
                        <span class="flex-1 h-px bg-gray-100"></span>
                        OR
                        <span class="flex-1 h-px bg-gray-100"></span>
                    </div>

                    <form method="POST" action="{{ route('admin.app-accounts.merge') }}"
                          onsubmit="return confirm('Merge {{ addslashes($account->name) }} into the selected account? This account will be soft-deleted and signed out.')">
                        @csrf
                        <input type="hidden" name="duplicate_id" value="{{ $account->id }}">
                        <label for="merge-out" class="block text-xs font-medium text-gray-600 mb-1.5">
                            Merge another account <span class="text-gray-400">into this one</span> (keep this):
                        </label>
                        <select name="primary_id" id="merge-out"
                                class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none mb-2">
                            @foreach ($candidates as $candidate)
                                <option value="{{ $candidate->id }}">
                                    #{{ $candidate->id }} — {{ $candidate->name }} ({{ $candidate->nric ?: 'no IC' }}{{ $candidate->idplato ? ', Linked' : '' }})
                                </option>
                            @endforeach
                        </select>
                        <button type="submit"
                                class="w-full px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                            Merge into this account
                        </button>
                    </form>
                @endif
            </div>
        </div>
    </div>
@endsection
