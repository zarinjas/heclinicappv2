<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Stores the Apple `sub` claim so returning Sign in with Apple users can be
 * identified.
 *
 * Apple only includes `email` in the identity token the first time a user
 * authorises the app. Every later sign-in carries just `sub`, the stable
 * per-app user identifier. Matching on email alone therefore worked once and
 * failed on every subsequent attempt.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('patients', 'apple_sub')) {
            return;
        }

        Schema::table('patients', function (Blueprint $table) {
            $table->string('apple_sub', 191)->nullable()->unique()->after('email');
        });
    }

    public function down(): void
    {
        if (! Schema::hasColumn('patients', 'apple_sub')) {
            return;
        }

        Schema::table('patients', function (Blueprint $table) {
            $table->dropUnique(['apple_sub']);
            $table->dropColumn('apple_sub');
        });
    }
};
