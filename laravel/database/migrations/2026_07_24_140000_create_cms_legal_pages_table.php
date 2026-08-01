<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cms_legal_pages', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();        // 'privacy' or 'terms'
            $table->string('title');
            $table->date('last_updated')->nullable();
            $table->json('sections')->nullable();     // [{heading, body}, ...]
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index('slug');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cms_legal_pages');
    }
};
