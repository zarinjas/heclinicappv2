@extends('layouts.admin')

@section('title', 'Contact & About')

@section('subtitle', 'Contact information and About details shown on the public /contact and /about pages and in the mobile app.')

@section('content')
<div class="max-w-4xl">
    <form method="POST" action="{{ route('admin.settings.contact-info.update') }}" class="space-y-6">
        @csrf

        <!-- Contact Information -->
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">Contact Information</h2>
                <p class="text-xs text-gray-400 mt-1">Shown on the public Contact page (/contact) and in the app's About screen.</p>
            </div>
            <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="col-span-2">
                    <label for="company_name" class="block text-sm font-medium text-[#0F1B3D] mb-1">Company Name <span class="text-red-500">*</span></label>
                    <input type="text" name="company_name" id="company_name" value="{{ old('company_name', $contact['company_name']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('company_name') border-red-300 @enderror">
                    @error('company_name') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label for="support_email" class="block text-sm font-medium text-[#0F1B3D] mb-1">Support Email <span class="text-red-500">*</span></label>
                    <input type="email" name="support_email" id="support_email" value="{{ old('support_email', $contact['support_email']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('support_email') border-red-300 @enderror">
                    @error('support_email') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label for="phone" class="block text-sm font-medium text-[#0F1B3D] mb-1">Phone Number</label>
                    <input type="text" name="phone" id="phone" value="{{ old('phone', $contact['phone']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                           placeholder="+60 11-6720 8860">
                    @error('phone') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label for="website" class="block text-sm font-medium text-[#0F1B3D] mb-1">Website URL</label>
                    <input type="url" name="website" id="website" value="{{ old('website', $contact['website']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                           placeholder="https://hemedicalclinic.com">
                    @error('website') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="col-span-2">
                    <label for="address" class="block text-sm font-medium text-[#0F1B3D] mb-1">Business Address</label>
                    <input type="text" name="address" id="address" value="{{ old('address', $contact['address']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                           placeholder="No. 12, Jalan Pahlawan, 55100 Kuala Lumpur, Malaysia">
                    @error('address') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="col-span-2">
                    <label for="operating_hours" class="block text-sm font-medium text-[#0F1B3D] mb-1">Operating Hours (JSON array)</label>
                    <textarea name="operating_hours" id="operating_hours" rows="4"
                              class="w-full px-4 py-2 text-sm font-mono border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('operating_hours') border-red-300 @enderror">{{ old('operating_hours', $contact['operating_hours']) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">e.g. ["Mon-Fri: 8:00am - 8:00pm","Sat: 9:00am - 1:00pm","Sun & Public Holidays: Closed"]</p>
                    @error('operating_hours') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <!-- About Information -->
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">About Information</h2>
                <p class="text-xs text-gray-400 mt-1">Shown on the public About page (/about) and in the app's About screen. The app name is managed under Branding.</p>
            </div>
            <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="col-span-2">
                    <label for="about_description" class="block text-sm font-medium text-[#0F1B3D] mb-1">App Description</label>
                    <textarea name="about_description" id="about_description" rows="4"
                              class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y @error('about_description') border-red-300 @enderror">{{ old('about_description', $contact['about_description']) }}</textarea>
                    @error('about_description') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label for="app_version" class="block text-sm font-medium text-[#0F1B3D] mb-1">Current App Version</label>
                    <input type="text" name="app_version" id="app_version" value="{{ old('app_version', $contact['app_version']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none"
                           placeholder="1.0.1">
                    <p class="mt-1 text-xs text-gray-400">Shown on the public About page. The mobile app reads its real version from the installed build.</p>
                    @error('app_version') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <button type="submit" class="px-6 py-2.5 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093]">
                Save Settings
            </button>
            <a href="{{ route('contact') }}" target="_blank" rel="noopener" class="px-6 py-2.5 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50">
                View Contact Page
            </a>
            <a href="{{ route('about') }}" target="_blank" rel="noopener" class="px-6 py-2.5 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50">
                View About Page
            </a>
        </div>
    </form>
</div>
@endsection
