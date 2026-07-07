<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class BrandingController extends Controller
{
    public function index(): View
    {
        $branding = [
            'app_name' => Setting::where('key', 'branding_app_name')->value('value') ?? 'He Medical Clinic',
            'app_short_name' => Setting::where('key', 'branding_app_short_name')->value('value') ?? 'HE',
            'tagline' => Setting::where('key', 'branding_tagline')->value('value') ?? 'Your Health, Simplified',
            'primary_color' => Setting::where('key', 'branding_primary_color')->value('value') ?? '#131C3C',
            'splash_bg_color' => Setting::where('key', 'branding_splash_bg_color')->value('value') ?? '#131C3C',
            'logo_url' => Setting::where('key', 'branding_logo_url')->value('value'),
            'splash_logo_url' => Setting::where('key', 'branding_splash_logo_url')->value('value'),
            'login_logo_url' => Setting::where('key', 'branding_login_logo_url')->value('value'),
            'appbar_logo_url' => Setting::where('key', 'branding_appbar_logo_url')->value('value'),
            'favicon_url' => Setting::where('key', 'branding_favicon_url')->value('value'),
        ];

        return view('admin.branding', compact('branding'));
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'app_name' => 'required|string|max:100',
            'app_short_name' => 'required|string|max:10',
            'tagline' => 'nullable|string|max:200',
            'primary_color' => 'nullable|string|max:7',
            'splash_bg_color' => 'nullable|string|max:7',
            'logo' => 'nullable|image|mimes:png,svg,jpg,webp,gif|max:2048',
            'splash_logo' => 'nullable|image|mimes:png,svg,jpg,webp,gif|max:5120',
            'login_logo' => 'nullable|image|mimes:png,svg,jpg,webp|max:2048',
            'appbar_logo' => 'nullable|image|mimes:png,svg,jpg,webp|max:2048',
            'favicon' => 'nullable|image|mimes:png,ico,svg|max:1024',
        ]);

        $this->saveSetting('branding_app_name', $validated['app_name']);
        $this->saveSetting('branding_app_short_name', $validated['app_short_name']);
        $this->saveSetting('branding_tagline', $validated['tagline'] ?? '');
        $this->saveSetting('branding_primary_color', $validated['primary_color'] ?? '#131C3C');
        $this->saveSetting('branding_splash_bg_color', $validated['splash_bg_color'] ?? '#131C3C');

        $imageFields = [
            'logo' => 'branding_logo_url',
            'splash_logo' => 'branding_splash_logo_url',
            'login_logo' => 'branding_login_logo_url',
            'appbar_logo' => 'branding_appbar_logo_url',
            'favicon' => 'branding_favicon_url',
        ];

        foreach ($imageFields as $field => $key) {
            if ($request->hasFile($field)) {
                // Delete old file if exists
                $oldUrl = Setting::where('key', $key)->value('value');
                if ($oldUrl) {
                    $oldPath = str_replace('/storage/', '', parse_url($oldUrl, PHP_URL_PATH));
                    if ($oldPath && Storage::disk('public')->exists($oldPath)) {
                        Storage::disk('public')->delete($oldPath);
                    }
                }

                $path = $request->file($field)->store('branding', 'public');
                $url = Storage::disk('public')->url($path);
                $this->saveSetting($key, $url);
            }
        }

        return redirect()->route('admin.branding')
            ->with('success', 'Branding updated successfully. Clear your app cache or restart the app to see changes.');
    }

    private function saveSetting(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "Branding setting: $key"]
        );
    }
}
