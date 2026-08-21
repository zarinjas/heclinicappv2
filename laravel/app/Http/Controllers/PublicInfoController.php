<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Contracts\View\View;

/**
 * Renders the public, admin-editable Contact Information (/contact) and
 * About (/about) pages. All values live in the `settings` table and are
 * managed from Admin → Settings → Contact & About.
 */
class PublicInfoController extends Controller
{
    public function contact(): View
    {
        $values = $this->values([
            'contact_company_name' => 'He Medical Clinic',
            'contact_support_email' => 'info@heclinic.com',
            'contact_phone' => '+60 11-6720 8860',
            'contact_website' => 'https://hemedicalclinic.com',
            'contact_address' => '',
            'contact_operating_hours' => '[]',
        ]);

        $values['operating_hours'] = json_decode($values['contact_operating_hours'], true) ?: [];

        return view('contact', ['info' => $values]);
    }

    public function about(): View
    {
        $values = $this->values([
            'branding_app_name' => 'He Medical Clinic',
            'about_app_description' => '',
            'contact_company_name' => 'He Medical Clinic',
            'contact_website' => 'https://hemedicalclinic.com',
            'contact_support_email' => 'info@heclinic.com',
            'about_app_version' => '1.0.1',
        ]);

        return view('about', ['info' => $values]);
    }

    /**
     * Fetch the given setting keys, applying a default when a key is missing
     * or empty so the public pages never render blanks.
     *
     * @param array<string, string> $defaults
     * @return array<string, string>
     */
    private function values(array $defaults): array
    {
        $stored = Setting::whereIn('key', array_keys($defaults))
            ->pluck('value', 'key')
            ->toArray();

        $out = [];
        foreach ($defaults as $key => $default) {
            $out[$key] = ($stored[$key] ?? '') !== '' ? (string) $stored[$key] : $default;
        }

        return $out;
    }
}
