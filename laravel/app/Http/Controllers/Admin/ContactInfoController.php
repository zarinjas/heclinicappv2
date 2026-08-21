<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * Manages the contact & about information shown on the public /contact and
 * /about pages and in the mobile app's About screen. Values are stored in the
 * `settings` table.
 */
class ContactInfoController extends Controller
{
    public function index(): View
    {
        $contact = [
            'company_name' => $this->get('contact_company_name', 'He Medical Clinic'),
            'support_email' => $this->get('contact_support_email', 'info@heclinic.com'),
            'phone' => $this->get('contact_phone', '+60 11-6720 8860'),
            'website' => $this->get('contact_website', 'https://hemedicalclinic.com'),
            'address' => $this->get('contact_address', ''),
            'operating_hours' => $this->get('contact_operating_hours', '[]'),
            'about_description' => $this->get('about_app_description', ''),
            'app_version' => $this->get('about_app_version', '1.0.1'),
        ];

        return view('admin.settings.contact-info', compact('contact'));
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'company_name' => ['required', 'string', 'max:150'],
            'support_email' => ['required', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'website' => ['nullable', 'url', 'max:255'],
            'address' => ['nullable', 'string', 'max:500'],
            'operating_hours' => ['nullable', 'string', 'max:2000', function (string $attribute, mixed $value, \Closure $fail) {
                if ($value === null || $value === '') {
                    return;
                }
                $decoded = json_decode($value, true);
                if (! is_array($decoded)) {
                    $fail('The operating hours must be a valid JSON array.');
                }
            }],
            'about_description' => ['nullable', 'string', 'max:2000'],
            'app_version' => ['nullable', 'string', 'max:30'],
        ]);

        $this->save('contact_company_name', $validated['company_name']);
        $this->save('contact_support_email', $validated['support_email']);
        $this->save('contact_phone', $validated['phone'] ?? '');
        $this->save('contact_website', $validated['website'] ?? '');
        $this->save('contact_address', $validated['address'] ?? '');
        $this->save('contact_operating_hours', $validated['operating_hours'] ?? '[]');
        $this->save('about_app_description', $validated['about_description'] ?? '');
        $this->save('about_app_version', $validated['app_version'] ?? '1.0.1');

        return redirect()
            ->route('admin.settings.contact-info')
            ->with('success', 'Contact & About information saved successfully.');
    }

    private function get(string $key, string $default): string
    {
        $value = Setting::where('key', $key)->value('value');

        return ($value === null || $value === '') ? $default : (string) $value;
    }

    private function save(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "Contact & About setting: $key"]
        );
    }
}
