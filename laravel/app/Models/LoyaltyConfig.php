<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

class LoyaltyConfig extends Model
{
    protected $table = 'loyalty_config';

    protected $fillable = [
        'key_name',
        'value',
        'updated_by',
    ];

    /**
     * Cached getter for a single config key.
     */
    public static function value(string $key, mixed $default = null): mixed
    {
        return Cache::remember("loyalty_config:{$key}", 300, function () use ($key, $default) {
            $row = self::where('key_name', $key)->value('value');

            return $row ?? $default;
        });
    }

    /**
     * Cached getter for all config keys as an associative array.
     */
    public static function allValues(): array
    {
        return Cache::remember('loyalty_config:all', 300, function () {
            return self::pluck('value', 'key_name')->toArray();
        });
    }

    public static function flushCache(): void
    {
        Cache::forget('loyalty_config:all');
        foreach (self::pluck('key_name') as $key) {
            Cache::forget("loyalty_config:{$key}");
        }
    }
}
