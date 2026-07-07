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
            'logo' => 'nullable|image|mimes:png,svg,jpg|max:2048',
            'splash_logo' => 'nullable|image|mimes:png,svg,jpg|max:2048',
            'login_logo' => 'nullable|image|mimes:png,svg,jpg|max:2048',
            'appbar_logo' => 'nullable|image|mimes:png,svg,jpg|max:2048',
            'favicon' => 'nullable|image|mimes:png,ico,svg|max:1024',
        ]);

        $this->saveSetting('branding_app_name', $validated['app_name']);
        $this->saveSetting('branding_app_short_name', $validated['app_short_name']);
        $this->saveSetting('branding_tagline', $validated['tagline'] ?? '');
        $this->saveSetting('branding_primary_color', $validated['primary_color'] ?? '#131C3C');

        foreach (['logo', 'splash_logo', 'login_logo', 'appbar_logo', 'favicon'] as $field) {
            if ($request->hasFile($field)) {
                $path = $request->file($field)->store('branding', 'public');
                $url = Storage::url($path);
                $this->saveSetting("branding_{$field}_url", $url);
            }
        }

        return redirect()->route('admin.branding')
            ->with('success', 'Branding updated successfully.');
    }

    private function saveSetting(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "Branding setting: $key"]
        );
    }
}
