# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
None.

## Last Completed Task
P1-T10 (remove-hardcoded-doctor-modals) — IN-REVIEW. Replaced 17 hardcoded doctor modal components (modal_arif/ through modal_wong/) with a single reusable `DoctorDetailBottomSheetWidget` that accepts `doctorName`, `specialty`, `branchName`, `photoAsset`, `bio` parameters. Updated `all_doctor_widget.dart` and `all_doctor_model.dart` in `lib/telehealth/`. Deleted 34 files (17 widget+model pairs). Zero orphaned references confirmed via grep.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
