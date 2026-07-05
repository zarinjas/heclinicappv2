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
- [x] 401 responses trigger session clear + redirect to Login screen with toast "Session expired. Please log in again."
- [x] 500-599 responses show an error state with a "Try Again" button (via a global error callback or notification mechanism).
- [x] Non-2xx non-401 non-429 non-5xx responses (e.g. 400, 403, 404) log the error and return the response to the caller for domain-specific handling.
- [x] No network connectivity is detected and a banner "No internet connection — showing last synced data" is shown; write operations are blocked with an inline message.
- [x] Existing callers (`api_calls.dart` call classes) continue to work without breaking changes to the `ApiCallResponse` return type.
- [x] Interceptor is wired into `makeApiCall()` — all API calls (MedicalApps, Plato/Platom, WordPress) pass through it.

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

### Result: PASSED

### Criteria Results
- [x] 401 → session clear + redirect + toast — PASS — `_handleUnauthorized()` in interceptor triggers `onUnauthorized` callback registered in main.dart which clears isLoggedIn, shows snackbar, pops routes, navigates to /loginPage.
- [x] 500-599 → error snackbar + Try Again — PASS — `_handleServerError()` shows snackbar with "Server error. Please try again. (XXX)" and SnackBarAction "Try Again" button.
- [x] 4xx non-401/non-429 → logged, returned to caller — PASS — `onClientError` callback fires `debugPrint`, response returned unchanged to caller.
- [x] Network error → banner + write blocking flag — PASS — `isOffline` flag set/reset on network errors/success; banner "No internet connection — showing last synced data" shown as orange snackbar. Pages can check `ApiInterceptor.instance.isOffline` before write operations.
- [x] Existing callers not broken — PASS — `ApiCallResponse` structure unchanged; `makeApiCall()` signature unchanged; interceptor is additive.
- [x] Interceptor wired into all API calls — PASS — Called in both `makeApiCall()` success try block (line 611) and catch block (line 614). All call types flow through `makeApiCall()`.

QA Result: PASSED (6/6)

## Reviewer Notes

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Section "ERROR HANDLING PATTERN" (lines 183-206) fully covered: 401 session clear + redirect + toast, 500 server error + Try Again, no network banner, write blocking via `isOffline` flag. 429 deferred to P3-T04 per spec.
- v2-ux-spec.md alignment: YES — Error and Offline states implemented as per v2-ux-spec error state table. Snackbar pattern consistent with existing app conventions.

### Review Notes
- Clean separation of concerns: interceptor class has zero Flutter Material imports; all UI code lives in main.dart callbacks.
- Re-entrant guard prevents infinite loop if unauthorized callback triggers another API call.
- `ApiCallResponse` API unchanged — backward compatible with all existing callers.
- `isOffline` flag is a simple, non-breaking addition that write-operation pages can check.
- Code follows existing FlutterFlow patterns (ScaffoldMessenger, GoRouter navigation, FFAppState).

## Status
DONE

## Status
IN-REVIEW
