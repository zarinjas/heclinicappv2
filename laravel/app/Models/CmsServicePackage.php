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
        'gallery',
        'whatsapp_number',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'gallery' => 'array',
        ];
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image) {
            return null;
        }
        return Storage::disk('public')->url($this->image);
    }

    public function getGalleryUrlsAttribute(): array
    {
        $urls = collect($this->gallery ?? [])
            ->filter()
            ->map(fn (string $path) => Storage::disk('public')->url($path))
            ->values()
            ->all();

        if (empty($urls) && $this->image_url) {
            return [$this->image_url];
        }

        return $urls;
    }
}
