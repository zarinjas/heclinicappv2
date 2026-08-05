<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private const TABLES = [
        'cms_sliders',
        'cms_service_packages',
        'cms_articles',
        'cms_videos',
        'cms_promotions',
        'cms_onboarding_slides',
        'cms_article_categories',
    ];

    public function up(): void
    {
        foreach (self::TABLES as $table) {
            if (! Schema::hasColumn($table, 'sort_order')) {
                continue;
            }

            // SQLite requires indexes on the column to be dropped BEFORE the
            // column itself (ALTER TABLE ... DROP COLUMN rebuilds indexes and
            // fails if the indexed column no longer exists). MySQL drops them
            // automatically, so this is a no-op there.
            $indexName = "{$table}_sort_order_index";
            try {
                Schema::table($table, function (Blueprint $blueprint) use ($indexName) {
                    $blueprint->dropIndex($indexName);
                });
            } catch (\Throwable $e) {
                // Index already gone (or named differently) — column drop below
                // is the source of truth.
            }

            Schema::table($table, function (Blueprint $blueprint) {
                $blueprint->dropColumn('sort_order');
            });
        }
    }

    public function down(): void
    {
        foreach (self::TABLES as $table) {
            if (Schema::hasColumn($table, 'sort_order')) {
                continue;
            }
            Schema::table($table, function (Blueprint $blueprint) {
                $blueprint->integer('sort_order')->default(0);
            });
        }
    }
};
