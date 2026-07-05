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
| Assigned Date | |
| Status | BACKLOG |
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
{To be filled}

### Files Changed
- {To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] All HTTP methods forwarded — PASS / FAIL
- [ ] Bearer token attached — PASS / FAIL
- [ ] Rate limit headers forwarded — PASS / FAIL
- [ ] Error normalization — PASS / FAIL
- [ ] 429 handling — PASS / FAIL
- [ ] Health endpoint — PASS / FAIL
- [ ] Caching works — PASS / FAIL
- [ ] IP rate limiting — PASS / FAIL
- [ ] Logging — PASS / FAIL
- [ ] Config file — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
