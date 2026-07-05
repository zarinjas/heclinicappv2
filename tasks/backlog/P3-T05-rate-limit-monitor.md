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
- [ ] After every Plato API call, the `x-ratelimit-limit` and `x-ratelimit-remaining` response headers are read and stored in the rate limit monitor.
- [ ] When `x-ratelimit-remaining` ≤ 5, all new Plato API calls are queued/paused (not sent) until `x-ratelimit-remaining` recovers.
- [ ] Paused calls are automatically resumed after a 60-second wait (default rate limit window) — the resumed calls proceed normally.
- [ ] A status indicator (e.g., `RateLimitMonitor.instance.isPaused` boolean + `remainingCalls` int) is available for the UI to display "Syncing..." status.
- [ ] Non-Plato APIs (MedicalApps, WordPress) are NOT affected by the Plato rate limit pause.
- [ ] The rate limit monitor does NOT block calls to `/patient/{id}`, `/search/patient`, or other single-record lookups — only list/bulk endpoints are paused when near limit.
- [ ] If `x-ratelimit-remaining` header is NOT present in the response (e.g., MedicalApps API), the monitor gracefully ignores it.
- [ ] All rate limit state is reset when the app restarts (in-memory only — no persistence needed).

## Implementation Notes

## QA Notes

## Reviewer Notes

## Status
BACKLOG
