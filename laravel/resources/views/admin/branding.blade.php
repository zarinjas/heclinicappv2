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
                    <p class="text-xs text-gray-500 mt-1">Main theme color (navy blue default). Applied to app bar, headers, and primary elements.</p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Accent Color (hex)</label>
                    <input type="color" name="accent_color" value="{{ old('accent_color', $branding['accent_color'] ?? '#3B8DFF') }}"
                           class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                    <p class="text-xs text-gray-500 mt-1">Accent color for buttons and highlights (blue default).</p>
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
                        'loading_gif' => ['label' => 'Loading GIF', 'desc' => 'Animated GIF shown on every loading screen (splash + in-app loaders)',
                                          'url' => $branding['loading_gif_url'] ?? null],
                        'favicon' => ['label' => 'Favicon (browser tab icon)', 'desc' => 'Favicon for the admin panel',
                                      'url' => $branding['favicon_url'] ?? null],
                    ];
                @endphp

                @foreach($logoFields as $field => $info)
                <div class="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                    <div id="preview-{{ $field }}" class="w-16 h-16 rounded-lg border border-gray-200 bg-white overflow-hidden flex items-center justify-center shrink-0">
                        @if($info['url'])
                        <img src="{{ $info['url'] }}" alt="{{ $info['label'] }}" class="w-full h-full object-contain">
                        @else
                        <div class="w-full h-full bg-gray-100 flex items-center justify-center text-gray-400 text-xs">No</div>
                        @endif
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-medium text-[#0F1B3D]">{{ $info['label'] }}</p>
                        <p class="text-xs text-gray-500">{{ $info['desc'] }}</p>
                    </div>
                    <input type="file" name="{{ $field }}" accept="image/png,image/svg+xml,image/jpeg,image/gif,image/webp"
                           onchange="previewImage(event, '{{ $field }}')"
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

        <!-- Welcome Screen Settings -->
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm mt-6">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">Welcome Screen Settings</h2>
                <p class="text-xs text-gray-400 mt-1">Customize the welcome screen shown after onboarding (logo, background, and buttons).</p>
            </div>
            <div class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Background Color</label>
                        <input type="color" name="welcome_bg_color" value="{{ old('welcome_bg_color', $branding['welcome_bg_color']) }}"
                               class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                        <p class="text-xs text-gray-500 mt-1">Base background color for the welcome screen.</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient Overlay Color</label>
                        <input type="color" name="welcome_bg_gradient_color" value="{{ old('welcome_bg_gradient_color', $branding['welcome_bg_gradient_color']) }}"
                               class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                        <p class="text-xs text-gray-500 mt-1">Gradient overlay from top to bottom over the background color.</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Button Color</label>
                        <input type="color" name="welcome_button_color" value="{{ old('welcome_button_color', $branding['welcome_button_color']) }}"
                               class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                        <p class="text-xs text-gray-500 mt-1">Color for the "Log In" button on the welcome screen.</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Logo Size (px)</label>
                        <input type="number" name="welcome_logo_size" value="{{ old('welcome_logo_size', $branding['welcome_logo_size']) }}"
                               min="60" max="260"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                        <p class="text-xs text-gray-500 mt-1">Logo size on the welcome screen (60–260 px).</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Telehealth Settings -->
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm mt-6">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">Telehealth Configuration</h2>
            </div>
            <div class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Title</label>
                        <input type="text" name="telehealth_title" value="{{ old('telehealth_title', $branding['telehealth_title']) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Price Text</label>
                        <input type="text" name="telehealth_price" value="{{ old('telehealth_price', $branding['telehealth_price']) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">WhatsApp Number</label>
                        <input type="text" name="telehealth_whatsapp" value="{{ old('telehealth_whatsapp', $branding['telehealth_whatsapp']) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Hours Text</label>
                        <input type="text" name="telehealth_hours" value="{{ old('telehealth_hours', $branding['telehealth_hours']) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Button Label</label>
                        <input type="text" name="telehealth_button_label" value="{{ old('telehealth_button_label', $branding['telehealth_button_label']) }}"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Description</label>
                    <textarea name="telehealth_description" rows="3"
                              class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y">{{ old('telehealth_description', $branding['telehealth_description']) }}</textarea>
                </div>
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Features (JSON array)</label>
                    <textarea name="telehealth_features" rows="4"
                              class="w-full px-4 py-2 text-sm font-mono border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y">{{ old('telehealth_features', $branding['telehealth_features']) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">e.g. ["Feature 1", "Feature 2", "Feature 3"]</p>
                </div>
            </div>
        </div>

        <!-- Clinic Info Settings -->
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm mt-6">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">Clinic Info</h2>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">About Text</label>
                    <textarea name="clinic_about_text" rows="3"
                              class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y">{{ old('clinic_about_text', $branding['clinic_about_text']) }}</textarea>
                </div>
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Operating Hours (JSON array)</label>
                    <textarea name="clinic_operating_hours" rows="4"
                              class="w-full px-4 py-2 text-sm font-mono border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none resize-y">{{ old('clinic_operating_hours', $branding['clinic_operating_hours']) }}</textarea>
                    <p class="mt-1 text-xs text-gray-400">e.g. ["Mon-Fri: 8am-8pm", "Sat: 8am-4pm", "Sun & PH: Closed"]</p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Contact Email</label>
                    <input type="email" name="clinic_contact_email" value="{{ old('clinic_contact_email', $branding['clinic_contact_email']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                </div>
            </div>
        </div>

        <div class="flex justify-end mt-6">
            <button type="submit"
                    class="px-6 py-3 bg-[#00C9A7] text-white rounded-xl font-medium text-sm hover:bg-[#00b897] transition-colors">
                Save Settings
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
    function previewImage(event, field) {
        const file = event.target.files && event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (e) {
            const preview = document.getElementById('preview-' + field);
            if (preview) {
                preview.innerHTML =
                    '<img src="' + e.target.result + '" alt="Preview" class="w-full h-full object-contain">';
            }
        };
        reader.readAsDataURL(file);
    }
</script>
@endpush
