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
- Added exponential backoff retry loop in `makeApiCall()` (`api_manager.dart:550-632`)
- Retry constants: `kMaxRetries = 4`, `kBaseDelayMs = 1000` — produces delays 1s, 2s, 4s, 8s via bit shift
- 429 check happens BEFORE cache store — failed 429 responses are not cached
- Interceptor `handleResponse` only called once per call (after retries exhausted or on success) — prevents duplicate toast/snackbar spam
- Added `OnRateLimitedCallback` typedef + `onRateLimited` field to `ApiInterceptor`
- Registered `onRateLimited` callback in `main.dart` — shows orange SnackBar: "Too many requests, please try again shortly."
- Retry state (`retryCount`) is local to `makeApiCall` — concurrent calls independently back off
- Non-429 status codes flow through to existing interceptor handlers without retry
- Debug logging: retry count and delay logged via `debugPrint`

## QA Notes
- [x] AC1 (Retry with delays 1s, 2s, 4s, 8s): PASS — `kBaseDelayMs * (1 << (retryCount - 1))` produces exactly 1000, 2000, 4000, 8000ms. `kMaxRetries = 4` → 5 total attempts.
- [x] AC2 (Future.delayed non-blocking): PASS — `await Future.delayed(Duration(milliseconds: delayMs))` is non-blocking to UI thread.
- [x] AC3 (All retries fail → toast): PASS — Exhausted retries fall through to `ApiInterceptor.handleResponse()` → `onRateLimited` callback → SnackBar with exact text.
- [x] AC4 (All API call types covered): PASS — Retry loop wraps entire switch: GET, DELETE (body/no-body), POST, PUT, PATCH, multipart.
- [x] AC5 (Concurrent calls independent): PASS — `retryCount` is local to each `makeApiCall()` invocation.
- [x] AC6 (No retry for non-429): PASS — Explicit `statusCode == 429` guard; non-429 codes skip retry block.
- [x] AC7 (Debug logging): PASS — `debugPrint('ApiManager: HTTP 429 — retry $retryCount/$kMaxRetries in ${delayMs}ms for $callName')`.

**QA Result: PASSED** (7/7)

## Reviewer Notes

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-REVIEW
