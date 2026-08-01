<?php

namespace App\Services\OtpChannels;

interface OtpChannel
{
    /**
     * Send an OTP to the given recipient.
     *
     * @param  string  $recipient  Email address or phone number depending on channel.
     * @param  string  $otp        The generated OTP code.
     * @param  string  $name       Patient name for personalisation.
     * @return bool
     */
    public function send(string $recipient, string $otp, string $name = ''): bool;
}
