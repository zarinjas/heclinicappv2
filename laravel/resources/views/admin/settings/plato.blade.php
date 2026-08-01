@extends('layouts.admin')

@section('title', 'Plato Settings')
@section('subtitle', 'Configure the Plato Medical API connection for the mobile app proxy.')

@section('content')
<div class="max-w-4xl mx-auto">
    <div class="bg-white rounded-xl p-6 border border-gray-200">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Plato Medical API</h2>
        <p class="text-sm text-gray-500 mb-6">
            The token is stored encrypted in the database and is only used server-side when proxying requests
            to <code class="text-xs bg-gray-100 px-1 py-0.5 rounded">clinic.platomedical.com</code>.
        </p>

        <form method="POST" action="{{ route('admin.settings.plato.update') }}" class="space-y-5">
            @csrf

            <div>
                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">API Token</label>
                <div class="flex items-center gap-3">
                    <input type="password" name="plato_api_token" autocomplete="new-password"
                           placeholder="Leave blank to keep the existing token"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                    <span class="shrink-0 text-xs font-medium px-2.5 py-1 rounded-full {{ $settings['token_configured'] ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                        {{ $settings['token_configured'] ? 'Configured' : 'Not set' }}
                    </span>
                </div>
                <p class="mt-1 text-xs text-gray-400">Entering a new token replaces the old one. Leave empty to keep the current token.</p>
                @error('plato_api_token') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
            </div>

            <div>
                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Base URL</label>
                <input type="url" name="plato_base_url" value="{{ old('plato_base_url', $settings['base_url']) }}"
                       class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none font-mono">
                @error('plato_base_url') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Timeout (seconds)</label>
                    <input type="number" name="plato_timeout" min="1" max="300" value="{{ old('plato_timeout', $settings['timeout']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    @error('plato_timeout') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Proxy Rate Limit (requests / minute)</label>
                    <input type="number" name="plato_proxy_rate_limit" min="1" max="600" value="{{ old('plato_proxy_rate_limit', $settings['proxy_rate_limit']) }}"
                           class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none">
                    @error('plato_proxy_rate_limit') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                </div>
            </div>

            <label class="flex items-center gap-3 cursor-pointer">
                <input type="checkbox" name="plato_cache_enabled" value="1"
                       {{ old('plato_cache_enabled', $settings['cache_enabled']) === '1' ? 'checked' : '' }}
                       class="w-4 h-4 rounded border-gray-300 text-[#00C9A7] focus:ring-[#00C9A7]">
                <span class="text-sm text-gray-700">Enable response caching (reduces Plato API usage)</span>
            </label>

            <div class="flex items-center gap-3 pt-2">
                <button type="submit"
                        class="px-6 py-3 bg-[#00C9A7] text-white rounded-xl font-medium text-sm hover:bg-[#00b897] transition-colors">
                    Save Settings
                </button>
            </div>
        </form>

        <hr class="my-6 border-gray-200">

        <div>
            <h3 class="text-sm font-semibold text-[#0F1B3D] mb-2">Test Connection</h3>
            <p class="text-xs text-gray-500 mb-3">Pings Plato <code class="text-xs bg-gray-100 px-1 py-0.5 rounded">/facility</code> to verify the token and base URL work.</p>
            <form method="POST" action="{{ route('admin.settings.plato.test') }}">
                @csrf
                <button type="submit"
                        class="px-6 py-3 bg-[#0F1B3D] text-white rounded-xl font-medium text-sm hover:bg-[#1e2d52] transition-colors">
                    Test Connection
                </button>
            </form>
        </div>
    </div>
</div>
@endsection
