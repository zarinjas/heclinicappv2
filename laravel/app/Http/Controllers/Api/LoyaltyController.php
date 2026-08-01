<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyConfig;
use App\Models\Patient;
use App\Services\LoyaltyService;
use App\Services\PlatoProxyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

final class LoyaltyController extends Controller
{
    public function __construct(
        private readonly LoyaltyService $loyalty,
        private readonly PlatoProxyService $plato,
    ) {}

    // -------------------------------------------------------------------------
    // GET /api/v2/loyalty/balance
    // Protected. Returns the current patient's points balance + config.
    // -------------------------------------------------------------------------
    public function balance(Request $request): JsonResponse
    {
        /** @var Patient $patient */
        $patient = $request->user();

        if (empty($patient->idplato)) {
            return response()->json([
                'status'  => false,
                'message' => 'No Plato patient linked to this account.',
            ], 422);
        }

        $payload = $this->loyalty->balancePayload($patient);

        return response()->json(array_merge(['status' => true], $payload));
    }

    // -------------------------------------------------------------------------
    // GET /api/v2/loyalty/transactions?type=&page=
    // Protected. Paginated transaction history for the current patient.
    // -------------------------------------------------------------------------
    public function transactions(Request $request): JsonResponse
    {
        /** @var Patient $patient */
        $patient = $request->user();

        if (empty($patient->idplato)) {
            return response()->json([
                'status'  => false,
                'message' => 'No Plato patient linked to this account.',
            ], 422);
        }

        $result = $this->loyalty->getTransactions(
            $patient->idplato,
            $request->input('type'),
            max(1, (int) $request->input('page', 1)),
        );

        return response()->json(array_merge(['status' => true], $result));
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/loyalty/redeem  { points: int }
    // Protected. Redeems points and returns a redemption code.
    // -------------------------------------------------------------------------
    public function redeem(Request $request): JsonResponse
    {
        $request->validate([
            'points' => ['required', 'integer', 'min:1'],
        ]);

        /** @var Patient $patient */
        $patient = $request->user();

        if (empty($patient->idplato)) {
            return response()->json([
                'status'  => false,
                'message' => 'No Plato patient linked to this account.',
            ], 422);
        }

        $result = $this->loyalty->redeemPoints($patient, (int) $request->input('points'));

        $httpCode = $result['status'] ? 200 : 422;

        return response()->json($result, $httpCode);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/loyalty/webhook
    // Public. Receives Plato webhook events (invoice:upsert / invoice:finalize).
    // Responds 200 immediately to satisfy the Plato webhook contract.
    // -------------------------------------------------------------------------
    public function webhook(Request $request): JsonResponse
    {
        $secret = (string) LoyaltyConfig::value('webhook_secret', '');

        if ($secret !== '' && $request->header('X-Loyalty-Secret') !== $secret) {
            return response()->json(['status' => false, 'message' => 'Unauthorized.'], 401);
        }

        $payload = $request->json()->all();
        $event = $payload['event'] ?? null;
        $objectType = $payload['object_type'] ?? null;
        $objectId = $payload['object_id'] ?? null;

        Log::channel('plato')->info('Loyalty webhook received', [
            'event'       => $event,
            'object_type' => $objectType,
            'object_id'   => $objectId,
        ]);

        // Always ack immediately; process in the background.
        if (in_array($event, ['invoice:upsert', 'invoice:finalize'], true) || $objectType === 'invoice') {
            $this->processInvoiceEvent((string) $objectId);
        }

        return response()->json(['status' => true]);
    }

    // -------------------------------------------------------------------------
    // Internal: fetch a finalized invoice from Plato and credit points.
    // -------------------------------------------------------------------------
    private function processInvoiceEvent(string $invoiceId): void
    {
        if ($invoiceId === '') {
            return;
        }

        try {
            $result = $this->plato->proxy('GET', "invoice/{$invoiceId}", ['_nocache' => time()]);

            if (! empty($result['error'])) {
                Log::channel('plato')->warning('Loyalty webhook invoice fetch failed', [
                    'invoice_id' => $invoiceId,
                    'result'     => $result['message'] ?? 'unknown',
                ]);

                return;
            }

            $invoice = $result['data'] ?? [];

            if (is_array($invoice) && array_is_list($invoice)) {
                $invoice = $invoice[0] ?? [];
            }
            if (! is_array($invoice)) {
                $invoice = [];
            }

            $invoiceTotal = (float) ($invoice['invoice_total'] ?? $invoice['total'] ?? $invoice['amount'] ?? 0);
            $patientId = $invoice['patient_id'] ?? $invoice['patient'] ?? $invoice['_patient'] ?? null;
            $nric = $invoice['nric'] ?? null;

            $status = strtolower((string) ($invoice['status'] ?? $invoice['payment_status'] ?? ''));

            if (! in_array($status, ['', 'paid', 'finalized', 'completed', 'done'], true)) {
                Log::channel('plato')->info('Loyalty webhook: invoice not finalized, skipping', [
                    'invoice_id' => $invoiceId,
                    'status'     => $status,
                ]);

                return;
            }

            if (empty($patientId)) {
                Log::channel('plato')->warning('Loyalty webhook: invoice has no patient_id', [
                    'invoice_id' => $invoiceId,
                ]);

                return;
            }

            $this->loyalty->earnFromInvoice($invoiceId, $invoiceTotal, (string) $patientId, $nric ? (string) $nric : null);
        } catch (\Exception $e) {
            Log::channel('plato')->error('Loyalty webhook processing error', [
                'invoice_id' => $invoiceId,
                'error'      => $e->getMessage(),
            ]);
        }
    }
}
