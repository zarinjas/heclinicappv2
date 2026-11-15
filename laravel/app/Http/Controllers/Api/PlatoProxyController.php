<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PlatoProxyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\RateLimiter;

final class PlatoProxyController extends Controller
{
    /**
     * Plato paths the patient app must never be able to read, whatever app
     * version the caller runs.
     *
     * Both "casenote" (clinical case notes) and "admin note" are P&C clinic
     * records that must never surface in the patient app. Older app builds
     * still request them directly, so they are blocked here at the proxy edge
     * rather than relying on a client-side update.
     */
    private const FORBIDDEN_PATH_PATTERNS = [
        '#^patient/[^/]+/notes?(/|$)#i',
        '#^patient/[^/]+/casenotes?(/|$)#i',
        '#^patient/[^/]+/adminnotes?(/|$)#i',
        '#^patient/[^/]+/admin(/|$)#i',
    ];

    /**
     * Endpoints that return a patient's own records. When the patient scope is
     * omitted Plato returns EVERY patient's records for these, so a matching
     * `patient_id`-style parameter is mandatory. Non-patient endpoints
     * (appointment/slots, appointment/codes, appointments/calendars) are
     * deliberately excluded.
     */
    private const PATIENT_SCOPED_PATH_PATTERNS = [
        '#^letters?$#i',
        '#^invoices?$#i',
        '#^payments?$#i',
        '#^appointment$#i',
        '#^appointment/[^/]+/(cancel|update|reschedule|delete)$#i',
    ];

    private PlatoProxyService $service;

    public function __construct(PlatoProxyService $service)
    {
        $this->service = $service;
    }

    /**
     * Proxy all requests to the Plato API.
     */
    public function proxy(Request $request, string $path): JsonResponse
    {
        $key = 'plato-proxy:'.($request->ip() ?? 'unknown');

        if (RateLimiter::tooManyAttempts($key, $this->service->proxyRateLimit())) {
            return response()->json([
                'error' => true,
                'code' => 429,
                'message' => 'Too many proxy requests. Please slow down.',
            ], Response::HTTP_TOO_MANY_REQUESTS);
        }

        RateLimiter::hit($key, 60);

        $method = strtoupper($request->method());
        $query = $request->query();
        $body = $request->all();

        if ($this->isForbiddenPath($path)) {
            return response()->json([
                'error' => true,
                'code' => 403,
                'message' => 'This resource is not available in the patient app.',
            ], Response::HTTP_FORBIDDEN);
        }

        if (! $this->authorizesPatientScope($request, $path, $query, $body)) {
            return response()->json([
                'error' => true,
                'code' => 403,
                'message' => 'You are not authorized to access this patient\'s data.',
            ], Response::HTTP_FORBIDDEN);
        }

        $result = $this->service->proxy($method, $path, $query, $body);

        $data = $result['data'] ?? $result;
        $data = $this->stripSensitiveFields($path, $data);

        $response = response()->json(
            $data,
            $result['status'] ?? 200
        );

        if (! empty($result['headers'])) {
            foreach ($result['headers'] as $name => $value) {
                $response->header($name, $value);
            }
        }

        return $response;
    }

    /**
     * Redeem / validate a voucher code via the configured Plato endpoint.
     */
    public function voucherRedeem(Request $request): JsonResponse
    {
        $request->validate([
            'code' => ['required', 'string', 'max:50'],
        ]);

        $key = 'plato-voucher:'.($request->ip() ?? 'unknown');

        if (RateLimiter::tooManyAttempts($key, $this->service->proxyRateLimit())) {
            return response()->json([
                'error' => true,
                'code' => 429,
                'message' => 'Too many requests. Please slow down.',
            ], Response::HTTP_TOO_MANY_REQUESTS);
        }

        RateLimiter::hit($key, 60);

        $result = $this->service->voucherRedeem($request->input('code'), $request->except(['code']));

        $response = response()->json(
            $result['data'] ?? $result,
            $result['status'] ?? 200
        );

        if (! empty($result['headers'])) {
            foreach ($result['headers'] as $name => $value) {
                $response->header($name, $value);
            }
        }

        return $response;
    }

    /**
     * Whether the requested Plato path is blanket-denied for the patient app.
     */
    private function isForbiddenPath(string $path): bool
    {
        $normalisedPath = ltrim($path, '/');

        foreach (self::FORBIDDEN_PATH_PATTERNS as $pattern) {
            if (preg_match($pattern, $normalisedPath) === 1) {
                return true;
            }
        }

        return false;
    }

    /**
     * Ensure a caller can only reach Plato data belonging to their own patient record.
     *
     * The proxy forwards arbitrary paths using a privileged server-side Plato token,
     * so without this check any authenticated patient could read another patient's
     * clinical notes, letters, invoices or appointments by changing the id.
     */
    private function authorizesPatientScope(Request $request, string $path, array $query, array $body): bool
    {
        $ownId = (string) ($request->user()->idplato ?? '');
        $normalisedPath = ltrim($path, '/');

        // Path-identified patient resources, e.g. patient/{id}, patient/{id}/note.
        if (preg_match('#^patient/([^/?]+)#i', $normalisedPath, $matches) === 1) {
            $requestedId = urldecode($matches[1]);

            if ($ownId === '' || $requestedId !== $ownId) {
                return false;
            }
        }

        // Query/body-identified patient resources, e.g. letter?patient_id={id}.
        $scopeSupplied = false;
        foreach (['patient_id', 'patientId', 'id_patient'] as $field) {
            $requestedId = $query[$field] ?? $body[$field] ?? null;

            if ($requestedId === null || $requestedId === '') {
                continue;
            }

            $scopeSupplied = true;

            if (! is_scalar($requestedId) || $ownId === '' || (string) $requestedId !== $ownId) {
                return false;
            }
        }

        // Endpoints that return every patient's data when the scope is omitted
        // must carry a matching patient id.
        if ($this->requiresPatientScope($normalisedPath) && ! $scopeSupplied) {
            return false;
        }

        return true;
    }

    /**
     * Whether the path is a patient-data endpoint that must carry a scope.
     */
    private function requiresPatientScope(string $path): bool
    {
        foreach (self::PATIENT_SCOPED_PATH_PATTERNS as $pattern) {
            if (preg_match($pattern, $path) === 1) {
                return true;
            }
        }

        return false;
    }

    /**
     * Remove clinical / administrative note fields from a patient record so
     * casenote and admin note never reach the patient app, even though the app
     * does not display them. Only the bare patient record endpoint is affected.
     */
    private function stripSensitiveFields(string $path, mixed $data): mixed
    {
        $normalisedPath = ltrim($path, '/');

        // Only `patient/{id}` itself — not subresources that already have their
        // own access rules.
        if (preg_match('#^patient/[^/]+/?$#i', $normalisedPath) !== 1) {
            return $data;
        }

        if (! is_array($data)) {
            return $data;
        }

        // Plato returns the record as a single-element list.
        if (array_is_list($data)) {
            return array_map(fn ($row) => $this->stripSensitiveFieldsFromRecord($row), $data);
        }

        return $this->stripSensitiveFieldsFromRecord($data);
    }

    private function stripSensitiveFieldsFromRecord(mixed $record): mixed
    {
        if (! is_array($record)) {
            return $record;
        }

        foreach (array_keys($record) as $key) {
            $lower = strtolower((string) $key);

            if (str_contains($lower, 'note') || $lower === 'admin') {
                unset($record[$key]);
            }
        }

        return $record;
    }

    /**
     * Health check for the proxy layer — does NOT proxy to Plato.
     */
    public function health(): JsonResponse
    {
        $status = $this->service->healthCheck();

        return response()->json($status);
    }
}
