@extends('layouts.admin')

@section('title', 'Edit Doctor')

@section('subtitle', $doctor->name)

@section('content')
    <form method="POST" action="{{ route('admin.doctors.update', $doctor) }}" enctype="multipart/form-data" class="max-w-2xl">
        @csrf
        @method('PUT')

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Doctor Name <span class="text-red-500">*</span></label>
                    <input
                        type="text"
                        name="name"
                        id="name"
                        value="{{ old('name', $doctor->name) }}"
                        required
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('name') border-red-300 @enderror"
                    >
                    @error('name')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <label for="specialty" class="block text-sm font-medium text-[#0F1B3D] mb-1">Specialty</label>
                        <input
                            type="text"
                            name="specialty"
                            id="specialty"
                            value="{{ old('specialty', $doctor->specialty) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('specialty') border-red-300 @enderror"
                        >
                        @error('specialty')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="branch_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Branch <span class="text-red-500">*</span></label>
                        <select
                            name="branch_id"
                            id="branch_id"
                            required
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('branch_id') border-red-300 @enderror"
                        >
                            <option value="">Select a branch...</option>
                            @foreach ($branches as $branch)
                                <option value="{{ $branch->id }}" {{ old('branch_id', $doctor->branch_id) == $branch->id ? 'selected' : '' }}>
                                    {{ $branch->name }}
                                </option>
                            @endforeach
                        </select>
                        @error('branch_id')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <label for="plato_facility_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Plato Facility ID</label>
                        <input
                            type="text"
                            name="plato_facility_id"
                            id="plato_facility_id"
                            value="{{ old('plato_facility_id', $doctor->plato_facility_id) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('plato_facility_id') border-red-300 @enderror"
                        >
                        @error('plato_facility_id')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="photo" class="block text-sm font-medium text-[#0F1B3D] mb-1">Photo</label>
                        <input
                            type="file"
                            name="photo"
                            id="photo"
                            accept="image/jpeg,image/png,image/webp"
                            class="w-full px-4 py-2 text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7]/10 file:text-[#00C9A7] hover:file:bg-[#00C9A7]/20 file:cursor-pointer border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('photo') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Max 2MB. JPG, JPEG, PNG, or WebP. Leave empty to keep current photo.</p>
                        @if ($doctor->photo)
                            <div class="mt-3 flex items-center gap-3">
                                <img src="{{ Storage::disk('public')->url($doctor->photo) }}" alt="Current photo" class="w-16 h-16 rounded-lg object-cover border border-gray-200">
                                <span class="text-xs text-gray-400">Current photo</span>
                            </div>
                        @endif
                        @error('photo')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label for="bio" class="block text-sm font-medium text-[#0F1B3D] mb-1">Bio</label>
                    <textarea
                        name="bio"
                        id="bio"
                        rows="4"
                        maxlength="500"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('bio') border-red-300 @enderror"
                        placeholder="Brief biography or professional background..."
                    >{{ old('bio', $doctor->bio) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400"><span id="bio-chars">0</span>/500 characters</p>
                    @error('bio')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="space-y-4">
                    <div>
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input
                                type="hidden"
                                name="is_visible_in_app"
                                value="0"
                            >
                            <input
                                type="checkbox"
                                name="is_visible_in_app"
                                id="is_visible_in_app"
                                value="1"
                                {{ old('is_visible_in_app', $doctor->is_visible_in_app) ? 'checked' : '' }}
                                class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                            >
                            <span class="text-sm font-medium text-[#0F1B3D]">Visible in Mobile App</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400 ml-6">When checked, this doctor appears in the mobile app booking flow.</p>
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
                                {{ old('is_active', $doctor->is_active) ? 'checked' : '' }}
                                class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                            >
                            <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400 ml-6">Inactive doctors are hidden from all views including admin listings.</p>
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Save Changes
                </button>
                <a href="{{ route('admin.doctors.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection

@section('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const bioField = document.getElementById('bio');
        const charCount = document.getElementById('bio-chars');
        if (bioField && charCount) {
            charCount.textContent = bioField.value.length;
            bioField.addEventListener('input', function () {
                charCount.textContent = this.value.length;
            });
        }
    });
</script>
@endsection
