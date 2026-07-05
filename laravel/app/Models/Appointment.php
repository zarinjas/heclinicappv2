<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Appointment extends Model
{
    protected $fillable = [
        'plato_appointment_id',
        'patient_name',
        'patient_nric',
        'patient_phone',
        'patient_plato_id',
        'branch_id',
        'branch_name',
        'doctor_id',
        'doctor_name',
        'appointment_date',
        'appointment_time',
        'calendar_color_id',
        'notes',
        'status',
        'plato_response',
        'notified_at',
        'reminded_24h_at',
        'reminded_1h_at',
    ];

    protected function casts(): array
    {
        return [
            'appointment_date' => 'date',
            'plato_response' => 'array',
            'notified_at' => 'datetime',
            'reminded_24h_at' => 'datetime',
            'reminded_1h_at' => 'datetime',
        ];
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function doctor(): BelongsTo
    {
        return $this->belongsTo(Doctor::class);
    }
}
