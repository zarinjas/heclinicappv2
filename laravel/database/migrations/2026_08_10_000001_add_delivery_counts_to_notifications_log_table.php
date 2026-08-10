<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Track real delivery outcomes per notification.
 *
 * Previously `status` was written as 'sent' unconditionally, so the admin UI
 * reported success even when nothing was delivered. These counters let the UI
 * show how many devices actually received a push.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('notifications_log', function (Blueprint $table) {
            $table->unsignedInteger('delivered_count')->default(0)->after('status');
            $table->unsignedInteger('failed_count')->default(0)->after('delivered_count');
        });
    }

    public function down(): void
    {
        Schema::table('notifications_log', function (Blueprint $table) {
            $table->dropColumn(['delivered_count', 'failed_count']);
        });
    }
};
