<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loyalty_transactions', function (Blueprint $table) {
            $table->id();
            $table->string('patient_id', 100)->index();
            $table->string('invoice_id', 100)->nullable()->index();
            $table->enum('type', ['earn', 'redeem', 'expire', 'adjust']);
            $table->integer('points');
            $table->integer('balance_after');
            $table->unsignedBigInteger('staff_id')->nullable();
            $table->text('reason')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->unique(['invoice_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loyalty_transactions');
    }
};
