<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cms_promotions', function (Blueprint $table) {
            $table->date('valid_from')->nullable()->after('cta_link');
            $table->date('valid_until')->nullable()->after('valid_from');
            $table->unsignedInteger('usage_limit')->nullable()->after('valid_until');
            $table->boolean('code_unique')->default(false)->after('usage_limit');
        });
    }

    public function down(): void
    {
        Schema::table('cms_promotions', function (Blueprint $table) {
            $table->dropColumn(['valid_from', 'valid_until', 'usage_limit', 'code_unique']);
        });
    }
};
