<?php

namespace App\Services\OtpChannels;

use App\Models\Patient;
use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * OneSender WhatsApp OTP channel.
 *
 * Configuration (checked in order):
 *   1. Database settings (`onesender_url` / `onesender_key`) — editable in
 *      the admin panel, deploy-safe.
 *   2. .env (ONESENDER_URL + ONESENDER_KEY).
 *
 * OneSender API docs: https://onesender.net
 */
class OneSenderWhatsappChannel implements OtpChannel
{
    public function send(string $recipient, string $otp, string $name = ''): bool
    {
        $url = $this->setting('onesender_url', config('services.onesender.url'));
        $key = $this->setting('onesender_key', config('services.onesender.key'));

        if (empty($key) || empty($url)) {
            Log::warning('OneSenderWhatsappChannel: ONESENDER_KEY/URL not configured. '
                .'Add them in the admin panel (Settings → WhatsApp) or in the server .env.');

            return false;
        }

        // Normalise to E.164 (e.g. 012-9999999 -> 60129999999). Sending a
        // leading-0 local number raw makes the gateway misread it as another
        // country code (e.g. 62 for Indonesia), so the OTP never arrives.
        $recipient = Patient::normalisePhone($recipient);

        if (empty($recipient)) {
            Log::warning('OneSenderWhatsappChannel: empty recipient after normalisation.');

            return false;
        }

        try {
            $whatsappNumber = $this->setting('onesender_clinic_whatsapp', config('services.onesender.clinic_whatsapp', '601167208860'));
            $contactLink = "https://wa.me/{$whatsappNumber}";

            $message = "Hi {$name},\n\n"
                ."Your HE Clinic verification code is: *{$otp}*\n\n"
                ."This code is valid for 10 minutes.\n\n"
                ."If you did not request this, please ignore this message.\n\n"
                ."Need help? Tap here to contact us: {$contactLink}";

            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$key,
            ])->post($url, [
                'recipient_type' => 'individual',
                'to' => $recipient,
                'type' => 'text',
                'text' => ['body' => $message],
            ]);

            if ($response->successful() && $response->json('code') === 200) {
                return true;
            }

            Log::warning('OneSenderWhatsappChannel: unexpected response', [
                'recipient' => $recipient,
                'response' => $response->json(),
            ]);

            return false;
        } catch (\Throwable $e) {
            Log::error('OneSenderWhatsappChannel: failed to send OTP', [
                'recipient' => $recipient,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    private function setting(string $key, ?string $default): ?string
    {
        $value = Setting::where('key', $key)->value('value');

        return $value !== null && $value !== '' ? $value : $default;
    }
}
