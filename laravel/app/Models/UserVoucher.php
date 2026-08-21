<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserVoucher extends Model
{
    protected $fillable = [
        'patient_id',
        'promotion_id',
        'code',
        'expires_at',
        'used_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'date',
            'used_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function promotion(): BelongsTo
    {
        return $this->belongsTo(CmsPromotion::class);
    }

    /**
     * Derived lifecycle status: active → used | expired.
     */
    public function getStatusAttribute(): string
    {
        if ($this->used_at !== null) {
            return 'used';
        }

        if ($this->expires_at !== null && $this->expires_at->lt(now()->startOfDay())) {
            return 'expired';
        }

        return 'active';
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }
}
