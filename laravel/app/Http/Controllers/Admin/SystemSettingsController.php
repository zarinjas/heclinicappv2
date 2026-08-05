<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Services\AppSettingsService;
use App\Services\OtpChannels\OneSenderWhatsappChannel;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Log;
use Illuminate\View\View;

class SystemSettingsController extends Controller
{
    public function __construct(private readonly AppSettingsService $settings) {}

    public function index(): View
    {
        return view('admin.settings.system', [
            'settings' => [
                'app_url' => $this->settings->appUrl(),
                'firebase_project_id' => $this->settings->firebaseProjectId(),
                'firebase_web_api_key_configured' => $this->settings->firebaseWebApiKeyConfigured(),
                'mail_mailer' => $this->settings->mailMailer(),
                'mail_host' => $this->settings->mailHost(),
                'mail_port' => $this->settings->mailPort(),
                'mail_username' => $this->settings->mailUsername(),
                'mail_password_configured' => $this->settings->mailPasswordConfigured(),
                'mail_encryption' => $this->settings->mailEncryption(),
                'mail_from_address' => $this->settings->mailFromAddress(),
                'mail_from_name' => $this->settings->mailFromName(),
            ],
            'whatsapp' => [
                'onesender_url' => $this->getSetting('onesender_url', config('services.onesender.url')),
                'onesender_configured' => Setting::where('key', 'onesender_key')->exists()
                    || ! empty(config('services.onesender.key')),
                'clinic_whatsapp' => $this->getSetting('onesender_clinic_whatsapp', config('services.onesender.clinic_whatsapp', '601167208860')),
            ],
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'app_url' => ['nullable', 'url', 'max:255'],
            'firebase_project_id' => ['nullable', 'string', 'max:191'],
            'firebase_web_api_key' => ['nullable', 'string', 'max:500'],
            'mail_mailer' => ['required', 'in:smtp,log'],
            'mail_host' => ['nullable', 'string', 'max:255'],
            'mail_port' => ['nullable', 'integer', 'min:1', 'max:65535'],
            'mail_username' => ['nullable', 'string', 'max:255'],
            'mail_password' => ['nullable', 'string', 'max:500'],
            'mail_encryption' => ['nullable', 'in:tls,ssl,none'],
            'mail_from_address' => ['nullable', 'email', 'max:191'],
            'mail_from_name' => ['nullable', 'string', 'max:191'],
            // WhatsApp OTP (OneSender)
            'onesender_url' => ['nullable', 'url', 'max:255'],
            'onesender_key' => ['nullable', 'string', 'max:500'],
            'onesender_clinic_whatsapp' => ['nullable', 'string', 'max:20'],
        ]);

        $this->settings->save($validated);

        // WhatsApp OTP settings (deploy-safe; key encrypted)
        if (! empty($validated['onesender_url'])) {
            $this->saveSetting('onesender_url', $validated['onesender_url']);
        }
        if (! empty($validated['onesender_key'])) {
            $this->saveSetting('onesender_key', Crypt::encryptString($validated['onesender_key']));
        }
        if (! empty($validated['onesender_clinic_whatsapp'])) {
            $this->saveSetting('onesender_clinic_whatsapp', $validated['onesender_clinic_whatsapp']);
        }

        $this->settings->applyToConfig();

        return redirect()
            ->route('admin.settings.system')
            ->with('success', 'System settings saved successfully.');
    }

    /**
     * Send a live test OTP via WhatsApp to prove the OneSender connection works.
     */
    public function testWhatsapp(Request $request): RedirectResponse
    {
        $phone = $request->input('phone');

        if (empty($phone)) {
            return redirect()
                ->route('admin.settings.system')
                ->with('error', 'Enter a phone number to send the test OTP to.');
        }

        $channel = app(OneSenderWhatsappChannel::class);
        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $sent = $channel->send($phone, $otp, 'HE Clinic Test');

        return redirect()
            ->route('admin.settings.system')
            ->with($sent ? 'success' : 'error', $sent
                ? "WhatsApp test sent to {$phone} with code {$otp}. Check your device."
                : "WhatsApp test FAILED to {$phone}. Check the OneSender URL and API key, then check the server logs.");
    }

    private function getSetting(string $key, mixed $default): ?string
    {
        return Setting::where('key', $key)->value('value') ?? $default;
    }

    private function saveSetting(string $key, string $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'description' => "System setting: $key"]
        );
    }
}
