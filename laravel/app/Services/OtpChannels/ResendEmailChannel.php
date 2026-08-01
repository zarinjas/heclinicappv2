<?php

namespace App\Services\OtpChannels;

use Illuminate\Support\Facades\Log;
use Resend\Laravel\Facades\Resend;

class ResendEmailChannel implements OtpChannel
{
    public function send(string $recipient, string $otp, string $name = ''): bool
    {
        try {
            $displayName = $name ?: 'Valued Patient';
            $fromAddress = config('mail.from.address', 'noreply@heclinic.com');
            $fromName    = config('mail.from.name', 'HE Clinic');

            Resend::emails()->send([
                'from'    => "{$fromName} <{$fromAddress}>",
                'to'      => [$recipient],
                'subject' => "Your HE Clinic verification code: {$otp}",
                'html'    => $this->buildHtml($displayName, $otp),
                'text'    => $this->buildText($displayName, $otp),
            ]);

            return true;
        } catch (\Throwable $e) {
            Log::error('ResendEmailChannel: failed to send OTP', [
                'recipient' => $recipient,
                'error'     => $e->getMessage(),
            ]);

            return false;
        }
    }

    private function buildHtml(string $name, string $otp): string
    {
        return <<<HTML
        <!DOCTYPE html>
        <html>
        <body style="font-family: sans-serif; color: #1a1a1a; padding: 32px;">
            <h2 style="color: #c0392b;">HE Clinic</h2>
            <p>Hi {$name},</p>
            <p>Use the verification code below to reset your password. This code is valid for <strong>10 minutes</strong>.</p>
            <div style="font-size: 36px; font-weight: bold; letter-spacing: 8px; margin: 24px 0; color: #c0392b;">
                {$otp}
            </div>
            <p style="color: #666; font-size: 13px;">
                If you did not request this, you can safely ignore this email.
            </p>
        </body>
        </html>
        HTML;
    }

    private function buildText(string $name, string $otp): string
    {
        return "Hi {$name},\n\nYour HE Clinic verification code is: {$otp}\n\nThis code is valid for 10 minutes.\n\nIf you did not request this, please ignore this email.";
    }
}
