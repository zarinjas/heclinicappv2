<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patients', function (Blueprint $table) {
            $table->id();

            // Identity — primary identifier
            $table->string('nric', 50)->nullable()->index();
            $table->string('nric_type', 50)->nullable(); // Pink IC, Passport, Blue IC, FIN, etc.

            // Anonymous patient fallback identifier
            $table->string('telephone', 30)->nullable()->index();

            // Contact
            $table->string('email', 191)->nullable()->index();

            // Demographics
            $table->string('name', 191);
            $table->string('nationality', 100)->nullable();
            $table->date('dob')->nullable();
            $table->string('sex', 10)->nullable();
            $table->string('title', 20)->nullable();
            $table->text('address')->nullable();

            // Medical info (optional at registration)
            $table->string('allergies_select', 20)->nullable(); // No / Yes / Unknown
            $table->text('allergies')->nullable();
            $table->string('food_allergies_select', 20)->nullable();
            $table->text('food_allergies')->nullable();

            // Referral (optional)
            $table->string('referred_by', 191)->nullable();

            // Plato integration
            $table->string('idplato', 191)->nullable()->unique()->index();

            // App auth
            $table->string('password');
            $table->string('fcm_token', 191)->nullable();
            $table->timestamp('password_changed_at')->nullable();

            // OTP for forgot password
            $table->string('otp_code', 10)->nullable();
            $table->timestamp('otp_expires_at')->nullable();
            $table->string('reset_token', 191)->nullable()->index();
            $table->timestamp('reset_token_expires_at')->nullable();

            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patients');
    }
};
