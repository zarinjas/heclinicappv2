# QA — Context

Last Updated: 2026-07-05

## Last Verified Task
P5-T03 — Doctor Selection Screen (PASSED — 10/10 criteria, re-verified after Process 2 completion)

## Verification History
- P5-T03 (2026-07-05): PASSED — 10/10 criteria (re-verified). Previously FAILED (8/10 due to missing branch/is_visible_in_app filtering). Now all 10 pass: branch filtering via new Laravel GET /api/v2/config/doctors endpoint (resolves Plato facility_id → MySQL branch_id), is_visible_in_app filtering via visible=true param + base where('is_visible_in_app', true). New files: laravel/app/Http/Controllers/Api/DoctorConfigController.php, route GET /api/v2/config/doctors. New Flutter call: GetDoctorsCall in api_calls.dart.
- P2-T06 (2026-07-05): PASSED — 9/9 criteria.
- P2-T05 (2026-07-05): PASSED — 10/10 criteria.
- P2-T04 (2026-07-05): PASSED — 10/10 criteria.
- P2-T03 (2026-07-05): PASSED — 9/9 criteria.
- P2-T02 (2026-07-05): PASSED — 8/8 criteria.
- P5-T02 (2026-07-05): PASSED — 9/9 criteria.
- P5-T01 (2026-07-05): PASSED — 6/6 criteria.
- P4-T06 (2026-07-05): PASSED — 11/11 criteria.
- P4-T05 (2026-07-05): PASSED — 10/10 criteria.
- P4-T04 (2026-07-05): PASSED — 13/13 criteria.
- P4-T03 (2026-07-05): PASSED — 8/8 criteria.
- P4-T02 (2026-07-05): PASSED — 5 tabs correct order.
- P4-T01 (2026-07-05): PASSED — theme file created.
- P3-T06 through P3-T01: All PASSED.

## Key Files to Monitor
- `laravel/app/Http/Controllers/Api/DoctorConfigController.php` — NEW: returns doctors from MySQL with branch_id/is_visible_in_app filtering
- `laravel/routes/api.php` — Added GET /api/v2/config/doctors route
- `lib/backend/api_requests/api_calls.dart` — Added GetDoctorsCall class
- `lib/pages/booking/doctor_selection_screen.dart` — Updated to use GetDoctorsCall with branch/visible params
- `laravel/app/Services/PlatoProxyService.php` — Full proxy service
