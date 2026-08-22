@extends('layouts.admin')

@section('title', 'Compose Notification')

@section('subtitle', 'Create a new notification')

@section('content')
    <form method="POST" action="{{ route('admin.notifications.send') }}" class="max-w-2xl">
        @csrf
        <input type="hidden" name="intent" id="intent" value="draft">

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Title <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="title"
                        id="title"
                        value="{{ old('title') }}"
                        required
                        maxlength="255"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="e.g. New Health Article Available"
                    >
                    <p class="mt-1 text-xs text-gray-400"><span id="title-chars">0</span>/255 characters</p>
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="body" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Body <span class="text-red-500">*</span>
                    </label>
                    <textarea
                        name="body"
                        id="body"
                        rows="6"
                        required
                        maxlength="2000"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('body') border-red-300 @enderror"
                        placeholder="Write your notification message..."
                    >{{ old('body') }}</textarea>
                    <p class="mt-1 text-xs text-gray-400"><span id="body-chars">0</span>/2000 characters</p>
                    @error('body')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="image_url" class="block text-sm font-medium text-[#0F1B3D] mb-1">Image URL</label>
                    <input
                        type="url"
                        name="image_url"
                        id="image_url"
                        value="{{ old('image_url') }}"
                        maxlength="500"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('image_url') border-red-300 @enderror"
                        placeholder="https://example.com/image.jpg"
                    >
                    <p class="mt-1 text-xs text-gray-400">Optional. Provide a valid HTTPS URL for the notification image.</p>
                    @error('image_url')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="border-t border-gray-100 pt-6">
                    <h3 class="text-sm font-semibold text-[#0F1B3D] mb-4">Delivery Channels</h3>

                    <div class="space-y-3">
                        <label class="flex items-center gap-3 cursor-pointer">
                            <input
                                type="checkbox"
                                name="channels[]"
                                value="push"
                                class="rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]"
                                {{ in_array('push', old('channels', ['push', 'email', 'in_app'])) ? 'checked' : '' }}
                            >
                            <span class="text-sm text-gray-700">Push Notification</span>
                        </label>
                        <label class="flex items-center gap-3 cursor-pointer">
                            <input
                                type="checkbox"
                                name="channels[]"
                                value="email"
                                class="rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]"
                                {{ in_array('email', old('channels', ['push', 'email', 'in_app'])) ? 'checked' : '' }}
                            >
                            <span class="text-sm text-gray-700">Email</span>
                        </label>
                        <label class="flex items-center gap-3 cursor-pointer">
                            <input
                                type="checkbox"
                                name="channels[]"
                                value="in_app"
                                class="rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]"
                                {{ in_array('in_app', old('channels', ['push', 'email', 'in_app'])) ? 'checked' : '' }}
                            >
                            <span class="text-sm text-gray-700">In-App Notification</span>
                        </label>
                    </div>

                    @error('channels')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="border-t border-gray-100 pt-6">
                    <h3 class="text-sm font-semibold text-[#0F1B3D] mb-4">Target Audience</h3>

                    <div>
                        <label for="target_type" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Audience <span class="text-red-500">*</span>
                        </label>
                        <select
                            name="target_type"
                            id="target_type"
                            required
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('target_type') border-red-300 @enderror"
                        >
                            <option value="all" {{ old('target_type') === 'all' ? 'selected' : '' }}>All Users</option>
                            <option value="branch" {{ old('target_type') === 'branch' ? 'selected' : '' }}>By Branch</option>
                            <option value="doctor" {{ old('target_type') === 'doctor' ? 'selected' : '' }}>By Doctor</option>
                            <option value="appointment_date_range" {{ old('target_type') === 'appointment_date_range' ? 'selected' : '' }}>By Appointment Date Range</option>
                            <option value="specific_patient" {{ old('target_type') === 'specific_patient' ? 'selected' : '' }}>Specific Patient</option>
                        </select>
                        @error('target_type')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div id="target_branch_section" class="mt-4 hidden">
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-2">Select Branches</label>
                        <div class="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto border border-gray-200 rounded-lg p-3">
                            @foreach($branches as $branch)
                                <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                    <input
                                        type="checkbox"
                                        name="target_ids[]"
                                        value="{{ $branch->id }}"
                                        class="rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]"
                                        {{ in_array($branch->id, old('target_ids', [])) ? 'checked' : '' }}
                                    >
                                    {{ $branch->name }}
                                </label>
                            @endforeach
                        </div>
                        @if($branches->isEmpty())
                            <p class="text-xs text-gray-400">No active branches available.</p>
                        @endif
                    </div>

                    <div id="target_doctor_section" class="mt-4 hidden">
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-2">Select Doctors</label>
                        <div class="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto border border-gray-200 rounded-lg p-3">
                            @foreach($doctors as $doctor)
                                <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                    <input
                                        type="checkbox"
                                        name="target_ids[]"
                                        value="{{ $doctor->id }}"
                                        class="rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]"
                                        {{ in_array($doctor->id, old('target_ids', [])) ? 'checked' : '' }}
                                    >
                                    {{ $doctor->name }}
                                </label>
                            @endforeach
                        </div>
                        @if($doctors->isEmpty())
                            <p class="text-xs text-gray-400">No doctors available.</p>
                        @endif
                    </div>

                    <div id="target_date_range_section" class="mt-4 hidden">
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label for="target_date_from" class="block text-sm font-medium text-[#0F1B3D] mb-1">From</label>
                                <input
                                    type="date"
                                    name="target_date_from"
                                    id="target_date_from"
                                    value="{{ old('target_date_from') }}"
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('target_date_from') border-red-300 @enderror"
                                >
                                @error('target_date_from')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>
                            <div>
                                <label for="target_date_to" class="block text-sm font-medium text-[#0F1B3D] mb-1">To</label>
                                <input
                                    type="date"
                                    name="target_date_to"
                                    id="target_date_to"
                                    value="{{ old('target_date_to') }}"
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('target_date_to') border-red-300 @enderror"
                                >
                                @error('target_date_to')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div id="target_patient_section" class="mt-4 hidden">
                        <label for="patient_search" class="block text-sm font-medium text-[#0F1B3D] mb-1">Search Patient</label>

                        <div class="relative">
                            <input
                                type="text"
                                id="patient_search"
                                autocomplete="off"
                                maxlength="255"
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                                placeholder="Type name, NRIC or phone to search..."
                            >
                            <div id="patient_results" class="hidden absolute z-20 mt-1 w-full max-h-72 overflow-y-auto bg-white border border-gray-200 rounded-lg shadow-lg">
                            </div>
                        </div>

                        {{-- Selected patient is stored here as the Plato _id. --}}
                        <input type="hidden" name="target_patient" id="target_patient" value="{{ old('target_patient') }}">

                        <div id="patient_selected" class="hidden mt-3 flex items-center justify-between bg-[#00C9A7]/10 border border-[#00C9A7]/30 rounded-lg px-4 py-3">
                            <div>
                                <p id="selected_patient_name" class="text-sm font-semibold text-[#0F1B3D]"></p>
                                <p id="selected_patient_meta" class="text-xs text-gray-500"></p>
                            </div>
                            <button type="button" id="patient_clear" class="text-xs font-medium text-gray-500 hover:text-red-500">
                                Clear
                            </button>
                        </div>

                        <p class="mt-1 text-xs text-gray-400">Search for the patient to send this notification to.</p>
                        @error('target_patient')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        onclick="document.getElementById('intent').value='send'"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Send Now
                </button>
                <button type="submit"
                        onclick="document.getElementById('intent').value='draft'"
                        class="px-6 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Save Draft
                </button>
                <a href="{{ route('admin.dashboard') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        function setupCharCount(inputId, countId) {
            const input = document.getElementById(inputId);
            const count = document.getElementById(countId);
            if (input && count) {
                count.textContent = input.value.length;
                input.addEventListener('input', function () {
                    count.textContent = this.value.length;
                });
            }
        }

        setupCharCount('title', 'title-chars');
        setupCharCount('body', 'body-chars');

        const targetTypeSelect = document.getElementById('target_type');
        const branchSection = document.getElementById('target_branch_section');
        const doctorSection = document.getElementById('target_doctor_section');
        const dateRangeSection = document.getElementById('target_date_range_section');
        const patientSection = document.getElementById('target_patient_section');

        function toggleTargetFields() {
            const value = targetTypeSelect.value;
            branchSection.classList.add('hidden');
            doctorSection.classList.add('hidden');
            dateRangeSection.classList.add('hidden');
            patientSection.classList.add('hidden');

            if (value === 'branch') {
                branchSection.classList.remove('hidden');
            } else if (value === 'doctor') {
                doctorSection.classList.remove('hidden');
            } else if (value === 'appointment_date_range') {
                dateRangeSection.classList.remove('hidden');
            } else if (value === 'specific_patient') {
                patientSection.classList.remove('hidden');
            }
        }

        if (targetTypeSelect) {
            targetTypeSelect.addEventListener('change', toggleTargetFields);
            toggleTargetFields();
        }

        // ── Specific-patient autocomplete ─────────────────────────────────────
        const patientSearch = document.getElementById('patient_search');
        const patientResults = document.getElementById('patient_results');
        const patientSelected = document.getElementById('patient_selected');
        const patientNameEl = document.getElementById('selected_patient_name');
        const patientMetaEl = document.getElementById('selected_patient_meta');
        const patientClear = document.getElementById('patient_clear');
        const targetPatient = document.getElementById('target_patient');

        let searchTimer = null;
        let selectedPatient = null;

        function showSelected(patient) {
            selectedPatient = patient;
            targetPatient.value = patient.id;
            patientNameEl.textContent = patient.name || 'Unnamed patient';
            const bits = [];
            if (patient.nric) bits.push(patient.nric);
            if (patient.telephone) bits.push(patient.telephone);
            if (patient.email) bits.push(patient.email);
            patientMetaEl.textContent = bits.join(' · ') || 'No additional details';
            patientSelected.classList.remove('hidden');
            patientSearch.value = '';
            patientSearch.placeholder = patient.name || 'Search patient...';
            patientResults.classList.add('hidden');
            patientResults.innerHTML = '';
        }

        function clearSelected() {
            selectedPatient = null;
            targetPatient.value = '';
            patientSelected.classList.add('hidden');
            patientSearch.value = '';
            patientSearch.placeholder = 'Type name, NRIC or phone to search...';
            patientSearch.focus();
        }

        function renderResults(items) {
            patientResults.innerHTML = '';

            if (!items.length) {
                patientResults.innerHTML =
                    '<div class="px-4 py-3 text-sm text-gray-500">No patients found. ' +
                    'If the patient is not listed, they may not exist in Plato.</div>';
                patientResults.classList.remove('hidden');
                return;
            }

            items.forEach(function (p) {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'w-full text-left px-4 py-3 hover:bg-[#00C9A7]/10 border-b border-gray-100 last:border-0';

                const meta = [p.nric, p.telephone].filter(Boolean).join(' · ');
                const tokenBadge = p.has_token
                    ? '<span class="ml-2 text-[10px] font-medium px-1.5 py-0.5 rounded-full bg-green-100 text-green-700">Push ready</span>'
                    : '';

                btn.innerHTML =
                    '<div class="text-sm font-medium text-[#0F1B3D]">' + escapeHtml(p.name) + tokenBadge + '</div>' +
                    (meta ? '<div class="text-xs text-gray-500">' + escapeHtml(meta) + '</div>' : '');

                btn.addEventListener('click', function () {
                    showSelected(p);
                });

                patientResults.appendChild(btn);
            });

            patientResults.classList.remove('hidden');
        }

        function escapeHtml(value) {
            return String(value ?? '').replace(/[&<>"']/g, function (ch) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch];
            });
        }

        if (patientSearch) {
            patientSearch.addEventListener('input', function () {
                clearTimeout(searchTimer);

                if (selectedPatient) {
                    clearSelected();
                }

                const q = patientSearch.value.trim();
                if (q.length < 2) {
                    patientResults.classList.add('hidden');
                    patientResults.innerHTML = '';
                    return;
                }

                searchTimer = setTimeout(function () {
                    fetch('{{ route('admin.patients.search') }}?q=' + encodeURIComponent(q), {
                        headers: { 'Accept': 'application/json' }
                    })
                    .then(function (res) { return res.json(); })
                    .then(function (items) { renderResults(Array.isArray(items) ? items : []); })
                    .catch(function () {
                        patientResults.innerHTML =
                            '<div class="px-4 py-3 text-sm text-red-500">Search failed. Please try again.</div>';
                        patientResults.classList.remove('hidden');
                    });
                }, 300);
            });

            patientSearch.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    patientResults.classList.add('hidden');
                    patientResults.innerHTML = '';
                }
            });

            patientClear.addEventListener('click', clearSelected);

            document.addEventListener('click', function (e) {
                if (!patientResults.classList.contains('hidden') &&
                    !patientSearch.contains(e.target) &&
                    !patientResults.contains(e.target)) {
                    patientResults.classList.add('hidden');
                    patientResults.innerHTML = '';
                }
            });

            // If the admin typed a value but didn't pick from the dropdown,
            // submit what they typed (keeps old name/NRIC input working).
            const form = patientSearch.closest('form');
            if (form) {
                form.addEventListener('submit', function () {
                    if (!targetPatient.value && patientSearch.value.trim()) {
                        targetPatient.value = patientSearch.value.trim();
                    }
                });
            }
        }
    });
</script>
@endpush
