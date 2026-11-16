<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlatoHealthRecordEvent extends Model
{
    protected $fillable = [
        'source_key',
        'patient_plato_id',
        'record_type',
        'title',
        'notified_at',
    ];

    protected function casts(): array
    {
        return [
            'notified_at' => 'datetime',
        ];
    }
}
