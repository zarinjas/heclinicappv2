# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P3-T04 (exponential-backoff-429) — IN-REVIEW. Implemented retry loop with exponential backoff (1s, 2s, 4s, 8s) in `makeApiCall()` in `api_manager.dart`. Added `OnRateLimitedCallback` to `ApiInterceptor`, registered toast in `main.dart`.

## Last Completed Task
P3-T03 (modified-since-strategy) — DONE.

## Known Constraints
- All Plato API calls must route through Laravel proxy
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
P3-T05 and P3-T06 in BACKLOG.
