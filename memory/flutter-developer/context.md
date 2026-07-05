# Flutter Developer — Context

Last Updated: 2026-07-04

## Active Task
P1-T04 (fix-hardcoded-appointment-id) — IN-REVIEW. Added `appointmentId` dynamic parameter to `GetAppointmentDetailsCall.call()`, replaced hardcoded ID in URL, added mock server route `GET /platom/appointment/:id`. No local call sites found (managed by FlutterFlow).

## Last Completed Task
P1-T03 (fix-minsdk-version) — DONE. Changed minSdkVersion 35 → 23 in android/app/build.gradle.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
