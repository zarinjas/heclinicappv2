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
     * Normalise a phone number to E.164-ish format (digits only, leading +).
     * Supports international numbers — does NOT assume +60.
     */
    public static function normalisePhone(string $phone): string
    {
        // Strip everything except digits and leading +
        $cleaned = preg_replace('/[^\d+]/', '', $phone);

        // If already has +, keep as-is (strip the + for storage consistency)
        if (str_starts_with($cleaned, '+')) {
            return ltrim($cleaned, '+');
        }

        // Malaysian local format: 01x -> 601x
        if (preg_match('/^0\d{8,10}$/', $cleaned)) {
            return '6' . $cleaned;
        }

        // Otherwise return digits as-is (international, already has country code)
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

        // NRIC / IC: 12 consecutive digits (Malaysian), or alphanumeric passport
        $digits = preg_replace('/\D/', '', $identifier);
        if (strlen($digits) === 12 && ctype_digit($digits)) {
            return 'nric';
        }

        // Default: treat as phone
        return 'phone';
    }
}
