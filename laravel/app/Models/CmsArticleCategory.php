<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CmsArticleCategory extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'sort_order',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    public function articles()
    {
        return $this->hasMany(CmsArticle::class, 'category_id');
    }

    protected static function booted(): void
    {
        static::creating(function (CmsArticleCategory $category) {
            if (empty($category->slug)) {
                $category->slug = Str::slug($category->name);
            }
            $category->ensureUniqueSlug();
        });

        static::updating(function (CmsArticleCategory $category) {
            if ($category->isDirty('name') && ! $category->isDirty('slug')) {
                $category->slug = Str::slug($category->name);
            }
            $category->ensureUniqueSlug();
        });
    }

    protected function ensureUniqueSlug(): void
    {
        $baseSlug = $this->slug;
        $counter = 1;
        while (static::where('slug', $this->slug)->where('id', '!=', $this->id)->exists()) {
            $this->slug = $baseSlug . '-' . $counter++;
        }
    }
}
