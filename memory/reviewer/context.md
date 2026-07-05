# Reviewer — Context

Last Updated: 2026-07-05

## Last Reviewed Task
P5-T03 — Doctor Selection Screen (APPROVED — 2026-07-05)

## Review History
- P5-T03 (2026-07-05): APPROVED — v2-decisions Process 5 Step 3: "Doctor selection screen — active doctors (is_visible_in_app = true) for selected branch, No Preference option always shown at top" fully aligned. v2-ux-spec SCREEN: Booking Flow — Step 2 all requirements met. New Laravel API endpoint GET /api/v2/config/doctors handles branch filtering (Plato facility ID → MySQL branch_id via branches.plato_facility_id) and is_visible_in_app filtering. New Flutter GetDoctorsCall class. All 10 QA criteria pass.
- P2-T06 (2026-07-05): APPROVED.
- P2-T05 (2026-07-05): APPROVED.
- P2-T04 (2026-07-05): APPROVED.
- P2-T03 (2026-07-05): APPROVED.
- P2-T02 (2026-07-05): APPROVED.
- P2-T01 (2026-07-05): APPROVED.
- P5-T02 (2026-07-05): APPROVED.
- P5-T01 (2026-07-05): APPROVED.
- P4-T06 (2026-07-05): APPROVED.
- P4-T05 (2026-07-05): APPROVED.
- P4-T04 (2026-07-05): APPROVED.
- P4-T03 (2026-07-05): APPROVED.
- P4-T02 (2026-07-05): APPROVED.
- P4-T01 (2026-07-05): APPROVED.
- P3-T06 through P3-T01: All APPROVED.

## Key Standards
- All Flutter tasks must use EnvConfig for URLs (no hardcoded API URLs)
- Theme/token alignment verified against v2-ux-spec.md
- Old code preserved where needed for backward compatibility until full migration complete
- Laravel tasks must use session-based auth with Blade views (no API tokens in mobile code)
