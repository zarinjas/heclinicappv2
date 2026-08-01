<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Branch extends Model
{
    protected $fillable = [
        'name',
        'address',
        'phone',
        'email',
        'whatsapp_number',
        'image',
        'operating_hours',
        'google_maps_link',
        'plato_facility_id',
        'is_active',
        'is_visible_in_app',
    ];

    protected function casts(): array
    {
        return [
            'operating_hours' => 'array',
            'is_active' => 'boolean',
            'is_visible_in_app' => 'boolean',
        ];
    }

    public function doctors(): HasMany
    {
        return $this->hasMany(Doctor::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }
}
