# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P1-T02 (reroute-platome-api-calls-to-laravel-proxy) — IN-REVIEW awaiting QA

## Last Completed Task
P1-T02 — Rerouted all 15 PlatomeApiGroup call classes to use FFAppState().tokenauth via Laravel proxy. Created PlatomeApiGroup helper class. Updated EnvConfig default URL.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
