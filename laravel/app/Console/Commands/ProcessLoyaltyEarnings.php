<?php

namespace App\Console\Commands;

use App\Models\Patient;
use App\Services\LoyaltyService;
use App\Services\PlatoProxyService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class ProcessLoyaltyEarnings extends Command
{
    protected $signature = 'app:process-loyalty-earnings';
    protected $description = 'Auto-credit loyalty points for newly finalized invoices from Plato';

    public function handle(PlatoProxyService $plato, LoyaltyService $loyalty): int
    {
        $patients = Patient::whereNotNull('idplato')
            ->where('idplato', '!=', '')
            ->get();

        if ($patients->isEmpty()) {
            $this->info('No Plato-linked patients found.');

            return Command::SUCCESS;
        }

        $earned = 0;
        $skipped = 0;

        foreach ($patients as $patient) {
            try {
                $result = $plato->proxy('GET', 'invoice', [
                    'patient_id' => $patient->idplato,
                    '_nocache'   => time(),
                ]);

                if (! empty($result['error'])) {
                    Log::channel('plato')->warning('Loyalty invoice fetch failed', [
                        'patient_id' => $patient->idplato,
                        'result'     => $result['message'] ?? 'unknown',
                    ]);
                    $skipped++;

                    continue;
                }

                $invoices = $result['data'] ?? [];

                if (is_array($invoices) && ! array_is_list($invoices)) {
                    $invoices = [$invoices];
                }
                if (! is_array($invoices)) {
                    continue;
                }

                foreach ($invoices as $invoice) {
                    if (! is_array($invoice)) {
                        continue;
                    }

                    $invoiceId = $invoice['_id'] ?? $invoice['id'] ?? $invoice['invoice_id'] ?? $invoice['given_id'] ?? null;
                    $total = (float) ($invoice['invoice_total'] ?? $invoice['total'] ?? $invoice['amount'] ?? 0);

                    if (empty($invoiceId) || $total <= 0 || ! $this->isEligible($invoice)) {
                        continue;
                    }

                    $outcome = $loyalty->earnFromInvoice(
                        (string) $invoiceId,
                        $total,
                        $patient->idplato,
                        $patient->nric,
                    );

                    if (($outcome['earned'] ?? false) === true) {
                        $earned++;
                        $this->line("Earned {$outcome['points']} pts for {$patient->idplato} (invoice {$invoiceId})");
                    }
                }
            } catch (\Exception $e) {
                Log::channel('plato')->error('Loyalty processing error', [
                    'patient_id' => $patient->idplato,
                    'error'      => $e->getMessage(),
                ]);
                $skipped++;
            }
        }

        $this->info("Loyalty earnings processed: {$earned} new, {$skipped} skipped/failed.");

        return Command::SUCCESS;
    }

    /**
     * Only finalized/paid invoices earn points. Invoices explicitly in a
     * non-final state (draft, open, pending, unpaid, cancelled, void) are
     * skipped; invoices with no status field are treated as eligible.
     */
    private function isEligible(array $invoice): bool
    {
        $status = strtolower((string) ($invoice['status'] ?? $invoice['payment_status'] ?? ''));

        if ($status === '') {
            return true;
        }

        return ! in_array($status, ['draft', 'open', 'pending', 'unpaid', 'cancelled', 'void', 'refunded'], true);
    }
}
