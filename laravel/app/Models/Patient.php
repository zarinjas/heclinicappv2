<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Patient extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'nric',
        'nric_type',
        'telephone',
        'email',
        'pending_email',
        'name',
        'nationality',
        'dob',
        'sex',
        'title',
        'address',
        'allergies_select',
        'allergies',
        'food_allergies_select',
        'food_allergies',
        'referred_by',
        'idplato',
        'password',
        'fcm_token',
        'password_changed_at',
        'otp_code',
        'otp_expires_at',
        'otp_attempts',
        'reset_token',
        'reset_token_expires_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'otp_code',
        'reset_token',
    ];

    protected $casts = [
        'dob'                      => 'date',
        'password_changed_at'      => 'datetime',
        'otp_expires_at'           => 'datetime',
        'otp_attempts'             => 'integer',
        'reset_token_expires_at'   => 'datetime',
    ];

    /**
     * Determine whether this patient registered anonymously (no NRIC/passport).
     */
    public function isAnonymous(): bool
    {
        return empty($this->nric);
    }

    /**
     * Determine whether the patient has changed their password at least once.
     */
    public function hasChangedPassword(): bool
    {
        return $this->password_changed_at !== null;
    }

    /**
     * Check if a stored OTP is still valid.
     */
    public function isOtpValid(string $code): bool
    {
        return $this->otp_code === $code
            && $this->otp_expires_at !== null
            && $this->otp_expires_at->isFuture();
    }

    /**
     * Check if a reset token is still valid.
     */
    public function isResetTokenValid(string $token): bool
    {
        return $this->reset_token === $token
            && $this->reset_token_expires_at !== null
            && $this->reset_token_expires_at->isFuture();
    }

    /**
     * Normalise a phone number to E.164-ish format (digits only, no leading +).
     *
     * @param  string       $phone       Raw phone input.
     * @param  string|null  $countryCode Digits-only country code (e.g. '60'), or
     *                                   null to preserve old hardcoded behaviour.
     */
    public static function normalisePhone(string $phone, ?string $countryCode = null): string
    {
        // Strip everything except digits and leading +
        $cleaned = preg_replace('/[^\d+]/', '', $phone);

        // If already has +, strip it and return (fully international).
        if (str_starts_with($cleaned, '+')) {
            return ltrim($cleaned, '+');
        }

        // Local format (starts with 0): replace leading 0 with the country code.
        if (preg_match('/^0\d{8,10}$/', $cleaned)) {
            $code = $countryCode ?? '60';

            return $code . substr($cleaned, 1);
        }

        // Otherwise return digits as-is (international, already has country code).
        return $cleaned;
    }

    /**
     * Detect the type of login identifier supplied by the user.
     * Returns: 'nric' | 'email' | 'phone'
     */
    public static function detectIdentifierType(string $identifier): string
    {
        // Email
        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            return 'email';
        }

        // Explicit + prefix or leading 0 → always a phone number (never an NRIC).
        if (str_starts_with($identifier, '+') || str_starts_with($identifier, '0')) {
            return 'phone';
        }

        $digits = preg_replace('/\D/', '', $identifier);

        // 12 consecutive digits: could be a Malaysian NRIC OR a full-format
        // phone number with country code (e.g. 60 + 10-digit 010/011 series).
        // Use the NRIC date pattern (YYMMDD) to disambiguate.
        if (strlen($digits) === 12 && ctype_digit($digits)) {
            $month = (int) substr($digits, 2, 2);
            $day = (int) substr($digits, 4, 2);
            $looksLikeNric = $month >= 1 && $month <= 12 && $day >= 1 && $day <= 31;

            if ($looksLikeNric) {
                return 'nric';
            }

            return 'phone';
        }

        // Default: treat as phone
        return 'phone';
    }
}
