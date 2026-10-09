<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlatoAppointmentReminder extends Model
{
    protected $fillable = [
        'plato_appointment_id',
        'patient_plato_id',
        'offset_days',
        'sent_at',
    ];

    protected function casts(): array
    {
        return [
            'offset_days' => 'integer',
            'sent_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class, 'patient_plato_id', 'idplato');
    }
}
