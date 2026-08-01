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
            Schema::table($table, function (Blueprint $blueprint) {
                $blueprint->dropIndex(['sort_order']);
                $blueprint->dropColumn('sort_order');
            });
        }
    }

    public function down(): void
    {
        foreach (self::TABLES as $table) {
            Schema::table($table, function (Blueprint $blueprint) {
                $blueprint->integer('sort_order')->default(0);
                $blueprint->index('sort_order');
            });
        }
    }
};
