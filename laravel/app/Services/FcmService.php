<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Sends push notifications through the FCM HTTP v1 API using a Google
 * service account.
 *
 * This exists because the previous pipeline wrote a document to the
 * `ff_push_notifications` Firestore collection with only a web API key and
 * relied on a Cloud Function to fan out. That write is unauthenticated, has no
 * matching security rule, and the Cloud Function only ever read tokens from
 * `fcm/{patientId}` — a location nothing writes to any more. Sending straight
 * from Laravel removes both failure points.
 */
final class FcmService
{
    private const OAUTH_TOKEN_URL = 'https://oauth2.googleapis.com/token';
    private const SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
    private const ACCESS_TOKEN_CACHE_KEY = 'fcm:access_token';

    /**
     * Whether a usable service account credential is configured.
     */
    public function isConfigured(): bool
    {
        return $this->serviceAccount() !== null;
    }

    /**
     * Confirm the configured credentials can actually mint an access token.
     * Used by `php artisan push:diagnose` to fail loudly at setup time rather
     * than silently at send time.
     */
    public function verifyCredentials(): bool
    {
        return $this->accessToken() !== null;
    }

    /**
     * Send a notification to many device tokens.
     *
     * @param  array<int, string>  $tokens
     * @param  array<string, string>  $data
     * @return array{success: int, failure: int, invalid_tokens: array<int, string>, error?: string}
     */
    public function sendToTokens(
        array $tokens,
        string $title,
        string $body,
        array $data = [],
        ?string $imageUrl = null,
    ): array {
        $tokens = array_values(array_unique(array_filter($tokens, static fn ($t) => is_string($t) && $t !== '')));

        if ($tokens === []) {
            return ['success' => 0, 'failure' => 0, 'invalid_tokens' => [], 'error' => 'No device tokens to send to.'];
        }

        $accessToken = $this->accessToken();

        if ($accessToken === null) {
            return ['success' => 0, 'failure' => count($tokens), 'invalid_tokens' => [], 'error' => 'FCM service account is not configured.'];
        }

        $projectId = (string) config('firebase.project_id');
        $url = sprintf('%s/projects/%s/messages:send', rtrim((string) config('firebase.fcm_endpoint'), '/'), $projectId);

        $success = 0;
        $failure = 0;
        $invalidTokens = [];

        foreach ($tokens as $token) {
            $message = [
                'message' => [
                    'token' => $token,
                    'notification' => array_filter([
                        'title' => $title,
                        'body' => $body,
                        'image' => $imageUrl ?: null,
                    ]),
                    // FCM v1 requires all data values to be strings.
                    'data' => array_map(static fn ($v) => (string) $v, $data),
                ],
            ];

            try {
                $response = Http::timeout(15)
                    ->withToken($accessToken)
                    ->acceptJson()
                    ->asJson()
                    ->post($url, $message);

                if ($response->successful()) {
                    $success++;

                    continue;
                }

                $failure++;
                $status = $response->status();
                $reason = (string) $response->json('error.status', '');

                // 404 UNREGISTERED / 400 INVALID_ARGUMENT mean the token is dead.
                if ($status === 404 || $reason === 'UNREGISTERED' || $reason === 'INVALID_ARGUMENT') {
                    $invalidTokens[] = $token;
                }

                Log::channel('plato')->warning('FCM send failed', [
                    'status' => $status,
                    'reason' => $reason,
                    'body' => $response->json('error.message'),
                ]);
            } catch (\Exception $e) {
                $failure++;
                Log::channel('plato')->error('FCM send exception', ['error' => $e->getMessage()]);
            }
        }

        return [
            'success' => $success,
            'failure' => $failure,
            'invalid_tokens' => $invalidTokens,
        ];
    }

    /**
     * Fetch (and cache) an OAuth2 access token for the service account.
     */
    private function accessToken(): ?string
    {
        $cached = Cache::get(self::ACCESS_TOKEN_CACHE_KEY);

        if (is_string($cached) && $cached !== '') {
            return $cached;
        }

        $credentials = $this->serviceAccount();

        if ($credentials === null) {
            return null;
        }

        $jwt = $this->buildSignedJwt($credentials);

        if ($jwt === null) {
            return null;
        }

        try {
            $response = Http::timeout(15)->asForm()->post(self::OAUTH_TOKEN_URL, [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if (! $response->successful()) {
                Log::channel('plato')->error('FCM OAuth token request failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return null;
            }

            $accessToken = (string) $response->json('access_token', '');
            $expiresIn = (int) $response->json('expires_in', 3600);

            if ($accessToken === '') {
                return null;
            }

            // Refresh slightly early to avoid using a token that expires mid-flight.
            Cache::put(self::ACCESS_TOKEN_CACHE_KEY, $accessToken, max(60, $expiresIn - 60));

            return $accessToken;
        } catch (\Exception $e) {
            Log::channel('plato')->error('FCM OAuth token exception', ['error' => $e->getMessage()]);

            return null;
        }
    }

    /**
     * Build an RS256-signed JWT assertion for the service account.
     *
     * @param  array<string, mixed>  $credentials
     */
    private function buildSignedJwt(array $credentials): ?string
    {
        $now = time();

        $header = ['alg' => 'RS256', 'typ' => 'JWT'];
        $claims = [
            'iss' => $credentials['client_email'],
            'scope' => self::SCOPE,
            'aud' => self::OAUTH_TOKEN_URL,
            'iat' => $now,
            'exp' => $now + 3600,
        ];

        $input = $this->base64UrlEncode(json_encode($header, JSON_THROW_ON_ERROR))
            .'.'
            .$this->base64UrlEncode(json_encode($claims, JSON_THROW_ON_ERROR));

        $signature = '';
        $key = openssl_pkey_get_private($credentials['private_key']);

        if ($key === false) {
            Log::channel('plato')->error('FCM service account private key could not be parsed.');

            return null;
        }

        if (! openssl_sign($input, $signature, $key, OPENSSL_ALGO_SHA256)) {
            Log::channel('plato')->error('FCM JWT signing failed.');

            return null;
        }

        return $input.'.'.$this->base64UrlEncode($signature);
    }

    /**
     * Load and validate the service account JSON.
     *
     * The service account can be provided two ways:
     *  1. Pasted into the admin panel (System Settings → Firebase), which is
     *     stored encrypted in the settings table and read via config. This is
     *     the deploy-safe option — no file to keep in sync with git.
     *  2. A file path in `FIREBASE_SERVICE_ACCOUNT_PATH` (.env). The file must
     *     survive deploys (keep it outside the rsync'd Laravel folder).
     *
     * @return array<string, mixed>|null
     */
    private function serviceAccount(): ?array
    {
        $stored = (string) config('firebase.service_account', '');

        if ($stored !== '') {
            try {
                $decoded = json_decode($stored, true, 512, JSON_THROW_ON_ERROR);
            } catch (\JsonException $e) {
                Log::channel('plato')->error('Firebase service account stored in settings is not valid JSON.', ['error' => $e->getMessage()]);

                return null;
            }

            if (is_array($decoded) && ! empty($decoded['client_email']) && ! empty($decoded['private_key'])) {
                return $decoded;
            }

            Log::channel('plato')->error('Firebase service account stored in settings is missing client_email or private_key.');

            return null;
        }

        $path = (string) config('firebase.service_account_path');

        if ($path === '') {
            return null;
        }

        if (! str_starts_with($path, '/')) {
            $path = base_path($path);
        }

        if (! is_readable($path)) {
            Log::channel('plato')->warning('Firebase service account file is not readable.', ['path' => $path]);

            return null;
        }

        try {
            $decoded = json_decode((string) file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);
        } catch (\JsonException $e) {
            Log::channel('plato')->error('Firebase service account file is not valid JSON.', ['error' => $e->getMessage()]);

            return null;
        }

        if (! is_array($decoded) || empty($decoded['client_email']) || empty($decoded['private_key'])) {
            Log::channel('plato')->error('Firebase service account file is missing client_email or private_key.');

            return null;
        }

        return $decoded;
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
