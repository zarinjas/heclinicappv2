@extends('layouts.admin')

@section('title', 'Branding')

@section('content')
<div class="max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold text-[#0F1B3D]">Branding Settings</h1>
    <p class="text-sm text-gray-500 mt-1">Customize the clinic's mobile app branding.</p>

    @if(session('success'))
        <div class="mt-4 p-4 bg-green-100 text-green-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    <form method="POST" action="{{ route('admin.branding.update') }}" enctype="multipart/form-data" class="mt-6 space-y-8">
        @csrf

        {{-- Identity --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-4">App Identity</h2>
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">App Name</label>
                    <input type="text" name="app_name" value="{{ old('app_name', $branding['app_name']) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                    @error('app_name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Short Name (max 10 chars)</label>
                    <input type="text" name="app_short_name" value="{{ old('app_short_name', $branding['app_short_name']) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                    @error('app_short_name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
                <div class="col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Tagline</label>
                    <input type="text" name="tagline" value="{{ old('tagline', $branding['tagline']) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Primary Color (hex)</label>
                    <input type="color" name="primary_color" value="{{ old('primary_color', $branding['primary_color']) }}"
                           class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Splash Background Color</label>
                    <input type="color" name="splash_bg_color" value="{{ old('splash_bg_color', $branding['splash_bg_color'] ?? '#131C3C') }}"
                           class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                    <p class="text-xs text-gray-500 mt-1">Background color for the splash screen (supports GIF animation)</p>
                </div>
            </div>
        </div>

        {{-- Logo Uploads --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-4">App Logos</h2>
            <p class="text-sm text-gray-500 mb-4">Upload PNG or SVG logos. Recommended size: 512×512px.</p>
            <div class="space-y-4">
                @php
                    $logoFields = [
                        'logo' => ['label' => 'App Logo', 'desc' => 'Main app logo used on every screen',
                                    'url' => $branding['logo_url'] ?? null],
                        'splash_logo' => ['label' => 'Splash Screen Logo', 'desc' => 'Logo shown on the splash/loading screen',
                                           'url' => $branding['splash_logo_url'] ?? null],
                        'login_logo' => ['label' => 'Login Screen Logo', 'desc' => 'Logo displayed on the login page',
                                          'url' => $branding['login_logo_url'] ?? null],
                        'appbar_logo' => ['label' => 'App Bar Logo', 'desc' => 'Small logo in the top app bar',
                                           'url' => $branding['appbar_logo_url'] ?? null],
                        'favicon' => ['label' => 'Favicon (browser tab icon)', 'desc' => 'Favicon for the admin panel',
                                      'url' => $branding['favicon_url'] ?? null],
                    ];
                @endphp

                @foreach($logoFields as $field => $info)
                <div class="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                    @if($info['url'])
                    <img src="{{ $info['url'] }}" alt="{{ $info['label'] }}" class="w-10 h-10 object-contain rounded">
                    @else
                    <div class="w-10 h-10 bg-gray-200 rounded flex items-center justify-center text-gray-400 text-xs">No</div>
                    @endif
                    <div class="flex-1">
                        <p class="text-sm font-medium text-[#0F1B3D]">{{ $info['label'] }}</p>
                        <p class="text-xs text-gray-500">{{ $info['desc'] }}</p>
                    </div>
                    <input type="file" name="{{ $field }}" accept="image/png,image/svg+xml,image/jpeg,image/gif,image/webp"
                           class="text-xs text-gray-600 file:mr-2 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b897]">
                </div>
                @endforeach
            </div>
        </div>

        {{-- Preview --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-4">Preview</h2>
            <div class="p-8 rounded-2xl" style="background: {{ $branding['primary_color'] ?? '#131C3C' }}">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 bg-gradient-to-br from-[#00C9A7] to-[#00b897] rounded-lg flex items-center justify-center">
                        <span class="text-white font-bold text-sm">{{ substr($branding['app_short_name'] ?? 'HE', 0, 2) }}</span>
                    </div>
                    <div>
                        <p class="text-white/70 text-xs">Good morning</p>
                        <p class="text-white font-semibold text-sm">{{ $branding['app_name'] ?? 'He Medical Clinic' }}</p>
                    </div>
                </div>
                <p class="text-white/60 text-xs mt-4 italic">{{ $branding['tagline'] ?? '' }}</p>
            </div>
        </div>

        <div class="flex justify-end">
            <button type="submit"
                    class="px-6 py-3 bg-[#00C9A7] text-white rounded-xl font-medium text-sm hover:bg-[#00b897] transition-colors">
                Save Branding
            </button>
        </div>
    </form>
</div>
@endsection
