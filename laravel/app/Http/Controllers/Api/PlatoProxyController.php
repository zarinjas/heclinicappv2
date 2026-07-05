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
        $key = 'plato-proxy:' . ($request->ip() ?? 'unknown');

        if (RateLimiter::tooManyAttempts($key, (int) config('plato.proxy_rate_limit', 60))) {
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
     * Health check for the proxy layer — does NOT proxy to Plato.
     */
    public function health(): JsonResponse
    {
        $status = $this->service->healthCheck();

        return response()->json($status);
    }
}
