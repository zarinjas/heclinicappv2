<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Branch extends Model
{
    /**
     * Default operating hours applied to every branch unless an admin sets
     * per-day hours. Mon–Fri 9AM–7PM, Sat–Sun 9AM–4PM.
     */
    public const DEFAULT_OPERATING_HOURS = [
        'monday' => '09:00-19:00',
        'tuesday' => '09:00-19:00',
        'wednesday' => '09:00-19:00',
        'thursday' => '09:00-19:00',
        'friday' => '09:00-19:00',
        'saturday' => '09:00-16:00',
        'sunday' => '09:00-16:00',
    ];

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
