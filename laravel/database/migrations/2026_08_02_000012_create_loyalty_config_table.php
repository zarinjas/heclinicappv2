<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loyalty_config', function (Blueprint $table) {
            $table->id();
            $table->string('key_name', 50)->unique();
            $table->string('value', 100);
            $table->unsignedBigInteger('updated_by')->nullable();
            $table->timestamps();
        });

        // Defaults seeded here so production deploy picks them up automatically.
        DB::table('loyalty_config')->insert([
            ['key_name' => 'earn_rate', 'value' => '1', 'created_at' => now(), 'updated_at' => now()],
            ['key_name' => 'redemption_rate', 'value' => '0.05', 'created_at' => now(), 'updated_at' => now()],
            ['key_name' => 'min_redemption', 'value' => '100', 'created_at' => now(), 'updated_at' => now()],
            ['key_name' => 'max_per_txn', 'value' => '1000', 'created_at' => now(), 'updated_at' => now()],
            ['key_name' => 'expiry_months', 'value' => '12', 'created_at' => now(), 'updated_at' => now()],
            ['key_name' => 'webhook_secret', 'value' => '', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('loyalty_config');
    }
};
