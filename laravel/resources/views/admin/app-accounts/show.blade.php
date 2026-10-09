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

    <div class="mt-6 bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between gap-4">
            <div>
                <h3 class="text-sm font-semibold text-[#0F1B3D]">Plato records for this patient</h3>
                <p class="text-xs text-gray-500 mt-1">
                    Plato may hold more than one record for the same person. The app reads only the
                    record it is linked to, so letters/MC uploaded to the other record will not appear.
                    Relinking points the app at the record that actually has the data.
                    <span class="font-medium text-amber-600">This does not merge Plato data</span> —
                    ask the clinic to merge duplicate records inside Plato for a permanent fix.
                </p>
            </div>
            @if ($platoRecords !== null)
                <a href="{{ route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]) }}"
                   class="shrink-0 px-3 py-1.5 text-xs font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    Refresh
                </a>
            @endif
        </div>

        @if ($platoRecords === null)
            <div class="px-6 py-6">
                <a href="{{ route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]) }}"
                   class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-[#0F1B3D] rounded-lg hover:bg-[#1e2d52] transition-colors">
                    Find Plato records
                </a>
                <p class="text-xs text-gray-400 mt-2">
                    Makes a live lookup against Plato for this account's NRIC or phone.
                </p>
            </div>
        @elseif ($platoRecords['error'])
            <div class="px-6 py-6">
                <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm">
                    {{ $platoRecords['error'] }}
                </div>
            </div>
        @elseif (count($platoRecords['records']) === 0)
            <div class="px-6 py-6">
                <p class="text-sm text-gray-500">No Plato records matched this account's identifier.</p>
            </div>
        @else
            <div class="px-6 py-4 text-xs text-gray-400 border-b border-gray-50">
                Searched Plato by
                <span class="font-medium text-gray-600">{{ implode(', ', array_keys($platoRecords['identifier'])) }}</span>
                = <span class="font-medium text-gray-600">{{ implode(', ', array_values($platoRecords['identifier'])) }}</span>
                · {{ count($platoRecords['records']) }} record(s) found
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Plato ID</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Name</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">NRIC</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Phone</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Created</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Letters</th>
                            <th class="text-left px-6 py-3 font-medium text-gray-500">Docs</th>
                            <th class="text-right px-6 py-3 font-medium text-gray-500">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($platoRecords['records'] as $record)
                            @php
                                $isCurrent = $record['plato_id'] === $account->idplato;
                                $linkedElsewhere = ! $isCurrent
                                    && $record['linked_account_id'] !== null
                                    && $record['linked_account_id'] !== $account->id;
                            @endphp
                            <tr class="border-b border-gray-50">
                                <td class="px-6 py-4 font-mono text-xs text-gray-500">{{ $record['plato_id'] }}</td>
                                <td class="px-6 py-4 text-[#0F1B3D]">{{ $record['name'] ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $record['nric'] ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">{{ $record['telephone'] ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500 whitespace-nowrap">{{ $record['created_on'] ?: '—' }}</td>
                                <td class="px-6 py-4 text-gray-500">
                                    {{ $record['letters'] === null ? '—' : $record['letters'].($record['letters'] >= 20 ? '+' : '') }}
                                </td>
                                <td class="px-6 py-4 text-gray-500">{{ $record['documents'] }}</td>
                                <td class="px-6 py-4 text-right">
                                    @if ($isCurrent)
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-600">
                                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                            Current
                                        </span>
                                    @elseif ($linkedElsewhere)
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-600">
                                            Linked to #{{ $record['linked_account_id'] }}
                                        </span>
                                        <p class="text-xs text-gray-400 mt-1">Merge that account first</p>
                                    @else
                                        <form method="POST" action="{{ route('admin.app-accounts.relink', $account) }}"
                                              onsubmit="return confirm('Point this account at Plato record {{ $record['plato_id'] }}? The app will read this record\'s letters and medical certificates.')">
                                            @csrf
                                            <input type="hidden" name="plato_id" value="{{ $record['plato_id'] }}">
                                            <button type="submit"
                                                    class="px-3 py-1.5 text-xs font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b395] transition-colors">
                                                Use this record
                                            </button>
                                        </form>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if (count($platoRecords['records']) >= 2)
                <div class="border-t border-gray-100 px-6 py-6 bg-red-50/40">
                    <div class="flex items-start gap-3">
                        <svg class="w-5 h-5 text-red-600 mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                        </svg>
                        <div class="flex-1">
                            <h4 class="text-sm font-semibold text-red-700">Merge Plato records</h4>
                            <p class="text-xs text-gray-600 mt-1">
                                Permanently combines two Plato records into one, moving the letters and medical
                                certificates onto the surviving record.
                                <span class="font-semibold text-red-700">This cannot be undone</span> and changes
                                the clinic's clinical records, so confirm the API field contract with Plato first.
                            </p>

                            @if (! $mergeEnabled)
                                <div class="mt-3 bg-amber-50 border border-amber-200 text-amber-700 rounded-lg px-4 py-3 text-xs">
                                    Plato merge is currently disabled. Set
                                    <code class="font-mono">PLATO_MERGE_ENABLED=true</code> on the server and
                                    re-open this page to enable the button.
                                </div>
                            @endif

                            <form method="POST" action="{{ route('admin.app-accounts.merge-plato', $account) }}"
                                  class="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-4"
                                  onsubmit="return confirm('Merge the duplicate Plato record into the surviving one? THIS CANNOT BE UNDONE.')">
                                @csrf
                                <div>
                                    <label class="block text-xs font-medium text-gray-600 mb-1.5">Keep (surviving record)</label>
                                    <select name="survivor_id"
                                            class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                                        @foreach ($platoRecords['records'] as $record)
                                            <option value="{{ $record['plato_id'] }}" {{ $record['plato_id'] === $account->idplato ? 'selected' : '' }}>
                                                {{ $record['plato_id'] }} — {{ $record['name'] ?: 'no name' }} ({{ $record['letters'] === null ? '?' : $record['letters'] }}{{ $record['letters'] !== null && $record['letters'] >= 20 ? '+' : '' }} letters)
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-xs font-medium text-gray-600 mb-1.5">Merge in (record to remove)</label>
                                    <select name="merged_id"
                                            class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                                        @foreach ($platoRecords['records'] as $record)
                                            @continue($record['plato_id'] === $account->idplato)
                                            <option value="{{ $record['plato_id'] }}">
                                                {{ $record['plato_id'] }} — {{ $record['name'] ?: 'no name' }} ({{ $record['letters'] === null ? '?' : $record['letters'] }}{{ $record['letters'] !== null && $record['letters'] >= 20 ? '+' : '' }} letters)
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="sm:col-span-2">
                                    <label class="block text-xs font-medium text-gray-600 mb-1.5">
                                        Type the phrase below to confirm
                                    </label>
                                    <input type="text" name="acknowledge" required
                                           placeholder="{{ $mergePhrase }}"
                                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-red-400 focus:border-transparent outline-none font-mono">
                                    <p class="text-xs text-gray-400 mt-1">Required phrase: <span class="font-mono text-gray-600">{{ $mergePhrase }}</span></p>
                                </div>
                                <div class="sm:col-span-2">
                                    <button type="submit" @disabled(! $mergeEnabled)
                                            class="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-lg hover:bg-red-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
                                        Merge Plato records
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            @endif
        @endif
    </div>
@endsection
