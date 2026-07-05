<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationLog extends Model
{
    protected $table = 'notifications_log';

    protected $fillable = [
        'type',
        'title',
        'body',
        'target_type',
        'target_ids',
        'channels',
        'status',
        'sent_at',
    ];

    protected function casts(): array
    {
        return [
            'target_ids' => 'array',
            'channels' => 'array',
            'sent_at' => 'datetime',
        ];
    }
}
