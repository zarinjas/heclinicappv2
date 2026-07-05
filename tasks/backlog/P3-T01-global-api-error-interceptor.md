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

**New (optional):**
- `lib/backend/api_requests/api_interceptor.dart` — separate interceptor class if preferred over inline logic

## Acceptance Criteria
- [ ] 401 responses trigger session clear + redirect to Login screen with toast "Session expired. Please log in again."
- [ ] 500-599 responses show an error state with a "Try Again" button (via a global error callback or notification mechanism).
- [ ] Non-2xx non-401 non-429 non-5xx responses (e.g. 400, 403, 404) log the error and return the response to the caller for domain-specific handling.
- [ ] No network connectivity is detected and a banner "No internet connection — showing last synced data" is shown; write operations are blocked with an inline message.
- [ ] Existing callers (`api_calls.dart` call classes) continue to work without breaking changes to the `ApiCallResponse` return type.
- [ ] Interceptor is wired into `makeApiCall()` — all API calls (MedicalApps, Plato/Platom, WordPress) pass through it.

## Implementation Notes

## QA Notes

## Reviewer Notes

## Status
BACKLOG
