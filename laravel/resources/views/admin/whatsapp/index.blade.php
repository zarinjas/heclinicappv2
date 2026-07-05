@extends('layouts.admin')

@section('title', 'WhatsApp Center')

@section('subtitle', 'Send WhatsApp messages to patients')

@section('content')
    @if (session('send_results'))
        <div class="mb-6 bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-6">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-10 h-10 rounded-full bg-[#00C9A7]/10 flex items-center justify-center">
                        <svg class="w-5 h-5 text-[#00C9A7]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                        </svg>
                    </div>
                    <div>
                        <h3 class="text-sm font-semibold text-[#0F1B3D]">Send Results — {{ session('send_results.branch_name') }}</h3>
                        <p class="text-xs text-gray-500">
                            {{ session('send_results.total') }} total &middot;
                            <span class="text-green-600 font-medium">{{ session('send_results.success') }} sent</span>
                            @if(session('send_results.failed') > 0)
                                &middot; <span class="text-red-500 font-medium">{{ session('send_results.failed') }} failed</span>
                            @endif
                        </p>
                    </div>
                </div>

                <div class="max-h-64 overflow-y-auto border border-gray-100 rounded-lg">
                    <table class="w-full text-sm">
                        <thead class="bg-gray-50 text-xs text-gray-500 uppercase">
                            <tr>
                                <th class="px-4 py-2 text-left">Recipient</th>
                                <th class="px-4 py-2 text-left">Phone</th>
                                <th class="px-4 py-2 text-left">Status</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            @foreach(session('send_results.results') as $result)
                                <tr>
                                    <td class="px-4 py-2 text-gray-700">{{ $result['name'] }}</td>
                                    <td class="px-4 py-2 text-gray-500 font-mono text-xs">{{ $result['phone'] }}</td>
                                    <td class="px-4 py-2">
                                        @if($result['status'] === 'sent')
                                            <span class="inline-flex items-center gap-1 text-xs font-medium text-green-700 bg-green-50 px-2 py-0.5 rounded-full">
                                                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                                                Sent
                                            </span>
                                        @else
                                            <span class="inline-flex items-center gap-1 text-xs font-medium text-red-700 bg-red-50 px-2 py-0.5 rounded-full"
                                                  title="{{ $result['error'] ?? 'Unknown error' }}">
                                                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/></svg>
                                                Failed
                                            </span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    @endif

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2">
            <form method="POST" action="{{ route('admin.whatsapp.send') }}" id="whatsapp-form">
                @csrf
                <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
                    <div class="p-6 space-y-6">
                        <div>
                            <label for="branch_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                                Branch <span class="text-red-500">*</span>
                            </label>
                            <select
                                name="branch_id"
                                id="branch_id"
                                required
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('branch_id') border-red-300 @enderror"
                            >
                                <option value="">— Select Branch —</option>
                                @foreach($branches as $branch)
                                    <option value="{{ $branch->id }}"
                                            data-whatsapp="{{ $branch->whatsapp_number }}"
                                            {{ old('branch_id') == $branch->id ? 'selected' : '' }}>
                                        {{ $branch->name }}
                                    </option>
                                @endforeach
                            </select>
                            <p id="branch-whatsapp-hint" class="mt-1 text-xs text-gray-400 hidden">
                                WhatsApp: <span id="branch-whatsapp-number"></span>
                            </p>
                            @error('branch_id')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div>
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm font-medium text-[#0F1B3D]">Send Mode <span class="text-red-500">*</span></span>
                            </div>
                            <div class="flex gap-3">
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="radio" name="send_mode" value="single"
                                           class="text-[#00C9A7] focus:ring-[#00C9A7]"
                                           checked>
                                    <span class="text-sm text-gray-700">Single Patient</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="radio" name="send_mode" value="bulk"
                                           class="text-[#00C9A7] focus:ring-[#00C9A7]">
                                    <span class="text-sm text-gray-700">Bulk (All Patients in Branch)</span>
                                </label>
                            </div>
                            @error('send_mode')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div id="single-patient-section">
                            <label for="recipient_phone" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                                Patient Phone Number <span class="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="recipient_phone"
                                id="recipient_phone"
                                value="{{ old('recipient_phone') }}"
                                maxlength="20"
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('recipient_phone') border-red-300 @enderror"
                                placeholder="e.g. +60123456789"
                            >
                            @error('recipient_phone')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror

                            <label for="recipient_name" class="block text-sm font-medium text-[#0F1B3D] mb-1 mt-3">Patient Name</label>
                            <input
                                type="text"
                                name="recipient_name"
                                id="recipient_name"
                                value="{{ old('recipient_name') }}"
                                maxlength="255"
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                                placeholder="Optional — for your reference"
                            >
                        </div>

                        <div id="bulk-patient-section" class="hidden">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm font-medium text-[#0F1B3D]">Patient List</span>
                                <button type="button" id="fetch-patients-btn"
                                        class="text-xs text-[#00C9A7] hover:text-[#00b093] font-medium flex items-center gap-1"
                                        onclick="fetchPatients()">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                                    </svg>
                                    Fetch Patients
                                </button>
                            </div>
                            <div id="patient-list-container" class="border border-gray-200 rounded-lg p-3 max-h-64 overflow-y-auto">
                                <p class="text-sm text-gray-400 text-center py-4" id="patient-list-empty">
                                    Select a branch and click "Fetch Patients" to load the patient list.
                                </p>
                                <div id="patient-list" class="space-y-2 hidden">
                                </div>
                            </div>
                            <div class="mt-2 flex items-center gap-2">
                                <button type="button" id="select-all-patients"
                                        class="text-xs text-[#00C9A7] hover:text-[#00b093] font-medium"
                                        onclick="toggleSelectAll()">
                                    Select All
                                </button>
                                <span class="text-xs text-gray-300">|</span>
                                <button type="button" id="deselect-all-patients"
                                        class="text-xs text-gray-400 hover:text-gray-600 font-medium"
                                        onclick="toggleSelectAll()">
                                    Deselect All
                                </button>
                            </div>
                            @error('patients')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div>
                            <label for="message" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                                Message <span class="text-red-500">*</span>
                            </label>
                            <textarea
                                name="message"
                                id="message"
                                rows="5"
                                required
                                maxlength="4096"
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('message') border-red-300 @enderror"
                                placeholder="Type your WhatsApp message here..."
                            >{{ old('message') }}</textarea>
                            <p class="mt-1 text-xs text-gray-400"><span id="message-chars">0</span>/4096 characters</p>
                            @error('message')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>

                    <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                        <button type="submit"
                                class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors flex items-center gap-2"
                                id="submit-btn">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>
                            </svg>
                            Send WhatsApp
                        </button>
                        <a href="{{ route('admin.dashboard') }}"
                           class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                            Cancel
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <div class="lg:col-span-1">
            <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-6 sticky top-8">
                <h3 class="text-sm font-semibold text-[#0F1B3D] mb-3">Tips</h3>
                <ul class="space-y-3 text-sm text-gray-500">
                    <li class="flex gap-2">
                        <span class="text-[#00C9A7] font-bold mt-0.5">1</span>
                        <span>Select a branch with a valid WhatsApp number first.</span>
                    </li>
                    <li class="flex gap-2">
                        <span class="text-[#00C9A7] font-bold mt-0.5">2</span>
                        <span>Use <strong>Single</strong> mode to message a specific patient.</span>
                    </li>
                    <li class="flex gap-2">
                        <span class="text-[#00C9A7] font-bold mt-0.5">3</span>
                        <span>Use <strong>Bulk</strong> mode to message all patients in a branch at once.</span>
                    </li>
                    <li class="flex gap-2">
                        <span class="text-[#00C9A7] font-bold mt-0.5">4</span>
                        <span>Messages are sent through Plato's WhatsApp integration.</span>
                    </li>
                    <li class="flex gap-2">
                        <span class="text-[#00C9A7] font-bold mt-0.5">5</span>
                        <span>Patient phone numbers must be in the Plato database.</span>
                    </li>
                </ul>

                <div class="mt-4 p-3 bg-amber-50 border border-amber-100 rounded-lg">
                    <p class="text-xs text-amber-700">
                        <strong>Note:</strong> Only branches with a configured WhatsApp number are listed. Set up branch WhatsApp numbers in <a href="{{ route('admin.branches.index') }}" class="underline text-[#00C9A7]">Branch Management</a>.
                    </p>
                </div>

                @if($branches->isEmpty())
                    <div class="mt-4 p-3 bg-red-50 border border-red-100 rounded-lg">
                        <p class="text-xs text-red-600">
                            No branches with WhatsApp numbers configured. Please configure a branch first.
                        </p>
                    </div>
                @endif
            </div>
        </div>
    </div>
@endsection

@push('scripts')
<script>
    let allPatients = [];
    let allSelected = false;

    document.addEventListener('DOMContentLoaded', function () {
        const branchSelect = document.getElementById('branch_id');
        const whatsappHint = document.getElementById('branch-whatsapp-hint');
        const whatsappNumber = document.getElementById('branch-whatsapp-number');

        if (branchSelect) {
            branchSelect.addEventListener('change', function () {
                const selected = this.options[this.selectedIndex];
                const wa = selected.dataset.whatsapp;
                if (wa) {
                    whatsappHint.classList.remove('hidden');
                    whatsappNumber.textContent = wa;
                } else {
                    whatsappHint.classList.add('hidden');
                }
                resetPatientList();
            });

            if (branchSelect.value) {
                branchSelect.dispatchEvent(new Event('change'));
            }
        }

        const singleRadio = document.querySelector('input[name="send_mode"][value="single"]');
        const bulkRadio = document.querySelector('input[name="send_mode"][value="bulk"]');
        const singleSection = document.getElementById('single-patient-section');
        const bulkSection = document.getElementById('bulk-patient-section');

        function toggleMode() {
            if (bulkRadio.checked) {
                singleSection.classList.add('hidden');
                bulkSection.classList.remove('hidden');
            } else {
                singleSection.classList.remove('hidden');
                bulkSection.classList.add('hidden');
            }
        }

        if (singleRadio && bulkRadio) {
            singleRadio.addEventListener('change', toggleMode);
            bulkRadio.addEventListener('change', toggleMode);
            toggleMode();
        }

        const messageTextarea = document.getElementById('message');
        const messageChars = document.getElementById('message-chars');
        if (messageTextarea && messageChars) {
            messageChars.textContent = messageTextarea.value.length;
            messageTextarea.addEventListener('input', function () {
                messageChars.textContent = this.value.length;
            });
        }
    });

    function resetPatientList() {
        allPatients = [];
        allSelected = false;
        document.getElementById('patient-list').classList.add('hidden');
        document.getElementById('patient-list').innerHTML = '';
        document.getElementById('patient-list-empty').classList.remove('hidden');
    }

    function fetchPatients() {
        const branchId = document.getElementById('branch_id').value;
        if (!branchId) {
            alert('Please select a branch first.');
            return;
        }

        const btn = document.getElementById('fetch-patients-btn');
        const listContainer = document.getElementById('patient-list');
        const emptyMsg = document.getElementById('patient-list-empty');

        btn.textContent = 'Loading...';
        btn.disabled = true;

        fetch('{{ route("admin.whatsapp.fetch-patients") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json',
            },
            body: JSON.stringify({ branch_id: branchId }),
        })
        .then(response => response.json())
        .then(data => {
            btn.textContent = 'Refresh Patients';
            btn.disabled = false;
            allPatients = data.patients || [];
            allSelected = false;

            if (allPatients.length === 0) {
                emptyMsg.textContent = 'No patients found for this branch.';
                emptyMsg.classList.remove('hidden');
                listContainer.classList.add('hidden');
                listContainer.innerHTML = '';
                return;
            }

            emptyMsg.classList.add('hidden');
            listContainer.classList.remove('hidden');
            listContainer.innerHTML = allPatients.map((p, i) => `
                <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer py-1">
                    <input type="checkbox" name="patients[${i}][phone]" value="${p.phone}"
                           class="patient-checkbox rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]">
                    <input type="hidden" name="patients[${i}][name]" value="${p.name}">
                    <span>${p.name}</span>
                    <span class="text-xs text-gray-400 font-mono ml-auto">${p.phone}</span>
                </label>
            `).join('');
        })
        .catch(error => {
            btn.textContent = 'Fetch Patients';
            btn.disabled = false;
            console.error('Error fetching patients:', error);
            alert('Failed to fetch patients. Please try again.');
        });
    }

    function toggleSelectAll() {
        allSelected = !allSelected;
        document.querySelectorAll('.patient-checkbox').forEach(cb => {
            cb.checked = allSelected;
        });
    }
</script>
@endpush
