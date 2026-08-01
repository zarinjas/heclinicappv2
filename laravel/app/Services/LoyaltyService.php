<?php

namespace App\Services;

use App\Models\LoyaltyAccount;
use App\Models\LoyaltyConfig;
use App\Models\LoyaltyTransaction;
use App\Models\Patient;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

final class LoyaltyService
{
    public function __construct(
        private readonly FirebaseService $firebase,
    ) {}

    // -------------------------------------------------------------------------
    // Accounts
    // -------------------------------------------------------------------------

    public function getOrCreateAccount(string $patientId, ?string $nric = null): LoyaltyAccount
    {
        return LoyaltyAccount::firstOrCreate(
            ['patient_id' => $patientId],
            ['patient_nric' => $nric]
        );
    }

    public function balancePayload(Patient $patient): array
    {
        $account = LoyaltyAccount::where('patient_id', $patient->idplato)->first();
        $balance = $account?->balance ?? 0;

        return [
            'balance'         => $balance,
            'expiry_warning'  => $this->expiryWarning($patient->idplato),
            'config'          => $this->configPayload(),
        ];
    }

    public function configPayload(): array
    {
        return [
            'earn_rate'        => (float) LoyaltyConfig::value('earn_rate', 1),
            'redemption_rate'  => (float) LoyaltyConfig::value('redemption_rate', 0.05),
            'min_redemption'   => (int) LoyaltyConfig::value('min_redemption', 100),
            'max_per_txn'      => (int) LoyaltyConfig::value('max_per_txn', 1000),
            'expiry_months'    => (int) LoyaltyConfig::value('expiry_months', 12),
        ];
    }

    // -------------------------------------------------------------------------
    // Earn
    // -------------------------------------------------------------------------

    /**
     * Credit points for a single finalized invoice. Idempotent — a given
     * invoice can only ever earn once (enforced by UNIQUE(invoice_id, type)).
     */
    public function earnFromInvoice(
        string $invoiceId,
        float $invoiceTotal,
        string $patientId,
        ?string $nric = null,
        ?int $staffId = null,
    ): array {
        if (empty($invoiceId)) {
            return ['earned' => false, 'reason' => 'empty_invoice_id'];
        }

        if (LoyaltyTransaction::where('invoice_id', $invoiceId)
            ->where('type', 'earn')
            ->exists()) {
            return ['earned' => false, 'reason' => 'duplicate'];
        }

        $earnRate = (float) LoyaltyConfig::value('earn_rate', 1);
        $points = (int) floor(max(0, $invoiceTotal) * $earnRate);

        if ($points <= 0) {
            return ['earned' => false, 'reason' => 'zero_points'];
        }

        $expiryMonths = (int) LoyaltyConfig::value('expiry_months', 12);

        try {
            DB::transaction(function () use ($invoiceId, $invoiceTotal, $patientId, $nric, $staffId, $points, $expiryMonths) {
                $account = $this->getOrCreateAccount($patientId, $nric);

                $newBalance = $account->balance + $points;
                $account->update([
                    'balance'      => $newBalance,
                    'patient_nric' => $nric ?? $account->patient_nric,
                ]);

                LoyaltyTransaction::create([
                    'patient_id'    => $patientId,
                    'invoice_id'    => $invoiceId,
                    'type'          => 'earn',
                    'points'        => $points,
                    'balance_after' => $newBalance,
                    'staff_id'      => $staffId,
                    'expires_at'    => now()->addMonths($expiryMonths),
                ]);

                $this->mirrorToFirestore($account);
            });
        } catch (\Exception $e) {
            Log::channel('plato')->error('Loyalty earn failed', [
                'invoice_id' => $invoiceId,
                'patient_id' => $patientId,
                'error'      => $e->getMessage(),
            ]);

            return ['earned' => false, 'reason' => 'error', 'error' => $e->getMessage()];
        }

        return ['earned' => true, 'points' => $points, 'invoice_id' => $invoiceId];
    }

    // -------------------------------------------------------------------------
    // Redeem
    // -------------------------------------------------------------------------

    /**
     * Redeem points and generate a redemption code for the next invoice.
     */
    public function redeemPoints(Patient $patient, int $points): array
    {
        $account = $this->getOrCreateAccount($patient->idplato, $patient->nric);

        $min = (int) LoyaltyConfig::value('min_redemption', 100);
        $max = (int) LoyaltyConfig::value('max_per_txn', 1000);
        $rate = (float) LoyaltyConfig::value('redemption_rate', 0.05);

        if ($points < $min) {
            return ['status' => false, 'message' => "Minimum redemption is {$min} points."];
        }

        if ($points > $max) {
            return ['status' => false, 'message' => "Maximum redemption per transaction is {$max} points."];
        }

        if ($points > $account->balance) {
            return ['status' => false, 'message' => 'Insufficient points balance.'];
        }

        $code = $this->generateRedemptionCode();

        DB::transaction(function () use ($account, $patient, $points, $code, $rate) {
            $newBalance = $account->balance - $points;
            $account->update(['balance' => $newBalance]);

            LoyaltyTransaction::create([
                'patient_id'    => $patient->idplato,
                'type'          => 'redeem',
                'points'        => -$points,
                'balance_after' => $newBalance,
                'reason'        => $code,
            ]);

            $this->mirrorToFirestore($account);
        });

        return [
            'status'          => true,
            'redemption_code' => $code,
            'points'          => $points,
            'discount'        => round($points * $rate, 2),
            'balance_after'   => $account->fresh()->balance,
        ];
    }

    // -------------------------------------------------------------------------
    // Transactions
    // -------------------------------------------------------------------------

    public function getTransactions(string $patientId, ?string $type, int $page, int $perPage = 20): array
    {
        $query = LoyaltyTransaction::where('patient_id', $patientId);

        if (in_array($type, ['earn', 'redeem', 'expire', 'adjust'], true)) {
            $query->where('type', $type);
        }

        $paginator = $query->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);

        return [
            'data'       => $paginator->map(fn (LoyaltyTransaction $t) => [
                'id'            => $t->id,
                'type'          => $t->type,
                'points'        => $t->points,
                'invoice_ref'   => $t->type === 'earn' ? ($t->invoice_id ?? $t->reason) : null,
                'reason'        => $t->reason,
                'expires_at'    => $t->expires_at?->toIso8601String(),
                'created_at'    => $t->created_at->toIso8601String(),
            ])->values(),
            'current_page' => $paginator->currentPage(),
            'last_page'    => $paginator->lastPage(),
            'total'        => $paginator->total(),
        ];
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    private function expiryWarning(string $patientId): ?array
    {
        $warning = LoyaltyTransaction::selectRaw('SUM(points) as points, MIN(expires_at) as earliest')
            ->where('patient_id', $patientId)
            ->where('type', 'earn')
            ->where('points', '>', 0)
            ->whereNotNull('expires_at')
            ->whereBetween('expires_at', [now(), now()->addDays(30)])
            ->first();

        if ($warning === null || (int) ($warning->points ?? 0) <= 0 || $warning->earliest === null) {
            return null;
        }

        return [
            'points' => (int) $warning->points,
            'date'   => $warning->earliest instanceof \Carbon\Carbon
                ? $warning->earliest->toIso8601String()
                : $warning->earliest,
        ];
    }

    private function generateRedemptionCode(): string
    {
        do {
            $code = 'HEC-' . strtoupper(Str::random(4)) . '-' . now()->year;
        } while (LoyaltyTransaction::where('reason', $code)->exists());

        return $code;
    }

    private function mirrorToFirestore(LoyaltyAccount $account): void
    {
        try {
            $this->firebase->writeToFirestore(
                'loyalty_accounts',
                [
                    'patient_id' => $account->patient_id,
                    'balance'    => $account->balance,
                    'updated_at' => now()->toIso8601String(),
                ],
                $account->patient_id,
            );
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Loyalty Firestore mirror failed', [
                'patient_id' => $account->patient_id,
                'error'      => $e->getMessage(),
            ]);
        }
    }
}
