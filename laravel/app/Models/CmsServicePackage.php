<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

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
        return asset('storage/' . $this->image);
    }
}
