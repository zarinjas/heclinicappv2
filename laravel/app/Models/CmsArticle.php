<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CmsArticle extends Model
{
    protected $fillable = [
        'title',
        'slug',
        'body',
        'excerpt',
        'featured_image',
        'category',
        'author_name',
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

    public function getFeaturedImageUrlAttribute(): ?string
    {
        if (! $this->featured_image) {
            return null;
        }
        return asset('storage/' . $this->featured_image);
    }

    public function getExcerptAttribute(?string $value): ?string
    {
        if ($value) {
            return $value;
        }
        return Str::limit(strip_tags($this->body), 200);
    }

    protected static function booted(): void
    {
        static::creating(function (CmsArticle $article) {
            if (empty($article->slug)) {
                $article->slug = Str::slug($article->title);
            }
            $article->ensureUniqueSlug();
        });

        static::updating(function (CmsArticle $article) {
            if ($article->isDirty('title') && ! $article->isDirty('slug')) {
                $article->slug = Str::slug($article->title);
            }
            $article->ensureUniqueSlug();
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
