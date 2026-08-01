<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class CmsPromotion extends Model
{
    protected $fillable = [
        'title',
        'description',
        'image',
        'cta_text',
        'cta_link',
        'promo_code',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image) {
            return null;
        }

        return Storage::disk('public')->url($this->image);
    }
}
