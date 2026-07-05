# P3-T02 — Pagination Helper for Plato List Endpoints

## Task ID
P3-T02

## Title
Implement Pagination Helper — current_page Loop for All Plato List Endpoints

## Description
Plato API limits responses to **20 records per request**. The current app does not implement `current_page` pagination — data exceeding 20 records is silently truncated (see CODEBASE.md Section 13). This task implements a reusable pagination helper that loops through `current_page` until an empty response is returned, then merges all records into a single aggregated result. All Plato list endpoints (`/patient`, `/appointment`, `/letter`, `/invoice`, `/facility`, `/appointment/calendars`, `/appointment/codes`) must be updated to use this helper.

## Dependencies
- P3-T01 (Global API error interceptor) — pagination retries must pass through the interceptor for consistent error handling.

## Expected Files
**Modified:**
- `lib/backend/api_requests/api_manager.dart` — add `fetchAllPages()` pagination helper and/or augment `makeApiCall()` with pagination support
- `lib/backend/api_requests/api_calls.dart` — all Plato list endpoint call classes updated to use pagination

**New:**
- `lib/backend/api_requests/pagination_helper.dart` — standalone pagination utility (recommended approach)

## Acceptance Criteria
- [ ] A `fetchAllPages()` or equivalent pagination helper exists that accepts a base URL + params, loops `current_page=1`, `2`, `3`... until `response.jsonBody` is empty or returns fewer records than the per-page limit.
- [ ] `GetPatientCall` — GET `/patient` returns all patients, not just first 20.
- [ ] `GetAppointmentCall` and `GetAppointmentUpcomingCall` — GET `/appointment` returns all appointments.
- [ ] `LetterCall` — GET `/letter` returns all letters.
- [ ] `LetterCopyCall` — GET `/invoice` returns all invoices.
- [ ] `GetproviderCall` — GET `/facility` returns all doctors.
- [ ] `GetAppointmentCodeCall` — GET `/appointment/codes` returns all codes.
- [ ] `GetAppointmentCopyCall` — GET `/appointment/calendars` returns all calendars.
- [ ] The helper does NOT force pagination on non-list endpoints (e.g., `GET /patient/{id}`, `GET /search/patient`).
- [ ] Pagination calls respect rate limits — calls are paused if `x-ratelimit-remaining` is near zero (Note: actual rate limit pause is implemented in P3-T05; this task should at minimum pass the headers through for future use).
- [ ] Merged results preserve the same `ApiCallResponse` structure (status code, headers of final page, merged `jsonBody`).

## Implementation Notes
Created `lib/backend/api_requests/pagination_helper.dart` — standalone utility with `PaginationHelper.fetchAllPages()` that accepts a `PageFetcher` callback, loops `current_page=1,2,3...` until response returns fewer than 20 records (or empty), and merges all records into a single `ApiCallResponse`. Updated all 8 Plato list endpoint call classes in `api_calls.dart` to use the helper: GetPatientCall, GetproviderCall, LetterCall, GetInvoiceCall, GetAppointmentCall, GetAppointmentUpcomingCall, GetAppointmentCodeCall, GetAppointmentCopyCall. Non-list endpoints (GetPatientbyidCall, CeknumberphoneCall, GetReportCall, GetAppointmentDetailsCall, EditPatiendCall, DeletePatientForAdminOnlyCall) left untouched. Rate limit headers from the final page are preserved in the merged response for future P3-T05 use.

## QA Notes

## Reviewer Notes

## Status
IN-PROGRESS
