<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('plato_appointment_reminders', function (Blueprint $table) {
            $table->id();

            // Plato appointment this reminder was sent for.
            $table->string('plato_appointment_id', 191)->index();

            // Local app patient (by Plato id) the reminder was targeted at.
            $table->string('patient_plato_id', 191)->nullable()->index();

            // How many days before the appointment the reminder was sent (3 or 1).
            $table->unsignedSmallInteger('offset_days');

            $table->timestamp('sent_at')->nullable();
            $table->timestamps();

            // One reminder per appointment per offset — makes repeated runs
            // idempotent. Explicit short name: MySQL caps identifiers at 64
            // chars and the auto-generated name would exceed it.
            $table->unique(['plato_appointment_id', 'offset_days'], 'plato_appt_reminders_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('plato_appointment_reminders');
    }
};
