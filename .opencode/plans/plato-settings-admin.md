# Plan: Plato Settings Admin Panel + Deploy to VPS

## Context
- App: Flutter (`he_clinic`) + Laravel backend proxy
- Plato token `1463d1150e7b199effa2793c2d809034` verified active (HTTP 200, real data)
- Rate limit Plato: 20 req/min (`x-ratelimit-limit: 20`)
- User wants: configure Plato API token + settings from admin panel (not .env), deploy to existing VPS via GitHub Actions, then test Flutter app against production API
- Token should be encrypted in DB. Global scope. super_admin only.
- Settings table + Setting model already exist. BrandingController is the pattern to follow.

## Files to Create
1. `laravel/app/Http/Controllers/Admin/PlatoSettingsController.php`
2. `laravel/resources/views/admin/settings/plato.blade.php`

## Files to Edit
1. `laravel/routes/web.php` — add 3 routes in super_admin group
2. `laravel/resources/views/layouts/admin.blade.php` — add sidebar link
3. `laravel/app/Services/PlatoProxyService.php` — read settings from DB with fallback to config, encrypt token, cache, clearSettingsCache()
4. `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — use proxyRateLimit() from service (public method)

## Detailed Implementation

### 1. PlatoSettingsController.php
```php
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
    public function __construct(private readonly PlatoProxyService $plato)
    {
    }

    public function index(): View
    {
        $settings = [
            'base_url' => Setting::where('key', 'plato_base_url')->value('value') ?? config('plato.base_url'),
            'timeout' => Setting::where('key', 'plato_timeout')->value('value') ?? config('plato.timeout', 30),
            'cache_enabled' => Setting::where('key', 'plato_cache_enabled')->value('value') ?? (config('plato.cache.enabled') ? '1' : '0'),
            'proxy_rate_limit' => Setting::where('key', 'plato_proxy_rate_limit')->value('value') ?? config('plato.proxy_rate_limit', 60),
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
        ]);

        $this->saveSetting('plato_base_url', $validated['plato_base_url']);
        $this->saveSetting('plato_timeout', (string) $validated['plato_timeout']);
        $this->saveSetting('plato_cache_enabled', $request->boolean('plato_cache_enabled') ? '1' : '0');
        $this->saveSetting('plato_proxy_rate_limit', (string) $validated['plato_proxy_rate_limit']);

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

    private function saveSetting(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "Plato setting: $key"]
        );
    }
}
```

### 2. views/admin/settings/plato.blade.php
- extends `layouts.admin`, title 'Plato Settings'
- form POST to `admin.settings.plato.update` with @csrf
- Fields:
  - API Token: `<input type="password" name="plato_api_token">` + note "Leave blank to keep existing token" + status badge "Configured" if token_configured
  - Base URL: `plato_base_url` (url)
  - Timeout: `plato_timeout` (number, 1-300)
  - Cache Enabled: checkbox `plato_cache_enabled` value 1
  - Proxy Rate Limit: `plato_proxy_rate_limit` (number, 1-600)
- Submit button + "Test Connection" form button (separate form POST to `admin.settings.plato.test`)
- Uses existing Tailwind classes (#0F1B3D, #00C9A7)

### 3. routes/web.php — add inside the auth group (super_admin only)
```php
Route::middleware(['auth', 'role:super_admin'])->group(function (): void {
    Route::get('settings/plato', [PlatoSettingsController::class, 'index'])->name('settings.plato');
    Route::post('settings/plato', [PlatoSettingsController::class, 'update'])->name('settings.plato.update');
    Route::post('settings/plato/test', [PlatoSettingsController::class, 'testConnection'])->name('settings.plato.test');
});
```
Add `use App\Http\Controllers\Admin\PlatoSettingsController;` import.

### 4. layouts/admin.blade.php — add sidebar link after Branding
```blade
<a href="{{ route('admin.settings.plato') }}"
   class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
          {{ request()->routeIs('admin.settings.plato') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
    </svg>
    Plato Settings
</a>
```

### 5. PlatoProxyService.php — replace config reads with DB-backed getters

Replace private props ($baseUrl, $token, $timeout, $logRequests) with methods:
```php
public function clearSettingsCache(): void
{
    foreach (['plato:api_token', 'plato:base_url', 'plato:timeout', 'plato:cache_enabled', 'plato:proxy_rate_limit'] as $key) {
        Cache::forget($key);
    }
}

private function token(): string
{
    return (string) Cache::remember('plato:api_token', 300, function () {
        $stored = Setting::where('key', 'plato_api_token')->value('value');

        return $stored ? Crypt::decryptString($stored) : (string) config('plato.api_token');
    });
}

private function baseUrl(): string
{
    return (string) Cache::remember('plato:base_url', 300, function () {
        return Setting::where('key', 'plato_base_url')->value('value') ?? config('plato.base_url');
    });
}

private function timeout(): int
{
    return (int) Cache::remember('plato:timeout', 300, function () {
        return Setting::where('key', 'plato_timeout')->value('value') ?? config('plato.timeout', 30);
    });
}

private function cacheEnabled(): bool
{
    return (bool) Cache::remember('plato:cache_enabled', 300, function () {
        $stored = Setting::where('key', 'plato_cache_enabled')->value('value');

        return $stored !== null ? $stored === '1' : (bool) config('plato.cache.enabled', true);
    });
}

public function proxyRateLimit(): int
{
    return (int) Cache::remember('plato:proxy_rate_limit', 300, function () {
        return Setting::where('key', 'plato_proxy_rate_limit')->value('value') ?? config('plato.proxy_rate_limit', 60);
    });
}
```
- `proxy()`: use `$this->baseUrl()`, `$this->timeout()`, `$this->token()`, `$this->cacheEnabled()` (in getCacheTtl)
- `healthCheck()`: use `$this->baseUrl()`, `$this->token()`
- `getCacheTtl()`: `if (! $this->cacheEnabled()) return null;`
- logRequest/logError: keep, replace `$this->logRequests` with `(bool) config('plato.log_requests', true)`
- Remove old constructor that set private props

### 6. PlatoProxyController.php — replace `config('plato.proxy_rate_limit', 60)` with `$this->service->proxyRateLimit()`

## Verification
- `cd laravel && php -l` on each changed PHP file
- `cd laravel && php artisan route:list` (if possible locally)
- curl health endpoint after deploy: `GET /api/v2/plato/health` returns `plato_connected: true`

## Deploy Steps (after edits committed & pushed to develop)
1. GitHub Actions auto-deploys (workflow already exists)
2. Login `https://heclinic.cyberoket.cloud/admin` as super_admin
3. Menu Plato Settings → paste token `1463d1150e7b199effa2793c2d809034` → Save → Test Connection
4. Verify `GET https://heclinic.cyberoket.cloud/api/v2/plato/health`

## Test Flutter
```bash
flutter run --dart-define=PLATOM_URL=https://heclinic.cyberoket.cloud/api/v2/plato \
            --dart-define=LARAVEL_API_URL=https://heclinic.cyberoket.cloud/api \
            --dart-define=MEDICAL_APPS_URL=https://heclinic.cyberoket.cloud/api
```

## Security Notes
- Token encrypted with Crypt::encryptString (uses APP_KEY)
- Route restricted to super_admin
- Token was exposed in chat/history — recommend rotating before production release
- Rate limit is low (20/min) — cache + backoff already implemented client/server side

## NOT committed (user will commit manually per repo conventions)
