<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CmsVideo extends Model
{
    protected $fillable = [
        'title',
        'tiktok_url',
        'thumbnail_url',
        'tiktok_author',
        'status',
        'sort_order',
        'published_at',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'published_at' => 'datetime',
        ];
    }
}
