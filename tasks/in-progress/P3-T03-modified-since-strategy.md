# P3-T03 — modified_since Strategy for Incremental Data Fetching

## Task ID
P3-T03

## Title
Implement modified_since Strategy for Incremental Data Fetching

## Description
Plato API supports the `modified_since` parameter (UNIX timestamp) to return only records changed since a given time. This reduces API calls, bandwidth, and rate limit consumption — critical for a mobile app. This task implements a `modified_since` strategy: on each successful list fetch, store the timestamp of the fetch; on subsequent fetches, pass `modified_since={last_timestamp}` so only new/changed records are returned. This applies to all Plato list endpoints that support it: `/patient`, `/appointment`, `/letter`, `/invoice`, `/facility`. The last-fetch timestamps should be persisted in `SharedPreferences` (keyed per endpoint).

## Dependencies
- P3-T02 (Pagination helper) — `modified_since` must work alongside pagination (params combined).

## Expected Files
**Modified:**
- `lib/backend/api_requests/api_manager.dart` — add `modified_since` timestamp tracking and injection
- `lib/backend/api_requests/api_calls.dart` — Plato list endpoint call classes updated to use modified_since
- `lib/app_state.dart` — optionally add `lastFetchTimestamps` map to `FFAppState`

**New:**
- `lib/backend/api_requests/modified_since_helper.dart` — standalone utility for timestamp persistence

## Acceptance Criteria
- [ ] A `getLastFetchTimestamp(endpointName)` and `setLastFetchTimestamp(endpointName, timestamp)` utility exists that persists to `SharedPreferences`.
- [ ] On first fetch of any Plato list endpoint, no `modified_since` param is sent (full fetch).
- [ ] On subsequent fetches, `modified_since={previous_fetch_timestamp}` is appended to the request params.
- [ ] If the endpoint supports `modified_since` and returns 0 records (no changes), the existing cached data is preserved — UI does not clear.
- [ ] Each endpoint tracks its own last-fetch timestamp independently (`patient`, `appointment`, `letter`, `invoice`, `facility`).
- [ ] A manual "force refresh" flag can bypass `modified_since` to force a full fetch (useful for pull-to-refresh).
- [ ] Timestamps are UNIX timestamps in seconds (integer), matching Plato API format.
- [ ] Works with pagination — `modified_since` param is included in every page of the pagination loop.

## Implementation Notes

## QA Notes

## Reviewer Notes

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-PROGRESS
