# P3-T06 — Audit and Finalize Laravel Proxy URL Configuration

## Task ID
P3-T06

## Title
Audit and Finalize Laravel Proxy URL Configuration — Remove All Hardcoded Plato URLs

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

## QA Notes

## Reviewer Notes

## Status
BACKLOG
