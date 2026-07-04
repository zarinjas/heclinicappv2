# P1-T01 — Add Plato API Token to Laravel .env and Proxy Route Foundation

## Task ID
P1-T01

## Title
Add Plato API Token to Laravel .env and Proxy Route Foundation

## Description
The Plato API token (`1463d1150e7b199effa2793c2d809034`) is currently hardcoded inside `lib/backend/api_requests/api_calls.dart` at line ~586. This is a critical security vulnerability — anyone who decompiles the Android APK can extract the token and gain full access to all Plato clinic data.

This task establishes the server-side foundation on the Laravel Admin Panel:

1. Add the Plato API token to Laravel `.env` as `PLATO_API_TOKEN`.
2. Add the Plato base URL to `.env` as `PLATO_BASE_URL`.
3. Create a `PlatoProxyController` with a generic `proxy()` method that:
   - Accepts method, path, query params, and body from the mobile app request.
   - Attaches `Authorization: Bearer {PLATO_API_TOKEN}` from `.env`.
   - Forwards the request to Plato API.
   - Returns the Plato response as-is to the mobile caller.
4. Register a catch-all route group under `/api/v2/plato/{path}` that routes to `PlatoProxyController@proxy`.
5. Protect the proxy route group with Laravel Sanctum auth middleware — only authenticated mobile users can call the proxy.

This task does NOT touch Flutter yet. It only sets up the receiving end on Laravel.

## Dependencies
- None — this is the first task in Process 1 and blocks all Plato-related mobile work.

## Expected Files
**Laravel Admin Panel (separate repo/VPS):**
- `.env` — add `PLATO_API_TOKEN` and `PLATO_BASE_URL`
- `config/services.php` — expose `plato.token` and `plato.base_url` config keys
- `app/Http/Controllers/Api/PlatoProxyController.php` — new controller
- `routes/api.php` — new proxy route group `/api/v2/plato/{path}`

## Acceptance Criteria
- [ ] `PLATO_API_TOKEN` and `PLATO_BASE_URL` exist in `.env` and are NOT committed to version control (`.gitignore` verified).
- [ ] `config/services.php` exposes `config('services.plato.token')` and `config('services.plato.base_url')`.
- [ ] `PlatoProxyController@proxy` successfully forwards a test `GET /api/v2/plato/facility` request to Plato and returns the correct response.
- [ ] Unauthenticated requests to `/api/v2/plato/{path}` return HTTP 401.
- [ ] The raw Plato token string does NOT appear anywhere in committed source code.
- [ ] Proxy forwards all HTTP methods: GET, POST, PUT, DELETE.
- [ ] Proxy forwards query parameters correctly.
- [ ] Proxy forwards request body (JSON) correctly for POST/PUT requests.
- [ ] HTTP errors from Plato (4xx, 5xx) are passed through to the mobile caller with the original status code.

## Priority
CRITICAL — blocks P1-T02 and all subsequent Plato API work

## Estimated Effort
3–4 hours

## Assigned To
laravel-developer

## Assigned Date
2026-07-04

## Status
IN-PROGRESS