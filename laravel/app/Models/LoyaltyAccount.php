<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyAccount extends Model
{
    protected $fillable = [
        'patient_id',
        'patient_nric',
        'balance',
    ];
}
