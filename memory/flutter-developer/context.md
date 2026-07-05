# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P4-T03 — Replace 17 Hardcoded Doctor Modals with Dynamic Doctor List (IN-REVIEW)

## Recent Work
- P4-T03 — Dynamic Doctor List: Created DoctorCardWidget, DoctorDetailSheet, DoctorListWidget; refactored AllDoctorWidget from 3434 lines (17 hardcoded doctors) to 85 lines using dynamic components (IN-REVIEW)
- P4-T02 — Bottom Nav 5 Tabs: Updated main.dart NavBarPage + nav.dart routes (DONE)
- P3-T06 — Laravel Proxy URL Audit (DONE)
- P3-T05 — Rate Limit Monitor (DONE)
- P3-T04 — HTTP 429 Exponential Backoff (DONE)
- P3-T03 — modified_since Strategy (DONE)
- P3-T02 — Pagination Helper (DONE)
- P3-T01 — Global API Error Interceptor (DONE)

## Implementation Notes (P4-T03)
- Created `lib/components/doctor_card_widget.dart` — reusable card with compact/full layouts
- Created `lib/components/doctor_detail_sheet.dart` — bottom sheet with V2 design tokens
- Created `lib/components/doctor_list_widget.dart` — fetches from GET /facility, handles loading/error/empty states
- Doctor photos use initials fallback (Plato doesn't provide photo URLs yet)
- `is_visible_in_app` filtering prepared for CMS (Process 9)
- Book Appointment button pops back; actual booking wiring is Process 5

## Implementation Notes (P4-T01)
- Created `lib/theme/app_theme.dart` with AppColors, AppSpacing, AppRadius, AppShadows, light ThemeData, dark ThemeData
- Wired into `main.dart` via `theme` and `darkTheme` parameters
- Used `google_fonts` for Plus Jakarta Sans
- Old `flutter_flow_theme.dart` retained for backward compatibility
- Existing pages still use old theme — migration in P4-T02 through P4-T06

## Key Files
- `lib/theme/app_theme.dart` — New V2 theme system
- `lib/main.dart` — App entry point with new theme wiring
- `lib/flutter_flow/flutter_flow_theme.dart` — Old theme (preserved)
- `lib/env_config.dart` — Environment config
- `lib/backend/api_requests/api_interceptor.dart` — API error interceptor
- `lib/backend/api_requests/api_calls.dart` — All API endpoint definitions
- `lib/components/doctor_card_widget.dart` — Reusable doctor card
- `lib/components/doctor_detail_sheet.dart` — Doctor detail bottom sheet
- `lib/components/doctor_list_widget.dart` — Dynamic doctor list with API fetch
