<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Services\PlatoProxyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\View\View;

class PlatoSettingsController extends Controller
{
    public function __construct(private readonly PlatoProxyService $plato) {}

    public function index(): View
    {
        $settings = [
            'base_url' => $this->getSetting('plato_base_url', config('plato.base_url')),
            'timeout' => $this->getSetting('plato_timeout', config('plato.timeout', 30)),
            'cache_enabled' => $this->getSetting('plato_cache_enabled', config('plato.cache.enabled') ? '1' : '0'),
            'proxy_rate_limit' => $this->getSetting('plato_proxy_rate_limit', config('plato.proxy_rate_limit', 60)),
            'voucher_path' => $this->getSetting('plato_voucher_path', config('plato.voucher_path')),
            'token_configured' => Setting::where('key', 'plato_api_token')->exists(),
        ];

        return view('admin.settings.plato', compact('settings'));
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'plato_api_token' => 'nullable|string',
            'plato_base_url' => 'required|url',
            'plato_timeout' => 'required|integer|min:1|max:300',
            'plato_cache_enabled' => 'nullable|boolean',
            'plato_proxy_rate_limit' => 'required|integer|min:1|max:600',
            'plato_voucher_path' => ['nullable', 'string', 'max:255'],
        ]);

        $this->saveSetting('plato_base_url', $validated['plato_base_url']);
        $this->saveSetting('plato_timeout', (string) $validated['plato_timeout']);
        $this->saveSetting('plato_cache_enabled', $request->boolean('plato_cache_enabled') ? '1' : '0');
        $this->saveSetting('plato_proxy_rate_limit', (string) $validated['plato_proxy_rate_limit']);
        $this->saveSetting('plato_voucher_path', $validated['plato_voucher_path'] ?? '');

        if (! empty($validated['plato_api_token'])) {
            $this->saveSetting('plato_api_token', Crypt::encryptString($validated['plato_api_token']));
        }

        $this->plato->clearSettingsCache();

        return redirect()->route('admin.settings.plato')
            ->with('success', 'Plato settings updated successfully.');
    }

    public function testConnection(): RedirectResponse
    {
        $this->plato->clearSettingsCache();

        $health = $this->plato->healthCheck();

        if ($health['token_configured'] && $health['plato_connected']) {
            return redirect()->route('admin.settings.plato')
                ->with('success', 'Connection OK: Plato API is reachable with the configured token.');
        }

        $message = $health['token_configured']
            ? 'Connection failed: Plato API could not be reached. Check the token and base URL.'
            : 'No token configured: save a Plato API token first.';

        return redirect()->route('admin.settings.plato')
            ->with('error', $message);
    }

    private function getSetting(string $key, mixed $default): ?string
    {
        return Setting::where('key', $key)->value('value') ?? $default;
    }

    private function saveSetting(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "Plato setting: $key"]
        );
    }
}
