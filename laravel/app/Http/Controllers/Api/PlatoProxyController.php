<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Http;

final class PlatoProxyController extends Controller
{
    private string $baseUrl;
    private string $token;

    public function __construct()
    {
        $this->baseUrl = config('services.plato.base_url');
        $this->token = config('services.plato.token');

        if (empty($this->baseUrl) || empty($this->token)) {
            abort(500, 'Plato API configuration is missing. Check PLATO_BASE_URL and PLATO_API_TOKEN in .env.');
        }
    }

    /**
     * Proxy all requests to the Plato API.
     *
     * Accepts any HTTP method, path, query params, and JSON body from the mobile
     * app, attaches the server-side Bearer token, and forwards to Plato.
     *
     * The mobile app never sees the Plato token — it stays in .env on the VPS.
     */
    public function proxy(Request $request, string $path): JsonResponse
    {
        $method = strtoupper($request->method());

        $url = rtrim($this->baseUrl, '/') . '/' . ltrim($path, '/');

        $query = $request->query();

        try {
            $http = Http::timeout(30)
                ->withToken($this->token)
                ->acceptJson()
                ->asJson();

            if ($method === 'GET') {
                $response = $http->get($url, $query);
            } elseif ($method === 'POST') {
                $response = $http->post($url, $request->all());
            } elseif ($method === 'PUT' || $method === 'PATCH') {
                $response = $http->send($method, $url, [
                    'json' => $request->all(),
                    'query' => $query,
                ]);
            } elseif ($method === 'DELETE') {
                $response = $http->delete($url, $query);
            } else {
                return response()->json([
                    'error' => "HTTP method '{$method}' is not supported by the proxy.",
                ], Response::HTTP_METHOD_NOT_ALLOWED);
            }

            return response()->json(
                $response->json(),
                $response->status()
            );

        } catch (ConnectionException $e) {
            return response()->json([
                'error' => 'Unable to connect to Plato API.',
                'detail' => $e->getMessage(),
            ], Response::HTTP_BAD_GATEWAY);
        }
    }
}
