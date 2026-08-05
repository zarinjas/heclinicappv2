<?php

namespace App\Services;

use App\Models\Patient;
use App\Services\OtpChannels\OneSenderWhatsappChannel;
use App\Services\OtpChannels\OtpChannel;
use App\Services\OtpChannels\ResendEmailChannel;
use Illuminate\Support\Facades\Log;

class OtpService
{
    /**
     * Resolve the appropriate channel for the given type.
     */
    private function channelFor(string $type): OtpChannel
    {
        return match ($type) {
            'whatsapp' => app(OneSenderWhatsappChannel::class),
            'email'    => app(ResendEmailChannel::class),
            default    => app(ResendEmailChannel::class),
        };
    }

    /**
     * Determine the best channel and recipient based on the patient's data,
     * preferring the suggested channel first, then falling back to whatever is available.
     *
     * @return array{channel: OtpChannel, recipient: string, channel_type: string}|null
     */
    public function resolveChannel(Patient $patient, string $preferredChannel = 'email'): ?array
    {
        if ($preferredChannel === 'whatsapp' && ! empty($patient->telephone)) {
            return [
                'channel'      => $this->channelFor('whatsapp'),
                'recipient'    => $patient->telephone,
                'channel_type' => 'whatsapp',
            ];
        }

        if ($preferredChannel === 'email' && ! empty($patient->email)) {
            return [
                'channel'      => $this->channelFor('email'),
                'recipient'    => $patient->email,
                'channel_type' => 'email',
            ];
        }

        // Fallback: if preferred channel not possible, try the other
        if ($preferredChannel === 'whatsapp' && ! empty($patient->email)) {
            Log::info('OtpService: WhatsApp requested but no phone on file — falling back to email', [
                'patient_id' => $patient->id,
            ]);

            return [
                'channel'      => $this->channelFor('email'),
                'recipient'    => $patient->email,
                'channel_type' => 'email',
            ];
        }

        if ($preferredChannel === 'email' && ! empty($patient->telephone)) {
            Log::info('OtpService: Email requested but no email on file — falling back to WhatsApp', [
                'patient_id' => $patient->id,
            ]);

            return [
                'channel'      => $this->channelFor('whatsapp'),
                'recipient'    => $patient->telephone,
                'channel_type' => 'whatsapp',
            ];
        }

        Log::warning('OtpService: no valid recipient found for patient', ['id' => $patient->id]);

        return null;
    }

    /**
     * Generate a 6-digit OTP, persist it against the patient, and dispatch it
     * via the resolved channel.
     *
     * @return bool  Whether the OTP was sent successfully.
     */
    public function sendOtp(Patient $patient, string $preferredChannel = 'email'): bool
    {
        $resolved = $this->resolveChannel($patient, $preferredChannel);

        if ($resolved === null) {
            Log::warning('OtpService::sendOtp — cannot resolve channel', [
                'patient_id' => $patient->id,
            ]);

            return false;
        }

        $otp = $this->generateOtp();

        $patient->update([
            'otp_code'       => $otp,
            'otp_expires_at' => now()->addMinutes(10),
            'otp_attempts'   => 0,
        ]);

        return $resolved['channel']->send($resolved['recipient'], $otp, $patient->name);
    }

    /**
     * Send an OTP to a specific email address (used when linking a NEW email
     * that is not yet stored on the patient's record).
     *
     * @return bool  Whether the OTP was sent successfully.
     */
    public function sendOtpToEmail(Patient $patient, string $email): bool
    {
        $otp = $this->generateOtp();

        $patient->update([
            'otp_code'       => $otp,
            'otp_expires_at' => now()->addMinutes(10),
            'otp_attempts'   => 0,
        ]);

        return app(ResendEmailChannel::class)->send($email, $otp, $patient->name);
    }

    /**
     * Verify an OTP submitted by the patient.
     * On success, clears the OTP and issues a short-lived reset token.
     *
     * @return string|null  The reset token on success, null on failure.
     */
    public function verifyOtp(Patient $patient, string $submittedOtp): ?string
    {
        // Increment attempt counter
        $patient->increment('otp_attempts');

        if ($patient->otp_attempts > 5) {
            Log::warning('OtpService::verifyOtp — max attempts exceeded', [
                'patient_id' => $patient->id,
                'attempts'   => $patient->otp_attempts,
            ]);

            // Reset OTP and attempts so user must request a new code
            $patient->update([
                'otp_code'       => null,
                'otp_expires_at' => null,
                'otp_attempts'   => 0,
            ]);

            return null;
        }

        if (! $patient->isOtpValid($submittedOtp)) {
            return null;
        }

        $resetToken = bin2hex(random_bytes(32));

        $patient->update([
            'otp_code'               => null,
            'otp_expires_at'         => null,
            'otp_attempts'           => 0,
            'reset_token'            => $resetToken,
            'reset_token_expires_at' => now()->addMinutes(15),
        ]);

        return $resetToken;
    }

    private function generateOtp(): string
    {
        return str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    }
}
