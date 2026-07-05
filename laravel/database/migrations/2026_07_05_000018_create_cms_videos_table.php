<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cms_videos', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('tiktok_url', 500);
            $table->string('thumbnail_url', 500);
            $table->string('tiktok_author', 100)->nullable();
            $table->enum('status', ['draft', 'published'])->default('draft');
            $table->integer('sort_order')->default(0);
            $table->timestamp('published_at')->nullable();
            $table->integer('created_by')->nullable();
            $table->timestamps();
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cms_videos');
    }
};
