<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Per-patient notification inbox.
 *
 * The app previously read its inbox straight from the Firestore `historynotif`
 * collection, but the security rules deny both the write (`allow create: if
 * false`) and the read (which requires a Firebase Auth uid the app never has,
 * since it authenticates with Sanctum). Storing the inbox in MySQL and serving
 * it over the existing authenticated API removes that dependency entirely.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_notifications', function (Blueprint $table) {
            $table->id();
            // Plato patient id — the identifier the app already holds.
            $table->string('patient_plato_id', 100)->index();
            $table->string('type', 50)->default('manual');
            $table->string('title');
            $table->text('body');
            $table->string('deep_link', 100)->nullable();
            $table->string('image_url')->nullable();
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            // Inbox query: this patient's notifications, newest first.
            $table->index(['patient_plato_id', 'created_at']);
            // Unread badge count.
            $table->index(['patient_plato_id', 'read_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_notifications');
    }
};
