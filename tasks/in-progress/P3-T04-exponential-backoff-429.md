# P3-T04 — HTTP 429 Exponential Backoff

## Task ID
P3-T04

## Title
Implement HTTP 429 Exponential Backoff

## Description
Plato API enforces rate limits and returns HTTP 429 (Too Many Requests) when the limit is exceeded (see docs/api-guidelines.md Section 3). The current app has no handling for 429 — rate-limited requests fail silently (see CODEBASE.md Section 19 Issue #5). This task implements exponential backoff with automatic retry: wait 1s, 2s, 4s, 8s between retries (4 total retries, after which fail gracefully and show a toast: "Too many requests, please try again shortly."). The backoff logic must be implemented in the global interceptor (`api_manager.dart`) and apply to ALL API calls (MedicalApps, Plato, WordPress).

## Dependencies
- P3-T01 (Global API error interceptor) — 429 handling is a subset of the interceptor.

## Expected Files
**Modified:**
- `lib/backend/api_requests/api_manager.dart` — add 429 detection + exponential backoff retry loop in `makeApiCall()`

**New (optional):**
- `lib/backend/api_requests/rate_limit_handler.dart` — separate class if backoff logic is complex

## Acceptance Criteria
- [ ] When any API call receives HTTP 429, the call is automatically retried with delays: 1s, 2s, 4s, 8s (4 total retries, 5 total attempts including the first).
- [ ] Retry delays use `Future.delayed()` with `Timer` — non-blocking to the UI.
- [ ] If all 4 retries fail with 429, the call returns the 429 response and a toast/snackbar shows: "Too many requests, please try again shortly."
- [ ] The backoff applies to ALL API call types (GET, POST, PUT, DELETE, MULTIPART).
- [ ] Concurrent API calls do not share retry state — each call independently backs off.
- [ ] No retry for non-429 status codes — other error codes (401, 500, etc.) are handled by the global interceptor (P3-T01) without retry.
- [ ] Retry counter is logged to console in debug mode for observability.

## Implementation Notes

## QA Notes

## Reviewer Notes

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-PROGRESS
