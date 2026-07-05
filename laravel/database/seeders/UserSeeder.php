<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $adminEmail = env('ADMIN_EMAIL', 'admin@heclinic.com');
        $adminPassword = env('ADMIN_PASSWORD', 'password');

        if (! User::where('email', $adminEmail)->exists()) {
            User::create([
                'name' => 'Super Admin',
                'email' => $adminEmail,
                'password' => Hash::make($adminPassword),
                'role' => 'super_admin',
                'email_verified_at' => now(),
            ]);
        }

        if (! User::where('email', 'staff@heclinic.com')->exists()) {
            User::create([
                'name' => 'Staff User',
                'email' => 'staff@heclinic.com',
                'password' => Hash::make('password'),
                'role' => 'staff',
                'email_verified_at' => now(),
            ]);
        }
    }
}
