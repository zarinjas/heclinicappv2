<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    public function up(): void
    {
        $patients = DB::table('patients')
            ->whereNotNull('telephone')
            ->where('telephone', '!=', '')
            ->get(['id', 'telephone']);

        $updated = 0;

        foreach ($patients as $patient) {
            $normalised = $this->normalisePhone($patient->telephone);

            if ($normalised !== $patient->telephone) {
                DB::table('patients')
                    ->where('id', $patient->id)
                    ->update(['telephone' => $normalised]);

                $updated++;
            }
        }

        Log::info('normalize_patient_phone_numbers migration complete', [
            'total' => $patients->count(),
            'updated' => $updated,
        ]);
    }

    public function down(): void
    {
        // No reverse — the old format cannot be reliably restored.
    }

    /**
     * Same logic as Patient::normalisePhone so the migration stays self-contained
     * even if the model evolves.
     */
    private function normalisePhone(string $phone): string
    {
        $cleaned = preg_replace('/[^\d+]/', '', $phone);

        if (str_starts_with($cleaned, '+')) {
            return ltrim($cleaned, '+');
        }

        if (preg_match('/^0\d{8,10}$/', $cleaned)) {
            return '60'.substr($cleaned, 1);
        }

        return $cleaned;
    }
};
