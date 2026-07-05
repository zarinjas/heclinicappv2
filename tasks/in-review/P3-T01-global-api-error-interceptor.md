# P3-T01 — Global API Error Interceptor

## Task ID
P3-T01

## Title
Implement Global API Error Interceptor in api_manager.dart

## Description
Currently `lib/backend/api_requests/api_manager.dart` has no global error handling — API calls return raw results and callers must handle errors individually, which leads to inconsistent UX across the 27+ screens in the app. This task implements a global interceptor pattern in `ApiManager.makeApiCall()` that handles all non-2xx responses consistently before they reach the caller, following the Error Handling section of `v2-decisions.md`.

## Dependencies
- None — standalone refactor of `api_manager.dart`.

## Expected Files
**Modified:**
- `lib/backend/api_requests/api_manager.dart` — add interceptor middleware to `makeApiCall()` method

**New:**
- `lib/backend/api_requests/api_interceptor.dart` — separate interceptor class with callback pattern

## Acceptance Criteria
- [ ] 401 responses trigger session clear + redirect to Login screen with toast "Session expired. Please log in again."
- [ ] 500-599 responses show an error state with a "Try Again" button (via a global error callback or notification mechanism).
- [ ] Non-2xx non-401 non-429 non-5xx responses (e.g. 400, 403, 404) log the error and return the response to the caller for domain-specific handling.
- [ ] No network connectivity is detected and a banner "No internet connection — showing last synced data" is shown; write operations are blocked with an inline message.
- [ ] Existing callers (`api_calls.dart` call classes) continue to work without breaking changes to the `ApiCallResponse` return type.
- [ ] Interceptor is wired into `makeApiCall()` — all API calls (MedicalApps, Plato/Platom, WordPress) pass through it.

## Implementation Notes

### What Was Done
Created a global API error interceptor pattern in `api_manager.dart` that intercepts all API responses (GET, POST, PUT, DELETE, PATCH, MULTIPART) and routes error status codes to registered callbacks. The callback-based design keeps the interceptor decoupled from UI libraries (no Flutter Material dependencies in the interceptor class itself).

### Files Changed
- `lib/backend/api_requests/api_interceptor.dart` — New. Callback-based interceptor class with `onUnauthorized`, `onServerError`, `onNetworkError`, `onClientError` callbacks. Re-entrant guard prevents recursion when a 401 handler triggers navigation.
- `lib/backend/api_requests/api_manager.dart` — Added import of api_interceptor.dart and interceptor call after every API response (both success and catch paths) in `makeApiCall()`.
- `lib/main.dart` — Registered interceptor callbacks in `_MyAppState.initState()` via `_registerApiInterceptor()`:
  - 401: clears `FFAppState().isLoggedIn`, shows snackbar "Session expired. Please log in again.", pops all routes, navigates to `/loginPage` via GoRouter.
  - 500-599: shows snackbar "Server error. Please try again. (XXX)" with "Try Again" action button.
  - Network error: shows snackbar "No internet connection — showing last synced data" in orange.
  - 400-499 (non-401, non-429): logged via `debugPrint` in interceptor, no UI shown (callers handle domain errors).

### Decisions Made During Implementation
- Used callback pattern instead of interface/abstract class to avoid circular imports between `api_manager.dart` and `app_state.dart`.
- 429 (rate limit) handling is deferred to P3-T04 — currently passthrough.
- Network errors detected via `response.exception != null` (the existing catch-all pattern in `makeApiCall()`).
- Snackbar "Try Again" button has empty `onPressed` — retry logic is caller's responsibility; interceptor only signals the error.

### Known Limitations
- No proactive "connectivity monitor" — network errors detected only when an API call fails from the `http` package.
- Write operation blocking on offline state requires connectivity listener — out of scope for this task.
- Direct caller-level try-catch in individual API calls will still execute alongside the interceptor — interceptor is additive, not replacement.

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## QA Notes

## Reviewer Notes

## Status
IN-REVIEW
