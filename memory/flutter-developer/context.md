# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P5-T03 — Doctor Selection Screen (DONE)

## Recent Work
- P5-T03 — Doctor Selection Screen (DONE): Re-implemented with new GetDoctorsCall (Laravel `/api/v2/config/doctors`) for branch_id + visible=true filtering. Branch filtering resolves Plato facility ID via MySQL branches.plato_facility_id → doctors.branch_id. is_visible_in_app filtering via visible query param. 10/10 QA pass, Reviewer APPROVED. Also created Laravel DoctorConfigController and route.
- P5-T02 — Branch Selection Screen: Created BranchSelectionScreenWidget with step indicator, API-driven branch list from GET /facility via existing GetproviderCall, card design with V2 design system accent selection highlight, Next navigation button. (DONE)
- P4-T06 — Global States: Created skeleton_loaders, empty_state_widget, error_state_widget, inline_spinner (DONE)
- P4-T05 — Consolidate Profile Screen: Rewrote profile_widget.dart with V2 layout (DONE)
- P4-T04 — Home Screen Redesign: Rewrote HomepageNewWidget with V2 design system (DONE)
- P4-T03 — Dynamic Doctor List: Created DoctorCardWidget, DoctorDetailSheet, DoctorListWidget (DONE)

## Key Files
- `lib/pages/booking/doctor_selection_screen.dart` — UPDATED: uses GetDoctorsCall with branch/visible params
- `lib/pages/booking/branch_selection_screen.dart` — Branch selection screen
- `lib/pages/booking/booking_flow_model.dart` — Shared booking flow state
- `lib/backend/api_requests/api_calls.dart` — Added GetDoctorsCall class
- `lib/env_config.dart` — Environment config
