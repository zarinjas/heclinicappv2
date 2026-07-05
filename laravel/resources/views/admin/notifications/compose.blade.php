@extends('layouts.admin')

@section('title', 'Compose Notification')

@section('subtitle', 'Create a new push notification')

@section('content')
    <form method="POST" action="{{ route('admin.notifications.send') }}" class="max-w-2xl">
        @csrf

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
                        <label for="target_patient" class="block text-sm font-medium text-[#0F1B3D] mb-1">Patient Name or NRIC</label>
                        <input
                            type="text"
                            name="target_patient"
                            id="target_patient"
                            value="{{ old('target_patient') }}"
                            maxlength="255"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('target_patient') border-red-300 @enderror"
                            placeholder="Enter patient name or NRIC"
                        >
                        @error('target_patient')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
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
    });
</script>
@endpush
