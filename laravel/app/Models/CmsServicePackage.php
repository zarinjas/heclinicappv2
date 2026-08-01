<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class CmsServicePackage extends Model
{
    protected $fillable = [
        'name',
        'description',
        'image',
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
