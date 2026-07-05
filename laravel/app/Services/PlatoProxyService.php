<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class PlatoProxyService
{
    private string $baseUrl;
    private string $token;
    private int $timeout;
    private bool $logRequests;

    public function __construct()
    {
        $this->baseUrl = config('plato.base_url');
        $this->token = config('plato.api_token');
        $this->timeout = (int) config('plato.timeout', 30);
        $this->logRequests = (bool) config('plato.log_requests', true);
    }

    public function proxy(string $method, string $path, array $query = [], array $body = []): array
    {
        $url = rtrim($this->baseUrl, '/') . '/' . ltrim($path, '/');

        $this->logRequest($method, $url, $query, $body);

        $cacheTtl = $this->getCacheTtl($path);
        $cacheKey = $this->buildCacheKey($method, $url, $query, $body);

        if ($method === 'GET' && $cacheTtl > 0) {
            $cached = Cache::get($cacheKey);
            if ($cached !== null) {
                return $cached;
            }
        }

        try {
            $http = Http::timeout($this->timeout)
                ->withToken($this->token)
                ->acceptJson()
                ->asJson();

            $response = match ($method) {
                'GET' => $http->get($url, $query),
                'POST' => $http->post($url, $body),
                'PUT', 'PATCH' => $http->send($method, $url, [
                    'json' => $body,
                    'query' => $query,
                ]),
                'DELETE' => $http->delete($url, $query),
                default => throw new \InvalidArgumentException("HTTP method '{$method}' is not supported by the proxy."),
            };

            $result = $this->buildResponse($response);

            if ($method === 'GET' && $cacheTtl > 0 && $response->successful()) {
                Cache::put($cacheKey, $result, $cacheTtl);
            }

            return $result;
        } catch (ConnectionException $e) {
            $this->logError($method, $url, $e->getMessage());

            return [
                'error' => true,
                'code' => 502,
                'message' => 'Unable to connect to Plato API.',
                'detail' => $e->getMessage(),
                'status' => 502,
                'headers' => [],
            ];
        } catch (\InvalidArgumentException $e) {
            return [
                'error' => true,
                'code' => 405,
                'message' => $e->getMessage(),
                'status' => 405,
                'headers' => [],
            ];
        }
    }

    public function healthCheck(): array
    {
        $tokenConfigured = ! empty($this->token);
        $platoConnected = false;
        $baseUrl = $this->baseUrl;

        if ($tokenConfigured) {
            try {
                $response = Http::timeout(10)
                    ->withToken($this->token)
                    ->acceptJson()
                    ->get(rtrim($this->baseUrl, '/') . '/facility', ['current_page' => 1]);

                $platoConnected = $response->successful();
            } catch (\Exception $e) {
                $platoConnected = false;
            }
        }

        return [
            'status' => 'ok',
            'plato_connected' => $platoConnected,
            'token_configured' => $tokenConfigured,
            'base_url' => $baseUrl,
        ];
    }

    private function buildResponse(Response $response): array
    {
        $status = $response->status();
        $body = $response->json();
        $headers = $this->extractRateLimitHeaders($response);

        if ($status >= 200 && $status < 300) {
            return [
                'data' => $body,
                'status' => $status,
                'headers' => $headers,
            ];
        }

        if ($status === 429) {
            return [
                'error' => true,
                'code' => 429,
                'message' => 'Plato API rate limit exceeded. Please wait and try again.',
                'status' => 429,
                'headers' => $headers,
            ];
        }

        if ($status === 401) {
            return [
                'error' => true,
                'code' => 401,
                'message' => 'Plato API authentication failed. Token may be expired.',
                'status' => 401,
                'headers' => $headers,
            ];
        }

        $message = $body['message'] ?? $body['error'] ?? 'Plato API returned an error.';

        return [
            'error' => true,
            'code' => $status,
            'message' => $message,
            'status' => $status,
            'headers' => $headers,
        ];
    }

    private function extractRateLimitHeaders(Response $response): array
    {
        $headers = [];

        $limit = $response->header('x-ratelimit-limit');
        $remaining = $response->header('x-ratelimit-remaining');

        if ($limit !== null) {
            $headers['x-ratelimit-limit'] = $limit;
        }
        if ($remaining !== null) {
            $headers['x-ratelimit-remaining'] = $remaining;
        }

        return $headers;
    }

    private function getCacheTtl(string $path): ?int
    {
        if (! config('plato.cache.enabled')) {
            return null;
        }

        $pathLower = mb_strtolower($path);

        if (str_contains($pathLower, 'appointment/slots')) {
            return (int) config('plato.cache.ttl_slots', 60);
        }
        if (str_contains($pathLower, 'facility')) {
            return (int) config('plato.cache.ttl_facility', 300);
        }
        if (str_contains($pathLower, 'doctor')) {
            return (int) config('plato.cache.ttl_doctor', 300);
        }

        return (int) config('plato.cache.ttl_default', 120);
    }

    private function buildCacheKey(string $method, string $url, array $query, array $body): string
    {
        $payload = json_encode(['method' => $method, 'url' => $url, 'query' => $query, 'body' => $body]);

        return 'plato_proxy:' . md5($payload);
    }

    private function logRequest(string $method, string $url, array $query, array $body): void
    {
        if (! $this->logRequests) {
            return;
        }

        Log::channel('plato')->info('Plato proxy request', [
            'method' => $method,
            'url' => $url,
            'query' => $query,
            'has_body' => ! empty($body),
        ]);
    }

    private function logError(string $method, string $url, string $message): void
    {
        if (! $this->logRequests) {
            return;
        }

        Log::channel('plato')->error('Plato proxy error', [
            'method' => $method,
            'url' => $url,
            'error' => $message,
        ]);
    }
}
