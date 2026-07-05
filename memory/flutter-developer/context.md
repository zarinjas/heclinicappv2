# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P1-T09 (remove-duplicate-booking-pages) — IN-REVIEW. Consolidated 3 duplicate directories into canonical widgets with merged functionality.

## Last Completed Task
P1-T08 (remove-duplicate-profile-pages) — DONE. Audited profile/ and profile_copy/ (identical). Consolidated to ProfileWidget with clean /profile path. Updated main.dart (tab 3), nav.dart (route + standalone removal), push_notifications_handler.dart, index.dart. Deleted profile_copy/ directory. Zero ProfileCopy references across lib/.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
