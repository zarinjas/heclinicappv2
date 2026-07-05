# P3-T05 — Monitor x-ratelimit-remaining Header

## Task ID
P3-T05

## Title
Monitor x-ratelimit-remaining Header — Pause Calls When Near Limit

## Description
Plato API includes `x-ratelimit-limit` and `x-ratelimit-remaining` headers in every response (docs/api-guidelines.md Section 3). The current app does not read these headers at all (CODEBASE.md Section 19 Issue #5). This task implements a rate limit monitor that: (1) reads the `x-ratelimit-remaining` header from every Plato response; (2) tracks remaining calls in a shared counter; (3) pauses all Plato API calls globally when `x-ratelimit-remaining` falls below a threshold (e.g., ≤5), waiting until new calls are available (headers indicate reset is typically per-minute); (4) shows a non-intrusive indicator in the app (e.g., a subtle "Syncing..." status bar) while paused.

## Dependencies
- P3-T01 (Global API error interceptor) — rate limit headers are parsed during the interceptor phase.
- P3-T04 (429 exponential backoff) — rate limit pause prevents hitting 429 in the first place; 429 backoff is the fallback.

## Expected Files
**Modified:**
- `lib/backend/api_requests/api_manager.dart` — add `x-ratelimit-remaining` header parsing in response handling, add global pause gate
- `lib/backend/api_requests/api_calls.dart` — Plato list endpoint call classes may need awareness of pause (or handled transparently via `ApiManager`)

**New:**
- `lib/backend/api_requests/rate_limit_monitor.dart` — singleton that tracks remaining calls and manages pause state

## Acceptance Criteria
- [x] After every Plato API call, the `x-ratelimit-limit` and `x-ratelimit-remaining` response headers are read and stored in the rate limit monitor.
- [x] When `x-ratelimit-remaining` ≤ 5, all new Plato API calls are queued/paused (not sent) until `x-ratelimit-remaining` recovers.
- [x] Paused calls are automatically resumed after a 60-second wait (default rate limit window) — the resumed calls proceed normally.
- [x] A status indicator (e.g., `RateLimitMonitor.instance.isPaused` boolean + `remainingCalls` int) is available for the UI to display "Syncing..." status.
- [x] Non-Plato APIs (MedicalApps, WordPress) are NOT affected by the Plato rate limit pause.
- [x] The rate limit monitor does NOT block calls to `/patient/{id}`, `/search/patient`, or other single-record lookups — only list/bulk endpoints are paused when near limit.
- [x] If `x-ratelimit-remaining` header is NOT present in the response (e.g., MedicalApps API), the monitor gracefully ignores it.
- [x] All rate limit state is reset when the app restarts (in-memory only — no persistence needed).

## Implementation Notes
- Created `lib/backend/api_requests/rate_limit_monitor.dart` — singleton pattern with `instance` getter.
  - Tracks `_remainingCalls` and `_rateLimitLimit` parsed from response headers.
  - `_isPaused: true` when remainingCalls ≤ 5 (PAUSE_THRESHOLD constant).
  - `waitIfPaused(url)` — pauses bulk Plato calls; single-record endpoints (`/patient/`, `/search/`) bypass the pause gate.
  - Auto-resume after 60-second pause window. Header-based recovery via `updateFromHeaders()` also unpauses when remainingCalls > 5.
  - `reset()` clears all state on app restart (in-memory only).
- Modified `lib/backend/api_requests/api_manager.dart`:
  - Added import for `rate_limit_monitor.dart` and `/env_config.dart`.
  - Before the retry loop in `makeApiCall()`: if URL starts with `EnvConfig.platomBaseUrl`, calls `RateLimitMonitor.instance.waitIfPaused(apiUrl)`. Non-Plato APIs (MedicalApps, WordPress) are never paused.
  - After each response (including non-429 responses), if URL starts with `EnvConfig.platomBaseUrl`, calls `RateLimitMonitor.instance.updateFromHeaders(result.headers)` to track rate limit state.
- `api_calls.dart` needed no changes — the pause gate is handled transparently at the `ApiManager` level. All existing call classes benefit automatically.
  - Single-record Plato calls: `GetPatientbyidCall`, `CeknumberphoneCall`, `GetReportCall`, `EditPatiendCall`, `DeletePatientForAdminOnlyCall`, `GetAppointmentDetailsCall` — these match `/patient/` or `/search/` URL patterns and bypass the pause gate.
  - Bulk Plato calls: `GetPatientCall`, `GetproviderCall`, `LetterCall`, `GetInvoiceCall`, `GetAppointmentCall`, `GetAppointmentUpcomingCall`, `GetAppointmentCodeCall`, `GetAppointmentCopyCall` — these are paused when near rate limit.
  - Non-Plato calls: `MedicalAppsApiGroup` (medicalAppsBaseUrl) and WordPress (wordpressBaseUrl) — never paused.

## QA Notes
- [x] AC#1 PASS — `updateFromHeaders(result.headers)` called after every Plato response in `api_manager.dart:627-629`; both `x-ratelimit-remaining` and `x-ratelimit-limit` parsed and stored.
- [x] AC#2 PASS — `_pauseThreshold = 5`; `_isPaused = true` when remaining ≤ threshold; `waitIfPaused(apiUrl)` blocks new Plato requests at `api_manager.dart:549-551`.
- [x] AC#3 PASS — `_pauseDuration = 60s` enforced inside `waitIfPaused()` while loop; `_isPaused = false` after 60s elapsed.
- [x] AC#4 PASS — Public getters `isPaused` (bool) and `remainingCalls` (int) available via `RateLimitMonitor.instance`.
- [x] AC#5 PASS — Pause gate gated by `apiUrl.startsWith(EnvConfig.platomBaseUrl)` — MedicalApps and WordPress base URLs never match, so their calls skip the gate entirely.
- [x] AC#6 PASS — `_isSingleRecordEndpoint()` checks for `/patient/` or `/search/` in URL; matching calls return immediately from `waitIfPaused()` without blocking.
- [x] AC#7 PASS — `updateFromHeaders()` only invoked for Plato URLs; internally uses `if (remaining != null)` null guard on each header parse.
- [x] AC#8 PASS — All state (`_remainingCalls`, `_rateLimitLimit`, `_isPaused`, `_pauseStartedAt`) is instance-level in the singleton — no SharedPreferences, sqflite, or disk persistence; app restart creates fresh default state.

## QA Result
QA=PASSED (8/8)

## Reviewer Notes

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-REVIEW
