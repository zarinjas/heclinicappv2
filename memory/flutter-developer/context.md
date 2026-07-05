# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
None.

## Last Completed Task
P1-T09 (remove-duplicate-booking-pages) — DONE. Consolidated 3 duplicate booking page directories (booking_pagecasse, select_datecase, select_date_reshecedule) into canonical widgets. Merged unique functionality via optional params (cas, namecase, isReschedule). Updated 5 caller sites. Deleted 6 files. Zero orphaned references.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
