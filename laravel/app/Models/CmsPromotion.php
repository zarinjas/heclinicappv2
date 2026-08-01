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
        'valid_from',
        'valid_until',
        'usage_limit',
        'code_unique',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'code_unique' => 'boolean',
            'valid_from' => 'date',
            'valid_until' => 'date',
            'usage_limit' => 'integer',
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
