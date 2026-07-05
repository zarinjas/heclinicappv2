@extends('layouts.admin')

@section('title', 'New Walk-In Appointment')

@section('subtitle', 'Create a walk-in appointment for a patient')

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    var branchSelect = document.getElementById('branch_id');
    var doctorSelect = document.getElementById('doctor_id');
    var branchNameInput = document.getElementById('branch_name');
    var doctorNameInput = document.getElementById('doctor_name');
    var calendarColorInput = document.getElementById('calendar_color_id');
    var allOptions = Array.from(doctorSelect.querySelectorAll('option'));

    if (branchSelect) {
        branchSelect.addEventListener('change', function () {
            var selectedBranchId = this.value;
            var selectedOption = this.options[this.selectedIndex];
            branchNameInput.value = selectedOption ? selectedOption.getAttribute('data-name') || '' : '';

            doctorSelect.innerHTML = '';
            var defaultOpt = document.createElement('option');
            defaultOpt.value = '';
            defaultOpt.textContent = 'Select a doctor';
            doctorSelect.appendChild(defaultOpt);
            doctorNameInput.value = '';
            calendarColorInput.value = '';

            var filtered = allOptions.filter(function (opt) {
                return selectedBranchId === '' || opt.getAttribute('data-branch') === selectedBranchId;
            });

            filtered.forEach(function (opt) {
                doctorSelect.appendChild(opt.cloneNode(true));
            });
        });
    }

    if (doctorSelect) {
        doctorSelect.addEventListener('change', function () {
            var selectedOption = this.options[this.selectedIndex];
            doctorNameInput.value = selectedOption ? selectedOption.getAttribute('data-name') || '' : '';
            calendarColorInput.value = selectedOption ? selectedOption.getAttribute('data-calendar-color') || '' : '';
        });
    }

    var oldBranch = "{{ old('branch_id') }}";
    if (oldBranch && branchSelect) {
        branchSelect.value = oldBranch;
        branchSelect.dispatchEvent(new Event('change'));
        var oldDoctor = "{{ old('doctor_id') }}";
        if (oldDoctor) {
            setTimeout(function () {
                doctorSelect.value = oldDoctor;
                doctorSelect.dispatchEvent(new Event('change'));
            }, 50);
        }
    }
});
</script>
@endpush

@section('content')
    <form method="POST" action="{{ route('admin.appointments.store') }}" class="max-w-2xl">
        @csrf

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <h3 class="text-sm font-semibold text-[#0F1B3D] uppercase tracking-wider mb-4">Patient Information</h3>
                    <div class="space-y-4">
                        <div>
                            <label for="patient_name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Patient Name <span class="text-red-500">*</span></label>
                            <input
                                type="text"
                                name="patient_name"
                                id="patient_name"
                                value="{{ old('patient_name') }}"
                                required
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('patient_name') border-red-300 @enderror"
                                placeholder="Full name as per NRIC"
                            >
                            @error('patient_name')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                            <div>
                                <label for="patient_nric" class="block text-sm font-medium text-[#0F1B3D] mb-1">NRIC <span class="text-red-500">*</span></label>
                                <input
                                    type="text"
                                    name="patient_nric"
                                    id="patient_nric"
                                    value="{{ old('patient_nric') }}"
                                    required
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('patient_nric') border-red-300 @enderror"
                                    placeholder="e.g. 900101-01-1234"
                                >
                                @error('patient_nric')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>

                            <div>
                                <label for="patient_phone" class="block text-sm font-medium text-[#0F1B3D] mb-1">Phone <span class="text-red-500">*</span></label>
                                <input
                                    type="text"
                                    name="patient_phone"
                                    id="patient_phone"
                                    value="{{ old('patient_phone') }}"
                                    required
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('patient_phone') border-red-300 @enderror"
                                    placeholder="e.g. 0123456789"
                                >
                                @error('patient_phone')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>
                        </div>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h3 class="text-sm font-semibold text-[#0F1B3D] uppercase tracking-wider mb-4">Appointment Details</h3>
                    <div class="space-y-4">
                        <div>
                            <label for="branch_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Branch <span class="text-red-500">*</span></label>
                            <select
                                name="branch_id"
                                id="branch_id"
                                required
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white @error('branch_id') border-red-300 @enderror"
                            >
                                <option value="">Select a branch</option>
                                @foreach ($branches as $branch)
                                    <option value="{{ $branch->id }}" data-name="{{ $branch->name }}">{{ $branch->name }}</option>
                                @endforeach
                            </select>
                            @error('branch_id')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div>
                            <label for="doctor_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Doctor <span class="text-red-500">*</span></label>
                            <select
                                name="doctor_id"
                                id="doctor_id"
                                required
                                class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none bg-white @error('doctor_id') border-red-300 @enderror"
                            >
                                <option value="">Select a doctor</option>
                                @foreach ($doctors as $doctor)
                                    <option
                                        value="{{ $doctor->id }}"
                                        data-branch="{{ $doctor->branch_id }}"
                                        data-name="{{ $doctor->name }}"
                                        data-calendar-color="{{ $doctor->platoCalendars->first()?->plato_calendar_color_id ?? '' }}"
                                    >{{ $doctor->name }} @if($doctor->branch) ({{ $doctor->branch->name }}) @endif</option>
                                @endforeach
                            </select>
                            @error('doctor_id')
                                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                            <div>
                                <label for="appointment_date" class="block text-sm font-medium text-[#0F1B3D] mb-1">Appointment Date <span class="text-red-500">*</span></label>
                                <input
                                    type="date"
                                    name="appointment_date"
                                    id="appointment_date"
                                    value="{{ old('appointment_date') }}"
                                    required
                                    min="{{ \Carbon\Carbon::tomorrow()->format('Y-m-d') }}"
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('appointment_date') border-red-300 @enderror"
                                >
                                @error('appointment_date')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>

                            <div>
                                <label for="appointment_time" class="block text-sm font-medium text-[#0F1B3D] mb-1">Appointment Time <span class="text-red-500">*</span></label>
                                <input
                                    type="time"
                                    name="appointment_time"
                                    id="appointment_time"
                                    value="{{ old('appointment_time') }}"
                                    required
                                    class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('appointment_time') border-red-300 @enderror"
                                >
                                @error('appointment_time')
                                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                                @enderror
                            </div>
                        </div>

                        <input type="hidden" name="branch_name" id="branch_name" value="{{ old('branch_name') }}">
                        <input type="hidden" name="doctor_name" id="doctor_name" value="{{ old('doctor_name') }}">
                        <input type="hidden" name="calendar_color_id" id="calendar_color_id" value="{{ old('calendar_color_id') }}">
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h3 class="text-sm font-semibold text-[#0F1B3D] uppercase tracking-wider mb-4">Notes</h3>
                    <div>
                        <label for="notes" class="block text-sm font-medium text-[#0F1B3D] mb-1">Notes</label>
                        <textarea
                            name="notes"
                            id="notes"
                            rows="3"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('notes') border-red-300 @enderror"
                            placeholder="Any additional notes for this appointment..."
                        >{{ old('notes') }}</textarea>
                        @error('notes')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Create Appointment
                </button>
                <a href="{{ route('admin.appointments.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
