<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Throwable;

final class PlatoProxyService
{
    public function proxy(string $method, string $path, array $query = [], array $body = [], bool $forceRefresh = false): array
    {
        $url = rtrim($this->baseUrl(), '/').'/'.ltrim($path, '/');

        $cacheTtl = $this->getCacheTtl($path);
        $cacheKey = $this->buildCacheKey($method, $url, $query, $body);
        $isCacheable = $method === 'GET' && $cacheTtl !== null && $cacheTtl > 0;

        if ($isCacheable && ! $forceRefresh) {
            $cached = $this->readCache($cacheKey);
            if ($cached !== null) {
                if ($cached['fresh_until'] >= now()->timestamp) {
                    $this->logMetric($method, $path, 'cache_hit', null, 0);

                    return $cached['response'];
                }

                if ($cached['stale_until'] >= now()->timestamp) {
                    $this->queueRefresh($method, $path, $query, $body);
                    $this->logMetric($method, $path, 'cache_stale', null, 0);

                    return $this->markStale($cached['response']);
                }
            }
        }

        $lock = $isCacheable
            ? $this->cacheStore()->lock('plato:request:'.hash('sha256', $cacheKey), $this->lockSeconds())
            : null;
        $lockAcquired = $lock === null;

        if ($lock !== null && ($lockAcquired = $lock->get()) === false) {
            usleep((int) config('plato.concurrency.wait_ms', 100) * 1000);
            $cached = $this->readCache($cacheKey);
            if (! $forceRefresh && $cached !== null && $cached['stale_until'] >= now()->timestamp) {
                $this->logMetric($method, $path, 'deduplicated', null, 0);

                return $cached['response'];
            }
        }

        try {
            $result = $this->sendWithRetry($method, $url, $path, $query, $body);

            if ($isCacheable && ($result['status'] ?? 0) >= 200 && ($result['status'] ?? 0) < 300) {
                $this->writeCache($cacheKey, $result, $cacheTtl);
            } elseif ($isCacheable && ($cached = $this->readCache($cacheKey)) !== null && $this->isFallbackError($result)) {
                $this->logMetric($method, $path, 'stale_fallback', $result['status'] ?? null, 0);

                return $this->markStale($cached['response']);
            }

            return $result;
        } finally {
            if ($lockAcquired) {
                $lock?->release();
            }
        }
    }

    public function invalidate(string $path, array $query = [], array $body = []): void
    {
        $url = rtrim($this->baseUrl(), '/').'/'.ltrim($path, '/');
        $this->cacheStore()->forget($this->buildCacheKey('GET', $url, $query, $body));
    }

    public function invalidatePatient(string $patientId, array $paths = ['appointment', 'appointment/slots', 'invoice', 'payment', 'letter', 'patient']): void
    {
        foreach ($paths as $path) {
            $versionPath = $path === 'patient' ? 'patient/'.$patientId : $path;
            $this->cacheStore()->increment('plato:version:'.hash('sha256', $versionPath.'|'.$patientId));
        }
    }

    private function sendWithRetry(string $method, string $url, string $path, array $query, array $body): array
    {
        if (! in_array($method, ['GET', 'HEAD'], true)) {
            return $this->sendOnce($method, $url, $path, $query, $body);
        }

        $attempts = max(1, (int) config('plato.retry.max_attempts', 3));
        $started = microtime(true);
        $last = null;

        for ($attempt = 1; $attempt <= $attempts; $attempt++) {
            $last = $this->sendOnce($method, $url, $path, $query, $body);
            $status = $last['status'] ?? 0;

            if (! $this->isRetryable($status)) {
                break;
            }

            if ($attempt === $attempts) {
                break;
            }

            $delay = $this->retryDelayMs($last, $attempt);
            $this->logMetric($method, $path, 'retry', $status, (microtime(true) - $started) * 1000, [
                'attempt' => $attempt,
                'delay_ms' => $delay,
            ]);
            usleep($delay * 1000);
        }

        return $last ?? $this->errorResponse(502, 'Unable to connect to Plato API.');
    }

    private function sendOnce(string $method, string $url, string $path, array $query, array $body): array
    {
        $started = microtime(true);
        $this->logRequest($method, $path, $query, $body);

        try {
            $result = $this->withConcurrency(function () use ($method, $url, $query, $body): array {
                $http = Http::timeout($this->timeout())
                    ->withToken($this->token())
                    ->acceptJson()
                    ->asJson();

                $response = match ($method) {
                    'GET' => $http->get($url, $query),
                    'POST' => $http->post($url, $body),
                    'PUT', 'PATCH' => $http->send($method, $url, ['json' => $body, 'query' => $query]),
                    'DELETE' => $http->delete($url, $query),
                    default => throw new \InvalidArgumentException("HTTP method '{$method}' is not supported by the proxy."),
                };

                return $this->buildResponse($response);
            });

            $this->logMetric($method, $path, 'http', $result['status'] ?? null, (microtime(true) - $started) * 1000);

            return $result;
        } catch (ConnectionException $e) {
            $this->logError($method, $path, $e->getMessage());
            $this->logMetric($method, $path, 'connection_error', 502, (microtime(true) - $started) * 1000);

            return $this->errorResponse(502, 'Unable to connect to Plato API.');
        } catch (\InvalidArgumentException $e) {
            return $this->errorResponse(405, $e->getMessage());
        } catch (Throwable $e) {
            $this->logError($method, $path, $e->getMessage());

            return $this->errorResponse(502, 'Unable to connect to Plato API.');
        }
    }

    private function withConcurrency(callable $callback): mixed
    {
        $max = max(1, (int) config('plato.concurrency.max', 4));
        $timeout = max(0, (int) config('plato.concurrency.timeout_ms', 3000));
        $wait = max(1, (int) config('plato.concurrency.wait_ms', 100));
        $deadline = microtime(true) + ($timeout / 1000);

        do {
            for ($slot = 0; $slot < $max; $slot++) {
                $lock = $this->cacheStore()->lock('plato:concurrency:'.$slot, 10);
                if (! $lock->get()) {
                    continue;
                }

                try {
                    return $callback();
                } finally {
                    $lock->release();
                }
            }

            usleep($wait * 1000);
        } while (microtime(true) < $deadline);

        return $callback();
    }

    private function readCache(string $key): ?array
    {
        $entry = $this->cacheStore()->get($key);

        return is_array($entry) && isset($entry['response'], $entry['fresh_until'], $entry['stale_until'])
            ? $entry
            : null;
    }

    private function writeCache(string $key, array $response, int $ttl): void
    {
        $freshUntil = now()->timestamp + $ttl;
        $staleUntil = $freshUntil + max(0, (int) config('plato.cache.stale_while_revalidate', 900));
        $this->cacheStore()->put($key, [
            'response' => $response,
            'fresh_until' => $freshUntil,
            'stale_until' => $staleUntil,
        ], $ttl + max(0, (int) config('plato.cache.stale_while_revalidate', 900)));
    }

    private function markStale(array $response): array
    {
        $response['headers']['x-plato-data-stale'] = 'true';

        return $response;
    }

    private function queueRefresh(string $method, string $path, array $query, array $body): void
    {
        try {
            \App\Jobs\RefreshPlatoCache::dispatch($method, $path, $query, $body)->onQueue('plato');
        } catch (Throwable $e) {
            Log::channel('plato')->warning('Plato cache refresh dispatch failed', ['error' => $e->getMessage()]);
        }
    }

    private function isFallbackError(array $result): bool
    {
        return ! empty($result['error']) && in_array((int) ($result['status'] ?? 0), [408, 429, 500, 502, 503, 504], true);
    }

    private function isRetryable(int $status): bool
    {
        return $status === 0 || in_array($status, [408, 425, 429, 500, 502, 503, 504], true);
    }

    private function retryDelayMs(array $result, int $attempt): int
    {
        $retryAfter = $result['headers']['retry-after'] ?? null;
        if (is_numeric($retryAfter)) {
            return min((int) config('plato.retry.max_delay_ms', 5000), max(0, (int) $retryAfter * 1000));
        }
        if (is_string($retryAfter) && ($timestamp = strtotime($retryAfter)) !== false) {
            return min((int) config('plato.retry.max_delay_ms', 5000), max(0, ($timestamp - time()) * 1000));
        }

        $base = min(
            (int) config('plato.retry.max_delay_ms', 5000),
            (int) config('plato.retry.base_delay_ms', 250) * (2 ** max(0, $attempt - 1)),
        );

        return random_int((int) ($base * 0.5), max(1, $base));
    }

    private function errorResponse(int $status, string $message): array
    {
        return ['error' => true, 'code' => $status, 'message' => $message, 'status' => $status, 'headers' => []];
    }

    private function cacheStore(): mixed
    {
        return Cache::store(config('plato.cache.store', 'redis'));
    }

    private function lockSeconds(): int
    {
        return max(5, $this->timeout() + 5);
    }

    /**
     * Fetch a Plato-hosted binary using the server-side Plato token.
     */
    public function download(string $path): Response
    {
        $isAbsolute = str_starts_with($path, 'http://') || str_starts_with($path, 'https://');
        if ($isAbsolute) {
            $sourceHost = parse_url($path, PHP_URL_HOST);
            $platoHost = parse_url($this->baseUrl(), PHP_URL_HOST);
            if (! is_string($sourceHost) || ! is_string($platoHost)
                || ! hash_equals(strtolower($platoHost), strtolower($sourceHost))) {
                throw new \InvalidArgumentException('The file source is not hosted by Plato.');
            }
        }

        $url = $isAbsolute
            ? $path
            : rtrim($this->baseUrl(), '/').'/'.ltrim($path, '/');

        $databaseToken = $this->token();
        $response = Http::timeout($this->timeout())
            ->withToken($databaseToken)
            ->get($url);

        // The admin UI stores a token in the database, which can outlive a
        // rotated deployment token in .env. Retry once with the deployment
        // token so existing PDF links do not fail with 401 until someone
        // manually opens the settings page.
        $deploymentToken = (string) config('plato.api_token');
        if ($response->status() === 401
            && $deploymentToken !== ''
            && ! hash_equals($databaseToken, $deploymentToken)) {
            $response = Http::timeout($this->timeout())
                ->withToken($deploymentToken)
                ->get($url);
        }

        return $response;
    }

    public function healthCheck(): array
    {
        $token = $this->token();
        $tokenConfigured = ! empty($token);
        $platoConnected = false;
        $baseUrl = $this->baseUrl();

        if ($tokenConfigured) {
            try {
                $response = Http::timeout(10)
                    ->withToken($token)
                    ->acceptJson()
                    ->get(rtrim($baseUrl, '/').'/facility', ['current_page' => 1]);

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

    public function proxyRateLimit(): int
    {
        return (int) $this->cachedSetting('plato:proxy_rate_limit', function () {
            return Setting::where('key', 'plato_proxy_rate_limit')->value('value')
                ?? config('plato.proxy_rate_limit', 60);
        });
    }

    /**
     * Redeem or validate a voucher code against the configured Plato path.
     * If no voucher path is configured, returns a "not configured" error so
     * the caller can fall back to display-only behaviour.
     */
    public function voucherRedeem(string $code, array $extra = []): array
    {
        $path = $this->voucherPath();

        if (empty($path)) {
            return [
                'error' => true,
                'code' => 501,
                'message' => 'Plato voucher endpoint is not configured.',
                'status' => 501,
                'headers' => [],
            ];
        }

        $url = rtrim($this->baseUrl(), '/').'/'.ltrim($path, '/');

        try {
            $response = Http::timeout($this->timeout())
                ->withToken($this->token())
                ->acceptJson()
                ->asJson()
                ->post($url, array_merge($extra, ['code' => $code]));

            return $this->buildResponse($response);
        } catch (ConnectionException $e) {
            $this->logError('POST', $url, $e->getMessage());

            return [
                'error' => true,
                'code' => 502,
                'message' => 'Unable to connect to Plato API.',
                'detail' => $e->getMessage(),
                'status' => 502,
                'headers' => [],
            ];
        }
    }

    public function voucherPath(): ?string
    {
        return (string) $this->cachedSetting('plato:voucher_path', function () {
            return Setting::where('key', 'plato_voucher_path')->value('value')
                ?: config('plato.voucher_path');
        }) ?: null;
    }

    public function clearSettingsCache(): void
    {
        foreach ([
            'plato:api_token',
            'plato:base_url',
            'plato:timeout',
            'plato:cache_enabled',
            'plato:proxy_rate_limit',
            'plato:voucher_path',
        ] as $key) {
            Cache::forget($key);
        }
    }

    private function token(): string
    {
        return (string) $this->cachedSetting('plato:api_token', function () {
            $stored = Setting::where('key', 'plato_api_token')->value('value');

            return $stored ? Crypt::decryptString($stored) : (string) config('plato.api_token');
        });
    }

    private function baseUrl(): string
    {
        return (string) $this->cachedSetting('plato:base_url', function () {
            return Setting::where('key', 'plato_base_url')->value('value')
                ?? config('plato.base_url');
        });
    }

    private function timeout(): int
    {
        return (int) $this->cachedSetting('plato:timeout', function () {
            return Setting::where('key', 'plato_timeout')->value('value')
                ?? config('plato.timeout', 30);
        });
    }

    private function cacheEnabled(): bool
    {
        return (bool) $this->cachedSetting('plato:cache_enabled', function () {
            $stored = Setting::where('key', 'plato_cache_enabled')->value('value');

            return $stored !== null ? $stored === '1' : (bool) config('plato.cache.enabled', true);
        });
    }

    private function cachedSetting(string $cacheKey, callable $resolver): mixed
    {
        return Cache::remember($cacheKey, 300, $resolver);
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

        $retryAfter = $response->header('retry-after');
        if ($retryAfter !== null) {
            $headers['retry-after'] = $retryAfter;
        }

        return $headers;
    }

    private function getCacheTtl(string $path): ?int
    {
        if (! $this->cacheEnabled()) {
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
        if (str_contains($pathLower, 'appointment')) {
            return (int) config('plato.cache.ttl_appointment', 30);
        }
        if (str_contains($pathLower, 'invoice') || str_contains($pathLower, 'payment')) {
            return (int) config('plato.cache.ttl_invoice', 60);
        }
        if (str_contains($pathLower, 'letter') || str_contains($pathLower, '/note')) {
            return (int) config('plato.cache.ttl_clinical', 300);
        }

        return (int) config('plato.cache.ttl_default', 120);
    }

    private function buildCacheKey(string $method, string $url, array $query, array $body): string
    {
        unset($query['_nocache']);
        ksort($query);
        ksort($body);
        $rawScope = $query['patient_id'] ?? $query['patientId'] ?? $query['id_patient']
            ?? $body['patient_id'] ?? $body['patientId'] ?? $body['id_patient'] ?? null;
        if ($rawScope === null && preg_match('#(?:^|/)patient/([^/]+)#i', $this->pathFromUrl($url), $matches) === 1) {
            $rawScope = urldecode($matches[1]);
        }
        $scope = $rawScope === null ? 'global' : 'patient:'.hash('sha256', (string) $rawScope);
        $patientVersion = $rawScope === null ? 0 : (int) $this->cacheStore()->get(
            'plato:version:'.hash('sha256', $this->pathFromUrl($url).'|'.(string) $rawScope)
        );
        $payload = json_encode([
            'version' => 2,
            'patient_version' => $patientVersion,
            'scope' => $scope,
            'method' => strtoupper($method),
            'url' => $url,
            'query' => $query,
            'body' => $body,
        ]);

        return 'plato_proxy:'.hash('sha256', $payload);
    }

    private function logRequest(string $method, string $path, array $query, array $body): void
    {
        if (! config('plato.log_requests', true)) {
            return;
        }

        Log::channel('plato')->info('Plato proxy request', [
            'method' => $method,
            'endpoint' => $this->endpointName($path),
            'has_body' => ! empty($body),
        ]);
    }

    private function logError(string $method, string $path, string $message): void
    {
        if (! config('plato.log_requests', true)) {
            return;
        }

        Log::channel('plato')->error('Plato proxy error', [
            'method' => $method,
            'endpoint' => $this->endpointName($path),
            'error_type' => class_basename($message),
        ]);
    }

    private function logMetric(string $method, string $path, string $event, ?int $status, float $latency, array $extra = []): void
    {
        if (! config('plato.log_requests', true)) {
            return;
        }

        Log::channel('plato')->info('Plato API metric', array_merge([
            'method' => $method,
            'endpoint' => $this->endpointName($path),
            'event' => $event,
            'status' => $status,
            'latency_ms' => round($latency, 2),
        ], $extra));
    }

    private function endpointName(string $path): string
    {
        return strtolower(trim((string) preg_replace('#/[^/]+$#', '/{id}', ltrim($path, '/')), '/')) ?: 'root';
    }

    private function pathFromUrl(string $url): string
    {
        $basePath = trim((string) parse_url($this->baseUrl(), PHP_URL_PATH), '/');
        $path = ltrim((string) parse_url($url, PHP_URL_PATH), '/');

        return str_starts_with($path, $basePath.'/') ? substr($path, strlen($basePath) + 1) : $path;
    }
}
