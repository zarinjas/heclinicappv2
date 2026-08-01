<?php

namespace App\Services\OtpChannels;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * OneSender WhatsApp OTP channel.
 *
 * To enable: set OTP_CHANNEL=whatsapp in .env and configure
 * ONESENDER_URL + ONESENDER_KEY.
 *
 * OneSender API docs: https://onesender.net
 */
class OneSenderWhatsappChannel implements OtpChannel
{
    public function send(string $recipient, string $otp, string $name = ''): bool
    {
        $url = config('services.onesender.url');
        $key = config('services.onesender.key');

        if (empty($key) || empty($url)) {
            Log::warning('OneSenderWhatsappChannel: ONESENDER_KEY/URL not configured.');
            return false;
        }

        try {
            $whatsappNumber = config('services.onesender.clinic_whatsapp', '601167208860');
            $contactLink = "https://wa.me/{$whatsappNumber}";

            $message = "Hi {$name},\n\n"
                . "Your HE Clinic verification code is: *{$otp}*\n\n"
                . "This code is valid for 10 minutes.\n\n"
                . "If you did not request this, please ignore this message.\n\n"
                . "Need help? Tap here to contact us: {$contactLink}";

            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$key,
            ])->post($url, [
                'recipient_type' => 'individual',
                'to'             => $recipient,
                'type'           => 'text',
                'text'           => ['body' => $message],
            ]);

            if ($response->successful() && $response->json('code') === 200) {
                return true;
            }

            Log::warning('OneSenderWhatsappChannel: unexpected response', [
                'recipient' => $recipient,
                'response'  => $response->json(),
            ]);

            return false;
        } catch (\Throwable $e) {
            Log::error('OneSenderWhatsappChannel: failed to send OTP', [
                'recipient' => $recipient,
                'error'     => $e->getMessage(),
            ]);

            return false;
        }
    }
}
