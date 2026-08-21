<?php

namespace Tests\Feature;

use App\Models\Setting;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Guards the public /contact and /about pages and the mobile app's
 * GET /api/v2/config/app-info endpoint.
 */
class ContactInfoTest extends TestCase
{
    use RefreshDatabase;

    private function setUpSettings(array $overrides = []): void
    {
        $defaults = [
            'contact_company_name' => 'He Medical Clinic',
            'contact_support_email' => 'info@heclinic.com',
            'contact_phone' => '+60 11-6720 8860',
            'contact_website' => 'https://hemedicalclinic.com',
            'contact_address' => 'No. 12, Jalan Pahlawan, Kuala Lumpur',
            'contact_operating_hours' => '["Mon-Fri: 8am - 8pm"]',
            'about_app_description' => 'Our app description.',
            'about_app_version' => '1.0.1',
        ];

        foreach (array_merge($defaults, $overrides) as $key => $value) {
            Setting::updateOrCreate(['key' => $key], ['value' => $value]);
        }
    }

    public function test_contact_page_renders_publicly(): void
    {
        $this->setUpSettings();

        $response = $this->get('/contact');

        $response->assertOk();
        $response->assertSee('Contact Us');
        $response->assertSee('He Medical Clinic');
        $response->assertSee('info@heclinic.com');
        $response->assertSee('+60 11-6720 8860');
        $response->assertSee('https://hemedicalclinic.com');
        $response->assertSee('Mon-Fri: 8am - 8pm');
    }

    public function test_about_page_renders_publicly(): void
    {
        $this->setUpSettings();

        $response = $this->get('/about');

        $response->assertOk();
        $response->assertSee('About');
        $response->assertSee('Our app description.');
        $response->assertSee('Version 1.0.1');
        $response->assertSee('info@heclinic.com');
    }

    public function test_pages_fall_back_to_defaults_when_settings_are_missing(): void
    {
        $response = $this->get('/contact');

        $response->assertOk();
        $response->assertSee('He Medical Clinic');
        $response->assertSee('info@heclinic.com');
    }

    public function test_app_info_api_returns_contact_and_about(): void
    {
        $this->setUpSettings();

        $response = $this->getJson('/api/v2/config/app-info');

        $response->assertOk()
            ->assertJson([
                'app_name' => 'He Medical Clinic',
                'company_name' => 'He Medical Clinic',
                'support_email' => 'info@heclinic.com',
                'phone' => '+60 11-6720 8860',
                'website' => 'https://hemedicalclinic.com',
                'address' => 'No. 12, Jalan Pahlawan, Kuala Lumpur',
                'app_description' => 'Our app description.',
                'app_version' => '1.0.1',
                'operating_hours' => ['Mon-Fri: 8am - 8pm'],
            ]);
    }

    public function test_app_info_api_works_with_no_settings_seeded(): void
    {
        $response = $this->getJson('/api/v2/config/app-info');

        $response->assertOk()
            ->assertJson([
                'app_name' => 'He Medical Clinic',
                'support_email' => 'info@heclinic.com',
                'operating_hours' => [],
            ]);
    }
}
