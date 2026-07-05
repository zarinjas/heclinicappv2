<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_documents', function (Blueprint $table) {
            $table->id();
            $table->string('patient_plato_uid');
            $table->string('filename');
            $table->string('original_name');
            $table->string('title')->nullable();
            $table->string('mime_type', 100)->default('application/pdf');
            $table->unsignedBigInteger('size_bytes')->default(0);
            $table->foreignId('uploaded_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->index('patient_plato_uid');
            $table->unique(['patient_plato_uid', 'filename']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_documents');
    }
};
