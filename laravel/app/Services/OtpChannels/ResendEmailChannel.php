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
            $fromAddress = config('mail.from.address', 'noreply@hemedicalapps.com');
            $fromName    = config('mail.from.name', 'He Clinic Apps');
            $logoUrl     = \App\Models\Setting::where('key', 'branding_logo_url')->value('value');
            $appName     = \App\Models\Setting::where('key', 'branding_app_name')->value('value') ?? 'He Clinic Apps';

            Resend::emails()->send([
                'from'    => "{$fromName} <{$fromAddress}>",
                'to'      => [$recipient],
                'subject' => "Your {$appName} verification code: {$otp}",
                'html'    => $this->buildHtml($displayName, $otp, $logoUrl, $appName),
                'text'    => $this->buildText($displayName, $otp, $appName),
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

    private function buildHtml(string $name, string $otp, ?string $logoUrl = null, string $appName = 'He Clinic Apps'): string
    {
        // Use the uploaded branding logo if available, otherwise fall back to a text block.
        $logoHtml = $logoUrl
            ? '<img src="'.e($logoUrl).'" alt="'.e($appName).'" width="40" height="40" style="display:inline-block; border-radius:10px; object-fit:contain; vertical-align:middle; margin-right:12px;">'
            : '<div style="display:inline-block; width:40px; height:40px; background:linear-gradient(135deg, #3B8DFF 0%, #27F5A3 100%); border-radius:10px; text-align:center; line-height:40px; font-size:20px; font-weight:800; color:#ffffff; margin-right:12px; vertical-align:middle;">HE</div>';

        return <<<HTML
        <!DOCTYPE html>
        <html>
        <body style="margin:0; padding:0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f6fb;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f4f6fb; padding:32px 16px;">
                <tr><td align="center">
                    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px; background:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 4px 24px rgba(19,28,60,0.08);">
                        <!-- Header -->
                        <tr>
                            <td style="background:linear-gradient(135deg, #131C3C 0%, #1D2B5F 100%); padding:28px 32px;">
                                {$logoHtml}
                                <span style="font-size:18px; font-weight:700; color:#ffffff; vertical-align:middle; line-height:40px;">{$appName}</span>
                            </td>
                        </tr>
                        <!-- Body -->
                        <tr>
                            <td style="padding:36px 32px;">
                                <h1 style="margin:0 0 8px; font-size:22px; font-weight:700; color:#131C3C;">Verification Code</h1>
                                <p style="margin:0 0 24px; font-size:15px; line-height:1.6; color:#4a5568;">Hi {$name},<br><br>Use the code below to reset your password. This code is valid for <strong>10 minutes</strong>.</p>
                                <!-- Code box -->
                                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f4f6fb; border:1px solid #e2e8f0; border-radius:12px; padding:0;">
                                    <tr><td align="center" style="padding:24px;">
                                        <span style="font-size:36px; font-weight:800; letter-spacing:10px; color:#1D2B5F;">{$otp}</span>
                                    </td></tr>
                                </table>
                                <p style="margin:24px 0 0; font-size:13px; line-height:1.6; color:#718096;">Didn't request this? You can safely ignore this email. Your account remains secure.</p>
                            </td>
                        </tr>
                        <!-- Footer -->
                        <tr>
                            <td style="background:#f8fafc; border-top:1px solid #e2e8f0; padding:20px 32px; text-align:center;">
                                <p style="margin:0 0 4px; font-size:12px; color:#8b7380;">{$appName} &middot; Your health, simplified</p>
                                <p style="margin:0; font-size:11px; color:#a0aec0;">This is an automated message. Please do not reply.</p>
                            </td>
                        </tr>
                    </table>
                </td></tr>
            </table>
        </body>
        </html>
        HTML;
    }

    private function buildText(string $name, string $otp, string $appName = 'He Clinic Apps'): string
    {
        return "Hi {$name},\n\nYour {$appName} verification code is: {$otp}\n\nThis code is valid for 10 minutes.\n\nIf you did not request this, please ignore this email.";
    }
}
