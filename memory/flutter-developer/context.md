# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P3-T01 (global-api-error-interceptor) — IN-REVIEW. Implemented global API error interceptor via callback-based `ApiInterceptor` class. Created `lib/backend/api_requests/api_interceptor.dart`, wired into `ApiManager.makeApiCall()`, registered callbacks in `lib/main.dart`.

## Last Completed Task
P1-T10 (remove-hardcoded-doctor-modals) — DONE. Replaced 17 hardcoded doctor modal components with single reusable `DoctorDetailBottomSheetWidget`.

## Known Constraints
- All Plato API calls must route through Laravel proxy
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
P3-T02 through P3-T06 in BACKLOG.
