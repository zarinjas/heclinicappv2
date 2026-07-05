@extends('layouts.admin')

@section('title', 'Edit Branch')

@section('subtitle', $branch->name)

@section('content')
    <form method="POST" action="{{ route('admin.branches.update', $branch) }}" enctype="multipart/form-data" class="max-w-2xl">
        @csrf
        @method('PUT')

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Branch Name <span class="text-red-500">*</span></label>
                    <input
                        type="text"
                        name="name"
                        id="name"
                        value="{{ old('name', $branch->name) }}"
                        required
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('name') border-red-300 @enderror"
                    >
                    @error('name')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="address" class="block text-sm font-medium text-[#0F1B3D] mb-1">Address</label>
                    <textarea
                        name="address"
                        id="address"
                        rows="3"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('address') border-red-300 @enderror"
                    >{{ old('address', $branch->address) }}</textarea>
                    @error('address')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <label for="phone" class="block text-sm font-medium text-[#0F1B3D] mb-1">Phone Number</label>
                        <input
                            type="text"
                            name="phone"
                            id="phone"
                            value="{{ old('phone', $branch->phone) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('phone') border-red-300 @enderror"
                        >
                        @error('phone')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="whatsapp_number" class="block text-sm font-medium text-[#0F1B3D] mb-1">WhatsApp Number</label>
                        <input
                            type="text"
                            name="whatsapp_number"
                            id="whatsapp_number"
                            value="{{ old('whatsapp_number', $branch->whatsapp_number) }}"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('whatsapp_number') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Must start with +60 for Malaysia. Used in booking WhatsApp redirect.</p>
                        @error('whatsapp_number')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label for="google_maps_link" class="block text-sm font-medium text-[#0F1B3D] mb-1">Google Maps Link</label>
                    <input
                        type="url"
                        name="google_maps_link"
                        id="google_maps_link"
                        value="{{ old('google_maps_link', $branch->google_maps_link) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('google_maps_link') border-red-300 @enderror"
                        placeholder="https://maps.google.com/?q=..."
                    >
                    <p class="mt-1 text-xs text-gray-400">URL to Google Maps location. Used for "Get Directions" in the mobile app.</p>
                    @error('google_maps_link')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="image" class="block text-sm font-medium text-[#0F1B3D] mb-1">Branch Photo</label>
                    <input
                        type="file"
                        name="image"
                        id="image"
                        accept="image/jpeg,image/png,image/webp"
                        class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b093] file:cursor-pointer @error('image') border-red-300 @enderror"
                    >
                    <p class="mt-1 text-xs text-gray-400">Max 5MB. JPEG, PNG, or WebP. Leave empty to keep current photo.</p>
                    @if ($branch->image)
                        <div class="mt-3 flex items-center gap-3">
                            <img src="{{ Storage::disk('public')->url($branch->image) }}" alt="Current photo" class="w-16 h-16 rounded-lg object-cover border border-gray-200">
                            <span class="text-xs text-gray-400">Current photo</span>
                        </div>
                    @endif
                    @error('image')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="operating_hours" class="block text-sm font-medium text-[#0F1B3D] mb-1">Operating Hours</label>
                    <textarea
                        name="operating_hours"
                        id="operating_hours"
                        rows="4"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('operating_hours') border-red-300 @enderror"
                    >{{ old('operating_hours', is_array($branch->operating_hours) ? implode("\n", $branch->operating_hours) : $branch->operating_hours) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">Enter operating hours as plain text.</p>
                    @error('operating_hours')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="plato_facility_id" class="block text-sm font-medium text-[#0F1B3D] mb-1">Plato Facility ID</label>
                    <input
                        type="text"
                        name="plato_facility_id"
                        id="plato_facility_id"
                        value="{{ old('plato_facility_id', $branch->plato_facility_id) }}"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('plato_facility_id') border-red-300 @enderror"
                    >
                    @error('plato_facility_id')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
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
                            {{ old('is_active', $branch->is_active) ? 'checked' : '' }}
                            class="w-4 h-4 text-[#00C9A7] border-gray-300 rounded focus:ring-[#00C9A7]"
                        >
                        <span class="text-sm font-medium text-[#0F1B3D]">Active</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-400 ml-6">Inactive branches are hidden from the mobile app branch selector.</p>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Save Changes
                </button>
                <a href="{{ route('admin.branches.index') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection
