<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CmsOnboardingSlide extends Model
{
    protected $table = 'cms_onboarding_slides';

    protected $fillable = ['title', 'subtitle', 'gradient_start', 'gradient_end', 'is_active', 'sort_order'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'sort_order' => 'integer'];
    }
}
