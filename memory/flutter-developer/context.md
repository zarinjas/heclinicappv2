# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P5-T02 — Branch Selection Screen (IN-REVIEW)

## Recent Work
- P5-T02 — Branch Selection Screen: Created BranchSelectionScreenWidget with step indicator, API-driven branch list from GET /facility via existing GetproviderCall, card design with V2 design system accent selection highlight, Next navigation button. Includes loading skeleton, empty state, and error state with retry. BookingFlowModel singleton stores selected branch for subsequent screens. (IN-REVIEW)
- P4-T06 — Global States: Created 4 reusable components (skeleton_loaders, empty_state_widget, error_state_widget, inline_spinner) per v2-ux-spec.md Section 2. Applied to Homepage, Appointments, Notifications, Reports/Health, and Articles screens. Replaced GIF loading animations with shimmer skeletons. Added empty/error states to all data screens. (DONE)
- P4-T05 — Consolidate Profile Screen: Rewrote profile_widget.dart with V2 layout per v2-ux-spec.md Section 4. Removed AppBar, added avatar+initials header (FFAppState data), My Details/Settings/About sections with V2 card rows, Log Out with V2 confirmation modal. Cleaned up profile_model.dart. ProfileCopy directory already removed from codebase — no references found. (DONE)
- P4-T04 — Home Screen Redesign: Rewrote HomepageNewWidget from ~2700 to ~1287 lines with V2 design system. Implemented: hero slider with auto-scroll, 2x2 quick actions grid, upcoming appointment card, doctor horizontal list (via P4-T03 widget), WordPress articles, video grid. All sections with skeleton/empty/error states. (DONE)
- P4-T03 — Dynamic Doctor List: Created DoctorCardWidget, DoctorDetailSheet, DoctorListWidget; refactored AllDoctorWidget from 3434 lines (17 hardcoded doctors) to 85 lines using dynamic components (DONE)
- P4-T02 — Bottom Nav 5 Tabs: Updated main.dart NavBarPage + nav.dart routes (DONE)
- P3-T06 — Laravel Proxy URL Audit (DONE)
- P3-T05 — Rate Limit Monitor (DONE)
- P3-T04 — HTTP 429 Exponential Backoff (DONE)
- P3-T03 — modified_since Strategy (DONE)
- P3-T02 — Pagination Helper (DONE)
- P3-T01 — Global API Error Interceptor (DONE)

## Implementation Notes (P5-T02)
- Reused existing GetproviderCall for GET /facility — no duplicate API endpoint needed
- BookingFlowModel follows singleton pattern matching FFAppState
- DoctorSelectionScreen route at `/doctorSelectionScreen` referenced for Next navigation (P5-T03)
- Branch image/address/hours mapped to available facility response fields (id, name, nric)
- V2 accent color (#00C9A7) used for active selection border and step indicator
- No external Provider dependency — BookingFlowModel is singleton accessed throughout booking flow

## Key Files
- `lib/pages/booking/branch_selection_screen.dart` — Branch selection screen (NEW)
- `lib/pages/booking/booking_flow_model.dart` — Shared booking flow state (NEW)
- `lib/theme/app_theme.dart` — V2 theme system
- `lib/main.dart` — App entry point
- `lib/flutter_flow/nav/nav.dart` — GoRouter routes
- `lib/env_config.dart` — Environment config
- `lib/backend/api_requests/api_interceptor.dart` — API error interceptor
- `lib/backend/api_requests/api_calls.dart` — All API endpoint definitions
