# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
None.

## Last Completed Task
P1-T06 (remove-duplicate-api-call-classes) — IN-REVIEW. Deleted `GetPatientbyidCopyCall` class from api_calls.dart (duplicate of GetPatientbyidCall). Renamed `LetterCopyCall` → `GetInvoiceCall` in api_calls.dart. Updated 12 call sites in reports_widget.dart and 4 in visits_widget.dart. Verified zero remaining references to old class names.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
