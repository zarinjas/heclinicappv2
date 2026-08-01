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
            'accent_color' => Setting::where('key', 'branding_accent_color')->value('value') ?? '#3B8DFF',
            'splash_bg_color' => Setting::where('key', 'branding_splash_bg_color')->value('value') ?? '#131C3C',
            'logo_url' => Setting::where('key', 'branding_logo_url')->value('value'),
            'splash_logo_url' => Setting::where('key', 'branding_splash_logo_url')->value('value'),
            'login_logo_url' => Setting::where('key', 'branding_login_logo_url')->value('value'),
            'appbar_logo_url' => Setting::where('key', 'branding_appbar_logo_url')->value('value'),
            'loading_gif_url' => Setting::where('key', 'branding_loading_gif_url')->value('value'),
            'favicon_url' => Setting::where('key', 'branding_favicon_url')->value('value'),
            'telehealth_title' => Setting::where('key', 'telehealth_title')->value('value') ?? 'Telehealth Consultation',
            'telehealth_description' => Setting::where('key', 'telehealth_description')->value('value') ?? '',
            'telehealth_features' => Setting::where('key', 'telehealth_features')->value('value') ?? '[]',
            'telehealth_whatsapp' => Setting::where('key', 'telehealth_whatsapp')->value('value') ?? '60136254528',
            'telehealth_price' => Setting::where('key', 'telehealth_price')->value('value') ?? 'RM 30 per 15-minute consultation',
            'telehealth_hours' => Setting::where('key', 'telehealth_hours')->value('value') ?? '',
            'telehealth_button_label' => Setting::where('key', 'telehealth_button_label')->value('value') ?? 'Start WhatsApp Consultation',
            'clinic_about_text' => Setting::where('key', 'clinic_about_text')->value('value') ?? '',
            'clinic_operating_hours' => Setting::where('key', 'clinic_operating_hours')->value('value') ?? '[]',
            'clinic_contact_email' => Setting::where('key', 'clinic_contact_email')->value('value') ?? 'info@heclinic.com',
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
            'accent_color' => 'nullable|string|max:7',
            'splash_bg_color' => 'nullable|string|max:7',
            'logo' => 'nullable|image|mimes:png,svg,jpg,webp,gif|max:2048',
            'splash_logo' => 'nullable|image|mimes:png,svg,jpg,webp,gif|max:5120',
            'login_logo' => 'nullable|image|mimes:png,svg,jpg,webp|max:2048',
            'appbar_logo' => 'nullable|image|mimes:png,svg,jpg,webp|max:2048',
            'loading_gif' => 'nullable|image|mimes:gif,webp,png|max:10240',
            'favicon' => 'nullable|image|mimes:png,ico,svg|max:1024',
            'telehealth_title' => 'nullable|string|max:255',
            'telehealth_description' => 'nullable|string|max:1000',
            'telehealth_features' => 'nullable|string|max:2000',
            'telehealth_whatsapp' => 'nullable|string|max:20',
            'telehealth_price' => 'nullable|string|max:100',
            'telehealth_hours' => 'nullable|string|max:255',
            'telehealth_button_label' => 'nullable|string|max:100',
            'clinic_about_text' => 'nullable|string|max:2000',
            'clinic_operating_hours' => 'nullable|string|max:2000',
            'clinic_contact_email' => 'nullable|email|max:255',
        ]);

        $this->saveSetting('branding_app_name', $validated['app_name']);
        $this->saveSetting('branding_app_short_name', $validated['app_short_name']);
        $this->saveSetting('branding_tagline', $validated['tagline'] ?? '');
        $this->saveSetting('branding_primary_color', $validated['primary_color'] ?? '#131C3C');
        $this->saveSetting('branding_accent_color', $validated['accent_color'] ?? '#3B8DFF');
        $this->saveSetting('branding_splash_bg_color', $validated['splash_bg_color'] ?? '#131C3C');

        $textFields = [
            'telehealth_title' => 'telehealth_title',
            'telehealth_description' => 'telehealth_description',
            'telehealth_features' => 'telehealth_features',
            'telehealth_whatsapp' => 'telehealth_whatsapp',
            'telehealth_price' => 'telehealth_price',
            'telehealth_hours' => 'telehealth_hours',
            'telehealth_button_label' => 'telehealth_button_label',
            'clinic_about_text' => 'clinic_about_text',
            'clinic_operating_hours' => 'clinic_operating_hours',
            'clinic_contact_email' => 'clinic_contact_email',
        ];

        foreach ($textFields as $field => $key) {
            if ($request->has($field)) {
                $this->saveSetting($key, $request->input($field));
            }
        }

        $imageFields = [
            'logo' => 'branding_logo_url',
            'splash_logo' => 'branding_splash_logo_url',
            'login_logo' => 'branding_login_logo_url',
            'appbar_logo' => 'branding_appbar_logo_url',
            'loading_gif' => 'branding_loading_gif_url',
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
