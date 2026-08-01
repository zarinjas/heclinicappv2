<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyTransaction extends Model
{
    protected $fillable = [
        'patient_id',
        'invoice_id',
        'type',
        'points',
        'balance_after',
        'staff_id',
        'reason',
        'expires_at',
    ];

    protected $casts = [
        'points'       => 'integer',
        'balance_after' => 'integer',
        'expires_at'   => 'datetime',
    ];
}
