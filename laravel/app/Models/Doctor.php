<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Doctor extends Model
{
    protected $fillable = [
        'user_id',
        'branch_id',
        'name',
        'specialty',
        'bio',
        'photo',
        'plato_facility_id',
        'is_visible_in_app',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_visible_in_app' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function platoCalendars(): HasMany
    {
        return $this->hasMany(PlatoCalendar::class);
    }
}
