<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cms_service_packages', function (Blueprint $table) {
            $table->json('gallery')->nullable()->after('image');
            $table->string('whatsapp_number', 20)->nullable()->after('gallery');
        });
    }

    public function down(): void
    {
        Schema::table('cms_service_packages', function (Blueprint $table) {
            $table->dropColumn(['gallery', 'whatsapp_number']);
        });
    }
};
