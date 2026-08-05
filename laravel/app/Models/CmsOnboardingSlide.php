<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class CmsOnboardingSlide extends Model
{
    protected $table = 'cms_onboarding_slides';

    public const DEFAULT_GRADIENT_START = '#3B8DFF';
    public const DEFAULT_GRADIENT_END = '#27F5A3';

    protected $fillable = ['title', 'subtitle', 'image', 'gradient_start', 'gradient_end', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image) {
            return null;
        }

        return Storage::disk('public')->url($this->image);
    }
}
