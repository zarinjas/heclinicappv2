<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CmsLegalPage extends Model
{
    protected $table = 'cms_legal_pages';

    protected $fillable = ['slug', 'title', 'last_updated', 'sections', 'is_active'];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'last_updated' => 'date',
            'sections' => 'array',
        ];
    }
}
