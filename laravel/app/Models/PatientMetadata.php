<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PatientMetadata extends Model
{
    protected $fillable = [
        'patient_plato_uid',
        'notes',
        'tags',
        'status',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'tags' => 'array',
        ];
    }

    public function updatedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }
}
