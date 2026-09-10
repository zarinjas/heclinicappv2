<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Redemption codes (generated when a patient redeems points) stay valid
        // for this many days. Admins can change it from Admin → Loyalty → Settings.
        DB::table('loyalty_config')->updateOrInsert(
            ['key_name' => 'redemption_expiry_days'],
            ['value' => '30', 'created_at' => now(), 'updated_at' => now()]
        );
    }

    public function down(): void
    {
        DB::table('loyalty_config')->where('key_name', 'redemption_expiry_days')->delete();
    }
};
