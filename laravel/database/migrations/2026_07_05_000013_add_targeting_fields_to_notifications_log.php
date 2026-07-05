<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('notifications_log', function (Blueprint $table) {
            $table->date('target_date_from')->nullable()->after('target_ids');
            $table->date('target_date_to')->nullable()->after('target_date_from');
        });
    }

    public function down(): void
    {
        Schema::table('notifications_log', function (Blueprint $table) {
            $table->dropColumn(['target_date_from', 'target_date_to']);
        });
    }
};
