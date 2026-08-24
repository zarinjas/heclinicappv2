<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Apply the clinic-wide default to every existing branch so the app
        // always has usable hours. Admins can still override per branch.
        $default = [
            'monday' => '09:00-19:00',
            'tuesday' => '09:00-19:00',
            'wednesday' => '09:00-19:00',
            'thursday' => '09:00-19:00',
            'friday' => '09:00-19:00',
            'saturday' => '09:00-16:00',
            'sunday' => '09:00-16:00',
        ];

        DB::table('branches')->update(['operating_hours' => json_encode($default)]);
    }

    public function down(): void
    {
        // No-op: reverting to per-branch values is not tracked.
    }
};
