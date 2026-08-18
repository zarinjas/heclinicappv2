<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cms_clinic_info', function (Blueprint $table) {
            $table->id();
            $table->string('image');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cms_clinic_info');
    }
};
