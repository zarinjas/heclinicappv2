<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('patient_documents', function (Blueprint $table) {
            $table->string('source', 20)->default('admin')->after('title');
            $table->unsignedBigInteger('uploaded_by')->nullable()->change();
            $table->foreignId('branch_id')->nullable()->constrained('branches')->nullOnDelete()->after('uploaded_by');
            $table->string('patient_name')->nullable()->after('branch_id');
            $table->string('patient_nric')->nullable()->after('patient_name');
            $table->string('patient_phone')->nullable()->after('patient_nric');
            $table->string('email_sent_to')->nullable()->after('patient_phone');
        });
    }

    public function down(): void
    {
        Schema::table('patient_documents', function (Blueprint $table) {
            $table->dropConstrainedForeignId('branch_id');
            $table->dropColumn(['source', 'patient_name', 'patient_nric', 'patient_phone', 'email_sent_to']);
            $table->unsignedBigInteger('uploaded_by')->nullable(false)->change();
        });
    }
};
