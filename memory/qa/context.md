# QA — Context

Last Updated: 2026-07-05

## Last Verified Task
P4-T06 — Apply Global Loading, Empty, and Error States (PASSED — all 11 criteria)

## Verification History
- P4-T06 (2026-07-05): PASSED — 11/11 criteria. 4 reusable components created (skeleton_loaders with 5 variants + shimmer, empty_state_widget, error_state_widget, inline_spinner). Applied to Homepage, Appointments, Notifications, Reports/Health (3 tabs), Articles. All GIF loading animations replaced with shimmer skeletons. Error states with Try Again on all data screens. Empty states with correct messaging per v2-ux-spec.md table.
- P4-T05 (2026-07-05): PASSED — 10/10 criteria. V2 profile screen with avatar+initials header (FFAppState data), My Details section (→ ProfileEditPage), Settings section (Biometric Login ON/OFF, Notification Preferences bottom sheet, Change Password), About section (He Clinic Info, Privacy Policy, Terms of Service), Log Out with V2 confirmation modal (warning icon, destructive button). ProfileCopy directory already removed. No /profileCopy route in nav.dart.
- P4-T04 (2026-07-05): PASSED — 13/13 criteria. V2 home screen with hero slider (auto-scroll 4s + dots), 2x2 quick actions grid, upcoming appointment card, doctor horizontal list (via P4-T03), WordPress articles, video grid. All sections have skeleton/empty/error states. Loyalty widget stub (hidden — deferred to Process 10).
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
- `lib/front_page/homepage_new/homepage_new_widget.dart` — V2 home screen (rewritten from ~2700 to ~1287 lines)
- `lib/front_page/homepage_new/homepage_new_model.dart` — Home screen model with V2 async states
- `lib/theme/app_theme.dart` — V2 design system; verify all tokens match v2-ux-spec.md
- `lib/main.dart` — Theme wiring; verify theme/darkTheme are set
- `lib/components/doctor_card_widget.dart` — Doctor card component
- `lib/components/doctor_detail_sheet.dart` — Doctor detail bottom sheet
- `lib/components/doctor_list_widget.dart` — Dynamic doctor list with API fetch
- `lib/components/skeleton_loaders.dart` — 5 shimmer skeleton variants
- `lib/components/empty_state_widget.dart` — Reusable empty state
- `lib/components/error_state_widget.dart` — Reusable error state
- `lib/components/inline_spinner.dart` — Button loading spinner
- `lib/telehealth/all_doctor/all_doctor_widget.dart` — Refactored telehealth page
