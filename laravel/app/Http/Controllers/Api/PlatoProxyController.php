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

        if (! $this->authorizesPatientScope($request, $path, $query, $body)) {
            return response()->json([
                'error' => true,
                'code' => 403,
                'message' => 'You are not authorized to access this patient\'s data.',
            ], Response::HTTP_FORBIDDEN);
        }

        $result = $this->service->proxy($method, $path, $query, $body);

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
        foreach (['patient_id', 'patientId', 'id_patient'] as $field) {
            $requestedId = $query[$field] ?? $body[$field] ?? null;

            if ($requestedId === null || $requestedId === '') {
                continue;
            }

            if (! is_scalar($requestedId) || $ownId === '' || (string) $requestedId !== $ownId) {
                return false;
            }
        }

        return true;
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
