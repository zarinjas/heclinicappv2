<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->string('plato_appointment_id')->nullable()->index();
            $table->string('patient_name');
            $table->string('patient_nric')->nullable();
            $table->string('patient_phone');
            $table->foreignId('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('branch_name')->nullable();
            $table->foreignId('doctor_id')->nullable()->constrained('doctors')->nullOnDelete();
            $table->string('doctor_name')->nullable();
            $table->date('appointment_date');
            $table->string('appointment_time');
            $table->string('calendar_color_id')->nullable();
            $table->text('notes')->nullable();
            $table->string('status')->default('pending')->index();
            $table->json('plato_response')->nullable();
            $table->timestamp('notified_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
