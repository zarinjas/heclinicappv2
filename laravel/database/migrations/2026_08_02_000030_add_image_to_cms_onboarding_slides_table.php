<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cms_onboarding_slides', function (Blueprint $table) {
            $table->string('image')->nullable()->after('subtitle');
        });
    }

    public function down(): void
    {
        Schema::table('cms_onboarding_slides', function (Blueprint $table) {
            $table->dropColumn('image');
        });
    }
};
