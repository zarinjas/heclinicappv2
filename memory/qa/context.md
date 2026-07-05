# QA — Context

Last Updated: 2026-07-05

## Last Verified Task
P4-T03 — Replace 17 Hardcoded Doctor Modals with Dynamic Doctor List (PASSED — all 8 criteria)

## Verification History
- P4-T03 (2026-07-05): PASSED — 8/8 criteria. DoctorListWidget fetches from GET /facility, DetailSheet opens on tap, dismissable, hardcoded modals removed from navigation, skeleton/empty/error states all present, pagination handled via PaginationHelper.
- P4-T02 (2026-07-05): PASSED — 5 tabs correct order, V2 styling confirmed, notification badge, routes updated
- P4-T01 (2026-07-05): PASSED — theme file created, all color/token/text/light/dark criteria met
- P3-T06 (2026-07-05): PASSED
- P3-T05 (2026-07-05): PASSED
- P3-T04 (2026-07-05): PASSED
- P3-T03 (2026-07-05): PASSED
- P3-T02 (2026-07-05): PASSED
- P3-T01 (2026-07-05): PASSED

## Key Files to Monitor
- `lib/theme/app_theme.dart` — V2 design system; verify all tokens match v2-ux-spec.md
- `lib/main.dart` — Theme wiring; verify theme/darkTheme are set
- `lib/components/doctor_card_widget.dart` — Doctor card component
- `lib/components/doctor_detail_sheet.dart` — Doctor detail bottom sheet
- `lib/components/doctor_list_widget.dart` — Dynamic doctor list with API fetch
- `lib/telehealth/all_doctor/all_doctor_widget.dart` — Refactored telehealth page
