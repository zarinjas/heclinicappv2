<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Seeds the default contact & about information settings. The values are
 * stored in the existing `settings` key/value table and are managed from the
 * admin panel under Settings → Contact & About.
 */
return new class extends Migration
{
    private const DEFAULTS = [
        'contact_company_name' => [
            'value' => 'He Medical Clinic',
            'description' => 'Contact info: company name shown on the public /contact and /about pages',
        ],
        'contact_support_email' => [
            'value' => 'info@heclinic.com',
            'description' => 'Contact info: support email address',
        ],
        'contact_phone' => [
            'value' => '+60 11-6720 8860',
            'description' => 'Contact info: phone number',
        ],
        'contact_website' => [
            'value' => 'https://hemedicalclinic.com',
            'description' => 'Contact info: website URL',
        ],
        'contact_address' => [
            'value' => 'No. 12, Jalan Pahlawan, 55100 Kuala Lumpur, Malaysia',
            'description' => 'Contact info: business address',
        ],
        'contact_operating_hours' => [
            'value' => '["Mon-Fri: 8:00am - 8:00pm","Sat: 9:00am - 1:00pm","Sun & Public Holidays: Closed"]',
            'description' => 'Contact info: operating hours (JSON array of strings)',
        ],
        'about_app_description' => [
            'value' => 'He Clinic is your trusted digital healthcare companion. Book appointments, view health records, and stay connected with He Medical Clinic from the comfort of your home.',
            'description' => 'About: app description shown on the public /about page and in the app',
        ],
        'about_app_version' => [
            'value' => '1.0.1',
            'description' => 'About: current app version shown on the public /about page',
        ],
    ];

    public function up(): void
    {
        foreach (self::DEFAULTS as $key => $data) {
            DB::table('settings')->insertOrIgnore([
                'key' => $key,
                'value' => $data['value'],
                'description' => $data['description'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        DB::table('settings')
            ->whereIn('key', array_keys(self::DEFAULTS))
            ->delete();
    }
};
