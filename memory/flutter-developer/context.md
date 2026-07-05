# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P3-T05 (rate-limit-monitor) — IN-REVIEW. Created `lib/backend/api_requests/rate_limit_monitor.dart` singleton that tracks `x-ratelimit-remaining` headers and pauses bulk Plato API calls when near limit. Modified `api_manager.dart` to integrate pause gate and header parsing. All handled transparently at ApiManager level.

## Last Completed Task
P3-T04 (exponential-backoff-429) — DONE.

## Known Constraints
- All Plato API calls must route through Laravel proxy
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
P3-T06 (laravel-proxy-url-audit) in BACKLOG.
