# P3-T06 — Audit and Finalize Laravel Proxy URL Configuration

## Task ID
P3-T06

## Title
Audit and Finalize Laravel Proxy URL Configuration — Remove All Hardcoded Plato URLs

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Description
Process 1 Step 2 already rerouted Platome API calls to use `EnvConfig.platomBaseUrl` (pointing to the Laravel proxy at `https://heclinic.cyberoket.cloud/api/v2/plato`). However, the original hardcoded Plato token `1463d1150e7b199effa2793c2d809034` and any residual hardcoded URLs must be verified as completely removed. This task conducts a full audit of the Flutter codebase to ensure: (1) zero hardcoded Plato URLs or tokens remain; (2) all Plato calls go through `EnvConfig.platomBaseUrl` via the Laravel proxy; (3) the proxy endpoint mapping is correct for all Plato API paths; (4) documentation is updated to reflect the final configuration.

## Dependencies
- P3-T01 through P3-T05 should be implemented first to ensure all interceptor/pagination/backoff logic works through the Laravel proxy.

## Expected Files
**Modified:**
- `lib/env_config.dart` — verify `platomBaseUrl` is correct and has appropriate fallback
- `lib/backend/api_requests/api_calls.dart` — verify all Plato endpoints use `EnvConfig.platomBaseUrl` (grep audit)
- Any files with residual hardcoded Plato references

## Acceptance Criteria
- [ ] A grep across `lib/` for `1463d1150e7b199effa2793c2d809034` returns zero results.
- [ ] A grep across `lib/` for `clinic.platomedical.com` returns zero results.
- [ ] All 15 Plato API call classes in `api_calls.dart` use `EnvConfig.platomBaseUrl` (verified by code review).
- [ ] `EnvConfig.platomBaseUrl` defaultValue is the Laravel proxy (`https://heclinic.cyberoket.cloud/api/v2/plato`), not the direct Plato URL.
- [ ] The Laravel proxy controller (`laravel/app/Http/Controllers/Api/PlatoProxyController.php`) correctly forwards all Plato API paths used by the Flutter app.
- [ ] A test call through the proxy (e.g., GET /patient via proxy) returns valid data from Plato.
- [ ] Documentation (`docs/CODEBASE.md`, `docs/v2-decisions.md`) reflects that Plato API token is now server-side only.

## Implementation Notes

### What Was Done
Full audit conducted across the entire Flutter codebase (`lib/`) and Laravel proxy layer. Verified zero hardcoded Plato tokens or URLs remain in Dart source files. Confirmed all 14 Plato API call classes (the 15th, GetPatientbyidCopyCall, was already removed in Process 1 P1-T06) use `EnvConfig.platomBaseUrl`. Updated `docs/CODEBASE.md` to reflect the new Laravel proxy architecture and mark the hardcoded token as RESOLVED.

### Files Changed
- `docs/CODEBASE.md` — Updated sections 5 (EnvConfig), 9 (API architecture), 11 (Plato API base URL/auth), and 19 (issue #1 marked RESOLVED)

### Decisions Made During Implementation
- `lib/env_config.dart` already has the correct proxy URL (`https://heclinic.cyberoket.cloud/api/v2/plato`) — no code changes needed.
- All 14 Plato API call classes in `api_calls.dart` confirmed to use `EnvConfig.platomBaseUrl` (verified via grep for `platombaseUrl` — 18 usages across 14 classes).
- `laravel/routes/api.php` confirms wildcard route `Route::any('/v2/plato/{path}', ...)` handles all paths.
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` implements a transparent proxy that forwards any HTTP method + path with the server-side Bearer token.
- `v2-decisions.md` already documents the proxy architecture (Process 1 Step 1-2) — no update needed.

### Known Limitations
- Could not execute a live test call through the proxy (AC6) — no Flutter/Laravel runtime available in CI. The proxy route and controller structure are correct and verified by code review.
- The `mock_server/index.js` routes use the prefix `/platom` (matching old direct Plato URL structure) — but this does not affect production and is intentionally overridden by `--dart-define=PLATOM_URL` in mock mode.

## QA Notes

## Reviewer Notes

## Status
IN-REVIEW
