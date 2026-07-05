@extends('layouts.admin')

@section('title', 'Map Calendar')

@section('subtitle', 'Link a Plato calendar to a doctor')

@section('content')
    <form method="POST" action="{{ route('admin.calendars.store') }}" class="max-w-2xl">
        @csrf

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="doctor_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Doctor <span class="text-red-500">*</span></label>
                    <select
                        name="doctor_id"
                        id="doctor_id"
                        required
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('doctor_id') border-red-300 @enderror"
                    >
                        <option value="">Select a doctor...</option>
                        @foreach ($doctors as $doctor)
                            <option value="{{ $doctor->id }}" {{ old('doctor_id') == $doctor->id ? 'selected' : '' }}>
                                {{ $doctor->name }}
                            </option>
                        @endforeach
                    </select>
                    @error('doctor_id')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <label for="plato_calendar_color_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Plato Calendar Color ID <span class="text-red-500">*</span></label>
                        <input
                            type="text"
                            name="plato_calendar_color_id"
                            id="plato_calendar_color_id"
                            value="{{ old('plato_calendar_color_id') }}"
                            required
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono @error('plato_calendar_color_id') border-red-300 @enderror"
                            placeholder="e.g. #FF5733 or cal_abc123"
                        >
                        <p class="mt-1 text-xs text-gray-400">The unique color ID from Plato's GET /systemsetup response.</p>
                        @error('plato_calendar_color_id')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Calendar Name</label>
                        <input
                            type="text"
                            name="name"
                            id="name"
                            value="{{ old('name') }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('name') border-red-300 @enderror"
                            placeholder="e.g. Dr. Ahmad Calendar"
                        >
                        <p class="mt-1 text-xs text-gray-400">Optional label for identifying this calendar in the admin panel.</p>
                        @error('name')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label class="inline-flex items-center gap-2 cursor-pointer">
                        <input
                            type="hidden"
                            name="is_active"
                            value="0"
                        >
                        <input
                            type="checkbox"
                            name="is_active"
                            id="is_active"
                            value="1"
                            {{ old('is_active', true) ? 'checked' : '' }}
                            class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                        >
                        <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-400 ml-6">Inactive calendars are excluded from appointment availability checks.</p>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Create Mapping
                </button>
                <a href="{{ route('admin.calendars.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
