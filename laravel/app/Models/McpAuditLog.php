<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Records every tool the Claude/MCP client invokes so admins can see exactly
 * what the AI did (and when), including the arguments it used.
 */
class McpAuditLog extends Model
{
    protected $fillable = [
        'tool',
        'arguments',
        'status',
        'summary',
        'ip',
    ];

    protected function casts(): array
    {
        return [
            'arguments' => 'array',
        ];
    }
}
