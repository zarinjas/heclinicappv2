<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;

/**
 * Public, unauthenticated endpoint that serves the contact & about details
 * used by the mobile app's About screen. Values are managed from the admin
 * panel under Settings → Contact & About.
 */
class AppInfoController extends Controller
{
    public function index()
    {
        $settings = Setting::whereIn('key', [
            'branding_app_name',
            'branding_app_short_name',
            'branding_tagline',
            'branding_logo_url',
            'about_app_description',
            'about_app_version',
            'contact_company_name',
            'contact_support_email',
            'contact_phone',
            'contact_website',
            'contact_address',
            'contact_operating_hours',
        ])->pluck('value', 'key');

        $operatingHours = json_decode($settings['contact_operating_hours'] ?? '[]', true);

        return response()->json([
            'app_name' => $settings['branding_app_name'] ?? 'He Medical Clinic',
            'app_short_name' => $settings['branding_app_short_name'] ?? 'HE',
            'tagline' => $settings['branding_tagline'] ?? 'Your Health, Simplified',
            'logo_url' => $settings['branding_logo_url'] ?? null,
            'app_description' => $settings['about_app_description'] ?? '',
            'app_version' => $settings['about_app_version'] ?? '1.0.1',
            'company_name' => $settings['contact_company_name'] ?? 'He Medical Clinic',
            'support_email' => $settings['contact_support_email'] ?? 'info@heclinic.com',
            'phone' => $settings['contact_phone'] ?? '',
            'website' => $settings['contact_website'] ?? 'https://hemedicalclinic.com',
            'address' => $settings['contact_address'] ?? '',
            'operating_hours' => is_array($operatingHours) ? $operatingHours : [],
        ]);
    }
}
