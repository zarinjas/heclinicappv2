<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // This table already exists on deployed environments: Sanctum was in
        // use long before its migration was committed to the repo. Creating it
        // unconditionally would abort `artisan migrate` on those databases, so
        // only create it where it is genuinely missing (e.g. fresh installs
        // and the in-memory test database).
        if (Schema::hasTable('personal_access_tokens')) {
            return;
        }

        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->morphs('tokenable');
            $table->text('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable()->index();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Intentionally a no-op. Rolling this migration back on a deployed
        // environment would destroy every active login session, and this
        // migration may not have been the thing that created the table.
    }
};
