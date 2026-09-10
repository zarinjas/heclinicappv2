<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class LoyaltyReward extends Model
{
    protected $fillable = [
        'name',
        'description',
        'image',
        'type',
        'points_cost',
        'service_package_id',
        'stock',
        'cta_text',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'points_cost' => 'integer',
            'stock' => 'integer',
            'sort_order' => 'integer',
        ];
    }

    public function servicePackage(): BelongsTo
    {
        return $this->belongsTo(CmsServicePackage::class);
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image) {
            return null;
        }

        return Storage::disk('public')->url($this->image);
    }
}
