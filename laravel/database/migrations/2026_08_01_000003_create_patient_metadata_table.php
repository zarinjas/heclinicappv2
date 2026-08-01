<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_metadata', function (Blueprint $table) {
            $table->id();
            $table->string('patient_plato_uid')->unique()->index();
            $table->text('notes')->nullable();
            $table->json('tags')->nullable();
            $table->string('status')->nullable();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_metadata');
    }
};
