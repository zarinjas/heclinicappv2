# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P4-T05 — Consolidate Profile Screen (IN-REVIEW)

## Recent Work
- P4-T05 — Consolidate Profile Screen: Rewrote profile_widget.dart with V2 layout per v2-ux-spec.md Section 4. Removed AppBar, added avatar+initials header (FFAppState data), My Details/Settings/About sections with V2 card rows, Log Out with V2 confirmation modal. Cleaned up profile_model.dart. ProfileCopy directory already removed from codebase — no references found. (IN-REVIEW)
- P4-T04 — Home Screen Redesign: Rewrote HomepageNewWidget from ~2700 to ~1287 lines with V2 design system. Implemented: hero slider with auto-scroll, 2x2 quick actions grid, upcoming appointment card, doctor horizontal list (via P4-T03 widget), WordPress articles, video grid. All sections with skeleton/empty/error states. (DONE)
- P4-T03 — Dynamic Doctor List: Created DoctorCardWidget, DoctorDetailSheet, DoctorListWidget; refactored AllDoctorWidget from 3434 lines (17 hardcoded doctors) to 85 lines using dynamic components (DONE)
- P4-T02 — Bottom Nav 5 Tabs: Updated main.dart NavBarPage + nav.dart routes (DONE)
- P3-T06 — Laravel Proxy URL Audit (DONE)
- P3-T05 — Rate Limit Monitor (DONE)
- P3-T04 — HTTP 429 Exponential Backoff (DONE)
- P3-T03 — modified_since Strategy (DONE)
- P3-T02 — Pagination Helper (DONE)
- P3-T01 — Global API Error Interceptor (DONE)

## Implementation Notes (P4-T04)
- Completely rewrote `homepage_new_widget.dart` with V2 layout per v2-ux-spec.md Section 4
- Hero slider uses PageView + Timer.periodic (auto-scroll 4s) instead of carousel_slider
- Articles switched from Firestore to WordPress API (GetArticlesCall) per CMS roadmap
- Doctor section delegates to P4-T03 DoctorListWidget
- Loyalty widget hidden (stub — no data source yet for Process 10)
- All sections handle loading (skeleton), empty (hide or empty state message), and error (retry) states
- Used V2 theme from app_theme.dart alongside existing FlutterFlowTheme

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
