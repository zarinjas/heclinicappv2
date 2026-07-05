# P2-T05 — Plato API Proxy Layer

## Task ID
P2-T05

## Title
Plato API Proxy Layer — Robust Proxy with Rate Limiting and Caching

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T05 |
| Slug | plato-api-proxy-layer |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 5 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | NO |
| Depends On | P2-T02 |
| Blocked Reason | N/A |

---

## Description

Enhance the existing Plato API proxy controller to be production-ready. Add request/response logging, rate limit header forwarding, response caching for frequently-used endpoints, error normalization, and support for all HTTP methods (GET, POST, PUT, DELETE). The existing `PlatoProxyController` already routes `ANY /api/v2/plato/{path}` through Laravel — this task makes it robust and production-grade. Per v2-decisions.md Process 2 Step 5.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 5: "Plato API proxy layer — all Plato calls route through Laravel with token in .env"
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — existing proxy controller (handles GET and POST)
- `laravel/routes/api.php` — existing route: `Route::any('/v2/plato/{path}', [PlatoProxyController::class, 'proxy'])`
- `docs/api-guidelines.md` — Plato authentication (Bearer token), rate limiting (x-ratelimit-* headers), pagination (current_page, modified_since)
- `docs/CODEBASE.md` — Section 11: Plato API endpoints used by Flutter app
- `lib/backend/api_requests/rate_limit_monitor.dart` — Flutter client-side rate limit monitor

---

## Scope

### In Scope
- Enhance `PlatoProxyController` to support all HTTP methods (GET, POST, PUT, DELETE) with proper body/query forwarding
- Read Plato API token from `.env` (PLATO_API_TOKEN) — already configured, verify
- Forward rate limit headers (`x-ratelimit-limit`, `x-ratelimit-remaining`) from Plato response to Flutter client
- Implement server-side response caching for GET endpoints (configurable TTL per endpoint type)
- Add request/response logging to `notifications_log` or Laravel log for debugging
- Error normalization: convert Plato errors to consistent JSON format `{ error: true, code: xxx, message: "..." }`
- Handle Plato HTTP errors (429, 401, 500) gracefully — return meaningful error responses
- Add config file `config/plato.php` for Plato base URL, token, cache TTLs, timeout
- Add proxy health check endpoint `GET /api/v2/plato/health` (does not proxy to Plato, returns status)
- Rate limit the proxy itself (protect from abuse — throttle requests per IP)
- Add query parameter forwarding support (Plato's `current_page`, `modified_since`, etc.)

### Out of Scope
- Admin Panel UI for monitoring proxy (future enhancement)
- Sophisticated retry logic on proxy (let Flutter's exponential backoff handle this)
- Transforming response data (proxy is pass-through; transformation is Flutter's responsibility)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — enhance with full method support, logging, header forwarding, caching, error normalization
- `laravel/config/plato.php` — Plato configuration
- `laravel/app/Services/PlatoProxyService.php` — service class encapsulating proxy logic
- `laravel/app/Http/Middleware/ProxyRateLimiter.php` — optional rate limiter for proxy endpoint
- `laravel/.env.example` — ensure PLATO_API_TOKEN, PLATO_BASE_URL are documented
- `laravel/routes/api.php` — add health endpoint

### API Endpoints
- `ANY /api/v2/plato/{path}` — existing, enhanced proxy endpoint
- `GET /api/v2/plato/health` — new, returns `{ status: "ok", plato_connected: true/false, token_configured: true/false }`

### Data / Schema
- `settings` table (from P2-T02): can store proxy configuration overrides, but keep simple with `config/plato.php` initially

### Plato Config (`config/plato.php`)
```php
return [
    'base_url' => env('PLATO_BASE_URL', 'https://clinic.platomedical.com'),
    'api_token' => env('PLATO_API_TOKEN'),
    'timeout' => env('PLATO_TIMEOUT', 30),
    'cache' => [
        'enabled' => env('PLATO_CACHE_ENABLED', true),
        'ttl_facility' => env('PLATO_CACHE_TTL_FACILITY', 300),   // 5 min
        'ttl_doctor' => env('PLATO_CACHE_TTL_DOCTOR', 300),        // 5 min
        'ttl_slots' => env('PLATO_CACHE_TTL_SLOTS', 60),           // 1 min
    ],
    'log_requests' => env('PLATO_LOG_REQUESTS', true),
    'proxy_rate_limit' => env('PLATO_PROXY_RATE_LIMIT', 60),       // per minute per IP
];
```

### Constraints
- Plato API token must NEVER be exposed to client — stays in `.env` only
- All proxy requests must use HTTPS
- Cache must respect data freshness — use lowest TTL for appointment slots
- Rate limit headers must be forwarded verbatim from Plato to Flutter client
- Proxy should not modify response body unless normalizing errors

---

## Acceptance Criteria

- [ ] Proxy correctly forwards GET, POST, PUT, and DELETE requests to Plato with all headers and body intact
- [ ] PLATO_API_TOKEN from `.env` is attached as `Authorization: Bearer {token}` to all proxied requests
- [ ] `x-ratelimit-limit` and `x-ratelimit-remaining` headers from Plato response are forwarded to Flutter client
- [ ] Plato error responses (non-2xx) are normalized to consistent JSON `{ error: true, code: xxx, message: "..." }`
- [ ] Plato 429 (Too Many Requests) returns a clear error to the client
- [ ] `GET /api/v2/plato/health` returns proxy status with Plato connectivity check
- [ ] Server-side caching reduces repeated calls to Plato for the same GET endpoint within TTL
- [ ] Proxy requests are rate-limited per IP to prevent abuse
- [ ] Request and error logs are written to Laravel log (and/or notifications_log table)
- [ ] Config file `config/plato.php` exists with all configurable values documented

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Enhanced the Plato API proxy layer to be production-grade. Created a dedicated `PlatoProxyService` encapsulating all proxy logic (HTTP forwarding, caching, error normalization, logging). Rewrote `PlatoProxyController` to use the service via DI with added IP-based rate limiting. Added a health check endpoint at `GET /api/v2/plato/health`. Added dedicated `config/plato.php` with all configurable options. Added `plato` log channel writing to `storage/logs/plato-proxy.log`.

### Files Changed
- `laravel/config/plato.php` — new config file for all Plato proxy settings
- `laravel/app/Services/PlatoProxyService.php` — new service with proxy(), healthCheck(), caching, error normalization, rate-limit header extraction
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — rewritten to use PlatoProxyService + IP rate limiting
- `laravel/routes/api.php` — added health endpoint (public, outside auth middleware)
- `laravel/config/logging.php` — added `plato` log channel (daily rotation, 30 days retention)
- `laravel/.env.example` — added new env vars: PLATO_TIMEOUT, PLATO_CACHE_*, PLATO_LOG_REQUESTS, PLATO_PROXY_RATE_LIMIT

### Decisions Made During Implementation
- Used Laravel's built-in `RateLimiter` facade instead of a custom middleware for simplicity and native support
- Cache TTL determined by endpoint type heuristic (path contains "appointment/slots" → 60s, "facility" → 300s, "doctor" → 300s, default → 120s) — matches config values in plato.php
- Error normalization follows task spec: `{ error: true, code: xxx, message: "..." }` for all non-2xx responses
- Health endpoint is public (no auth) to allow monitoring tools to check proxy status
- Proxy logging uses a separate log file (`plato-proxy.log`) with daily rotation to avoid cluttering the main Laravel log
- Kept backward compatibility with `config/services.plato` (not removed) in case other code references it

### Known Limitations
- Response caching only applies to GET requests (POST/PUT/DELETE are not cached)
- Cache invalidation is time-based only — no programmatic cache invalidation on data change
- IP rate limiting uses Laravel's default cache driver — if using `array` driver in tests, rate limiting is effectively disabled
- No database logging to `notifications_log` table — uses file-based logging only (can be added later if admin panel monitoring is needed)

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] All HTTP methods forwarded — PASS — proxy() handles GET, POST, PUT, PATCH, DELETE via match expression in PlatoProxyService
- [x] Bearer token attached — PASS — Http::withToken() called on every request; token sourced from config('plato.api_token') = env('PLATO_API_TOKEN')
- [x] Rate limit headers forwarded — PASS — extractRateLimitHeaders() reads x-ratelimit-limit and x-ratelimit-remaining, controller attaches them to JSON response
- [x] Error normalization — PASS — buildResponse() normalizes all non-2xx to consistent `{ error: true, code, message }` structure
- [x] 429 handling — PASS — dedicated 429 case with clear message; IP-based throttling also returns 429
- [x] Health endpoint — PASS — GET /api/v2/plato/health (public, no auth) returns status, plato_connected, token_configured, base_url
- [x] Caching works — PASS — GET requests use Cache::get/put with MD5-based keys; TTL varies by endpoint type (facility=300s, slots=60s, default=120s); cache.enabled flag respected
- [x] IP rate limiting — PASS — proxy() checks RateLimiter::tooManyAttempts per-IP key before forwarding; configurable via PLATO_PROXY_RATE_LIMIT
- [x] Logging — PASS — logRequest() and logError() write to dedicated `plato` log channel (daily rotation, 30 days, storage/logs/plato-proxy.log)
- [x] Config file — PASS — config/plato.php exists with all configurable values documented: base_url, api_token, timeout, cache.*, log_requests, proxy_rate_limit

### Failure Details
N/A — All criteria passed.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Process 2 Step 5 "Plato API proxy layer" fully satisfied: token in .env, all HTTP methods proxied, rate-limit headers forwarded, caching per endpoint type, error normalization, health endpoint. Error handling follows v2-decisions.md Admin Panel section: 429/401/500 responses normalized. Timeout configurable. Proxy rate limiting prevents abuse.
- v2-ux-spec.md alignment: N/A — backend Laravel task, no Flutter UI changes.

### Rejection Reason
N/A
