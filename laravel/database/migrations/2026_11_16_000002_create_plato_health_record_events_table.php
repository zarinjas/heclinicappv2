<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('plato_health_record_events', function (Blueprint $table) {
            $table->id();
            $table->string('source_key', 255)->unique();
            $table->string('patient_plato_id', 100)->index();
            $table->string('record_type', 30);
            $table->string('title');
            $table->timestamp('notified_at')->nullable();
            $table->timestamps();

            $table->index(['patient_plato_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('plato_health_record_events');
    }
};
