<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoyaltyRedemption extends Model
{
    protected $fillable = [
        'patient_id',
        'reward_id',
        'redemption_code',
        'points',
        'discount_value',
        'status',
        'fulfilled_by',
        'fulfilled_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'points' => 'integer',
            'discount_value' => 'float',
            'fulfilled_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function reward(): BelongsTo
    {
        return $this->belongsTo(LoyaltyReward::class);
    }

    public function fulfiller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'fulfilled_by');
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }
}
