@extends('layouts.admin')

@section('title', 'System Settings')
@section('subtitle', 'Configure app URL, Firebase, and mail/SMTP from the admin panel — no .env editing needed.')

@section('content')
<div class="max-w-4xl mx-auto">
    <form method="POST" action="{{ route('admin.settings.system.update') }}" class="space-y-6">
        @csrf

        {{-- Application --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Application</h2>
            <p class="text-sm text-gray-500 mb-6">Base URL used for file download links and email links.</p>

            <div>
                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">App URL</label>
                <input type="url" name="app_url" value="{{ old('app_url', $settings['app_url']) }}"
                       placeholder="https://hemedicalapps.com"
                       class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                <p class="mt-1 text-xs text-gray-400">Used in document download URLs and notification email links. No trailing slash.</p>
                @error('app_url') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
            </div>
        </div>

        {{-- Firebase --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Firebase</h2>
            <p class="text-sm text-gray-500 mb-6">Used for push notifications and in-app notifications.</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Project ID</label>
                    <input type="text" name="firebase_project_id" value="{{ old('firebase_project_id', $settings['firebase_project_id']) }}"
                           placeholder="heclinicapps-8be27"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                    @error('firebase_project_id') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Web API Key</label>
                    <div class="flex items-center gap-3">
                        <input type="password" name="firebase_web_api_key" autocomplete="new-password"
                               placeholder="Leave blank to keep the existing key"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                        <span class="shrink-0 text-xs font-medium px-2.5 py-1 rounded-full {{ $settings['firebase_web_api_key_configured'] ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                            {{ $settings['firebase_web_api_key_configured'] ? 'Configured' : 'Not set' }}
                        </span>
                    </div>
                    <p class="mt-1 text-xs text-gray-400">Stored encrypted. Leave empty to keep the current key.</p>
                    @error('firebase_web_api_key') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        {{-- Mail / SMTP --}}
        <div class="bg-white rounded-xl p-6 border border-gray-200">
            <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Mail / SMTP</h2>
            <p class="text-sm text-gray-500 mb-6">Used to send notification emails (e.g. patient document uploads).</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Mailer</label>
                    <select name="mail_mailer"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                        <option value="smtp" {{ old('mail_mailer', $settings['mail_mailer']) === 'smtp' ? 'selected' : '' }}>SMTP</option>
                        <option value="log" {{ old('mail_mailer', $settings['mail_mailer']) === 'log' ? 'selected' : '' }}>Log only (testing)</option>
                    </select>
                    <p class="mt-1 text-xs text-gray-400">Choose "Log only" while testing to avoid sending real emails.</p>
                    @error('mail_mailer') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Encryption</label>
                    <select name="mail_encryption"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                        @php $currentEnc = $settings['mail_encryption'] === '' ? 'none' : $settings['mail_encryption']; @endphp
                        <option value="tls" {{ old('mail_encryption', $currentEnc) === 'tls' ? 'selected' : '' }}>TLS</option>
                        <option value="ssl" {{ old('mail_encryption', $currentEnc) === 'ssl' ? 'selected' : '' }}>SSL</option>
                        <option value="none" {{ old('mail_encryption', $currentEnc) === 'none' ? 'selected' : '' }}>None</option>
                    </select>
                    @error('mail_encryption') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">SMTP Host</label>
                    <input type="text" name="mail_host" value="{{ old('mail_host', $settings['mail_host']) }}"
                           placeholder="smtp.gmail.com"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                    @error('mail_host') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">SMTP Port</label>
                    <input type="number" name="mail_port" min="1" max="65535" value="{{ old('mail_port', $settings['mail_port']) }}"
                           placeholder="587"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    @error('mail_port') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">SMTP Username</label>
                    <input type="text" name="mail_username" value="{{ old('mail_username', $settings['mail_username']) }}"
                           placeholder="noreply@hemedicalapps.com"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                    @error('mail_username') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">SMTP Password</label>
                    <div class="flex items-center gap-3">
                        <input type="password" name="mail_password" autocomplete="new-password"
                               placeholder="Leave blank to keep the existing password"
                               class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                        <span class="shrink-0 text-xs font-medium px-2.5 py-1 rounded-full {{ $settings['mail_password_configured'] ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                            {{ $settings['mail_password_configured'] ? 'Configured' : 'Not set' }}
                        </span>
                    </div>
                    <p class="mt-1 text-xs text-gray-400">Stored encrypted. Leave empty to keep the current password.</p>
                    @error('mail_password') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">From Address</label>
                    <input type="email" name="mail_from_address" value="{{ old('mail_from_address', $settings['mail_from_address']) }}"
                           placeholder="noreply@hemedicalapps.com"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                    @error('mail_from_address') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">From Name</label>
                    <input type="text" name="mail_from_name" value="{{ old('mail_from_name', $settings['mail_from_name']) }}"
                           placeholder="He Clinic Apps"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    @error('mail_from_name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <button type="submit"
                    class="px-6 py-3 bg-[#00C9A7] text-white rounded-xl font-medium text-sm hover:bg-[#00b897] transition-colors">
                Save Settings
            </button>
        </div>
    </form>
</div>
@endsection
