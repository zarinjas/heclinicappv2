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
        @php
            $welcomeLogoSize = (int) ($branding['welcome_logo_size'] ?? 120);
            $previewLogoUrl = $branding['welcome_logo_url'] ?: ($branding['logo_url'] ?? null);
        @endphp
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm mt-6">
            <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="text-lg font-semibold text-[#0F1B3D]">Welcome Screen Settings</h2>
                <p class="text-xs text-gray-400 mt-1">Customize the welcome screen: background image, color overlay (solid / linear / radial gradient), logo, and buttons.</p>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">
                    {{-- Controls --}}
                    <div class="lg:col-span-3">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="col-span-2">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Background Image</label>
                                <div class="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                                    <div id="preview-welcome_bg_image" class="w-24 h-24 rounded-lg border border-gray-200 bg-white overflow-hidden flex items-center justify-center shrink-0">
                                        @if($branding['welcome_bg_image_url'])
                                        <img src="{{ $branding['welcome_bg_image_url'] }}" alt="Welcome Background" class="w-full h-full object-cover">
                                        @else
                                        <div class="w-full h-full bg-gray-100 flex items-center justify-center text-gray-400 text-xs">No</div>
                                        @endif
                                    </div>
                                    <div class="flex-1">
                                        <p class="text-xs text-gray-500">Full-screen background image (recommended 1080×1920px). Leave empty to use only the color overlay.</p>
                                        <input type="file" name="welcome_bg_image" accept="image/png,image/jpeg,image/webp,image/gif"
                                               onchange="previewImage(event, 'welcome_bg_image'); updateWelcomePreviewImage(event)"
                                               class="mt-2 text-xs text-gray-600 file:mr-2 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b897]">
                                    </div>
                                </div>
                            </div>

                            <div class="col-span-2">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Welcome Logo</label>
                                <div class="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                                    <div id="preview-welcome_logo" class="w-16 h-16 rounded-lg border border-gray-200 bg-white overflow-hidden flex items-center justify-center shrink-0">
                                        @if($previewLogoUrl)
                                        <img src="{{ $previewLogoUrl }}" alt="Welcome Logo" class="w-full h-full object-contain">
                                        @else
                                        <div class="w-full h-full bg-gray-100 flex items-center justify-center text-gray-400 text-xs">No</div>
                                        @endif
                                    </div>
                                    <div class="flex-1">
                                        <p class="text-xs text-gray-500">Logo shown on the welcome screen. Falls back to the main app logo if left empty.</p>
                                        <input type="file" name="welcome_logo" accept="image/png,image/svg+xml,image/jpeg,image/webp,image/gif"
                                               onchange="previewImage(event, 'welcome_logo'); updateWelcomePreviewLogo(event)"
                                               class="mt-2 text-xs text-gray-600 file:mr-2 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-medium file:bg-[#00C9A7] file:text-white hover:file:bg-[#00b897]">
                                    </div>
                                </div>
                            </div>

                            <div class="col-span-2">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Overlay Type</label>
                                <select name="welcome_overlay_type" id="welcome_overlay_type" onchange="toggleOverlayFields(); updateWelcomePreview()"
                                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                                    <option value="solid" {{ ($branding['welcome_overlay_type'] ?? 'linear') === 'solid' ? 'selected' : '' }}>Solid Color</option>
                                    <option value="linear" {{ ($branding['welcome_overlay_type'] ?? 'linear') === 'linear' ? 'selected' : '' }}>Linear Gradient (top → bottom)</option>
                                    <option value="radial" {{ ($branding['welcome_overlay_type'] ?? 'linear') === 'radial' ? 'selected' : '' }}>Radial Gradient (center → edge)</option>
                                </select>
                            </div>

                            <div id="field-welcome_overlay_color" class="field-overlay-solid">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Solid Color</label>
                                <input type="color" name="welcome_overlay_color" value="{{ old('welcome_overlay_color', $branding['welcome_overlay_color']) }}"
                                       oninput="updateWelcomePreview()" class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                            </div>

                            <div id="field-linear-start" class="field-overlay-linear">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient Start Color (top)</label>
                                <input type="color" name="welcome_linear_start_color" value="{{ old('welcome_linear_start_color', $branding['welcome_linear_start_color']) }}"
                                       oninput="updateWelcomePreview()" class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                            </div>
                            <div id="field-linear-end" class="field-overlay-linear">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Gradient End Color (bottom)</label>
                                <input type="color" name="welcome_linear_end_color" value="{{ old('welcome_linear_end_color', $branding['welcome_linear_end_color']) }}"
                                       oninput="updateWelcomePreview()" class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                            </div>

                            <div id="field-radial-center" class="field-overlay-radial">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Radial Center Color</label>
                                <input type="color" name="welcome_radial_center_color" value="{{ old('welcome_radial_center_color', $branding['welcome_radial_center_color']) }}"
                                       oninput="updateWelcomePreview()" class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                            </div>
                            <div id="field-radial-edge" class="field-overlay-radial">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Radial Edge Color</label>
                                <input type="color" name="welcome_radial_edge_color" value="{{ old('welcome_radial_edge_color', $branding['welcome_radial_edge_color']) }}"
                                       oninput="updateWelcomePreview()" class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                            </div>

                            <div class="col-span-2">
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Overlay Opacity: <span id="opacity_value" class="text-[#00C9A7]">{{ $branding['welcome_overlay_opacity'] ?? 100 }}%</span></label>
                                <input type="range" name="welcome_overlay_opacity" min="0" max="100" value="{{ old('welcome_overlay_opacity', $branding['welcome_overlay_opacity']) }}"
                                       oninput="document.getElementById('opacity_value').textContent = this.value + '%'; updateWelcomePreview()"
                                       class="w-full accent-[#00C9A7]">
                                <p class="text-xs text-gray-500 mt-1">Higher = more solid overlay. Lower lets the background image show through.</p>
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Button Color</label>
                                <input type="color" name="welcome_button_color" value="{{ old('welcome_button_color', $branding['welcome_button_color']) }}"
                                       class="w-full h-10 px-1 border border-gray-300 rounded-lg cursor-pointer">
                                <p class="text-xs text-gray-500 mt-1">Accent color used around the welcome screen buttons.</p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Logo Size (px)</label>
                                <input type="number" name="welcome_logo_size" value="{{ old('welcome_logo_size', $welcomeLogoSize) }}"
                                       min="60" max="260" oninput="updateWelcomePreviewLogoSize()"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent">
                                <p class="text-xs text-gray-500 mt-1">Logo size on the welcome screen (60–260 px).</p>
                            </div>
                        </div>
                    </div>

                    {{-- Live phone preview --}}
                    <div class="lg:col-span-2">
                        <div class="lg:sticky lg:top-6">
                            <p class="text-sm font-semibold text-[#0F1B3D] mb-2">Live Preview</p>
                            <div class="relative mx-auto w-56 rounded-[2rem] border-[10px] border-gray-800 shadow-2xl overflow-hidden" style="height: 460px">
                                @if($branding['welcome_bg_image_url'])
                                <img id="welcome-preview-image" src="{{ $branding['welcome_bg_image_url'] }}" alt="Welcome BG" class="absolute inset-0 w-full h-full object-cover">
                                @else
                                <img id="welcome-preview-image" src="" alt="" class="absolute inset-0 w-full h-full object-cover hidden">
                                @endif
                                <div id="welcome-preview-overlay" class="absolute inset-0"></div>
                                <div class="relative z-10 flex flex-col items-center justify-between h-full p-5">
                                    <div class="flex-1"></div>
                                    <div class="flex flex-col items-center">
                                        <img id="welcome-preview-logo" src="{{ $previewLogoUrl ?? '' }}" alt="Logo"
                                             class="object-contain mb-3 {{ $previewLogoUrl ? '' : 'hidden' }}"
                                             style="width: {{ $welcomeLogoSize }}px; height: {{ $welcomeLogoSize }}px">
                                        <div id="welcome-preview-logo-fallback"
                                             class="rounded-lg bg-gradient-to-br from-[#00C9A7] to-[#00b897] mb-3 flex items-center justify-center text-white font-extrabold {{ $previewLogoUrl ? 'hidden' : '' }}"
                                             style="width: {{ $welcomeLogoSize }}px; height: {{ $welcomeLogoSize }}px; font-size: {{ (int) ($welcomeLogoSize * 0.35) }}px">
                                            {{ substr($branding['app_short_name'] ?? 'HE', 0, 2) }}
                                        </div>
                                        <p class="text-white font-bold text-sm">{{ $branding['app_name'] ?? 'He Medical Clinic' }}</p>
                                    </div>
                                    <div class="flex-1"></div>
                                    <div class="w-full space-y-3">
                                        <div class="w-full h-12 rounded-xl bg-white text-[#0F1B3D] flex items-center justify-center text-sm font-semibold">Log In</div>
                                        <div class="w-full h-12 rounded-xl border border-white/70 text-white flex items-center justify-center text-sm font-semibold">Create Account</div>
                                    </div>
                                </div>
                            </div>
                        </div>
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

    function toggleOverlayFields() {
        const type = document.getElementById('welcome_overlay_type').value;
        document.querySelectorAll('.field-overlay-solid, .field-overlay-linear, .field-overlay-radial').forEach(el => {
            el.style.display = 'none';
        });
        document.querySelectorAll('.field-overlay-' + type).forEach(el => {
            el.style.display = '';
        });
    }

    function updateWelcomePreview() {
        const type = document.getElementById('welcome_overlay_type').value;
        const overlay = document.getElementById('welcome-preview-overlay');
        if (!overlay) return;

        const opacity = (document.querySelector('[name="welcome_overlay_opacity"]').value || 100) / 100;
        let bg = '';
        if (type === 'solid') {
            bg = document.querySelector('[name="welcome_overlay_color"]').value;
        } else if (type === 'linear') {
            bg = 'linear-gradient(to bottom, ' +
                document.querySelector('[name="welcome_linear_start_color"]').value + ', ' +
                document.querySelector('[name="welcome_linear_end_color"]').value + ')';
        } else {
            bg = 'radial-gradient(circle at center, ' +
                document.querySelector('[name="welcome_radial_center_color"]').value + ', ' +
                document.querySelector('[name="welcome_radial_edge_color"]').value + ')';
        }
        overlay.style.background = bg;
        overlay.style.opacity = opacity;
    }

    function updateWelcomePreviewImage(event) {
        const file = event.target.files && event.target.files[0];
        const img = document.getElementById('welcome-preview-image');
        if (!file || !img) return;
        const reader = new FileReader();
        reader.onload = function (e) {
            img.src = e.target.result;
            img.classList.remove('hidden');
        };
        reader.readAsDataURL(file);
    }

    function updateWelcomePreviewLogo(event) {
        const file = event.target.files && event.target.files[0];
        const img = document.getElementById('welcome-preview-logo');
        const fallback = document.getElementById('welcome-preview-logo-fallback');
        if (!file || !img) return;
        const reader = new FileReader();
        reader.onload = function (e) {
            img.src = e.target.result;
            img.classList.remove('hidden');
            if (fallback) fallback.classList.add('hidden');
            updateWelcomePreviewLogoSize();
        };
        reader.readAsDataURL(file);
    }

    function updateWelcomePreviewLogoSize() {
        const size = document.querySelector('[name="welcome_logo_size"]').value || 120;
        const img = document.getElementById('welcome-preview-logo');
        const fallback = document.getElementById('welcome-preview-logo-fallback');
        if (img) {
            img.style.width = size + 'px';
            img.style.height = size + 'px';
        }
        if (fallback) {
            fallback.style.width = size + 'px';
            fallback.style.height = size + 'px';
            fallback.style.fontSize = Math.round(size * 0.35) + 'px';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        toggleOverlayFields();
        updateWelcomePreview();
    });
</script>
@endpush
