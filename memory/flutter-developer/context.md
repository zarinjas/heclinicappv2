# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P3-T02 (pagination-helper) — IN-REVIEW. Created `lib/backend/api_requests/pagination_helper.dart` with `PaginationHelper.fetchAllPages()` that loops `current_page` until response is empty. Updated all 8 Plato list endpoint call classes in `api_calls.dart` to use the helper.

## Last Completed Task
P3-T01 (global-api-error-interceptor) — DONE. Implemented global API error interceptor via callback-based `ApiInterceptor` class.

## Known Constraints
- All Plato API calls must route through Laravel proxy
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
P3-T02 through P3-T06 in BACKLOG.
