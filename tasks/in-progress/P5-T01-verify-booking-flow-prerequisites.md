# P5-T01 — Verify Booking Flow Prerequisites

## Task ID
P5-T01

## Title
Verify Booking Flow Prerequisites

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T01 |
| Slug | verify-booking-flow-prerequisites |
| Process | 5 — Booking Flow |
| Process Step | Step 1 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Before starting the mobile booking flow screens, verify that all server-side prerequisites are met. This is a validation task — confirm the Laravel proxy controller is functional for the booking endpoints and that the Plato Calendar Setup (Process 2 Step 6) is confirmed ready. Per v2-decisions.md Process 5 Step 1: "Process 2 step 6 complete (Calendar Setup in Admin Panel)."

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 1 (Prerequisite)
- `docs/api-guidelines.md` — Section on POST /appointment/slots parameters (month, check_for_conflicts, simultaneous, interval, starttime, endtime)
- `docs/CODEBASE.md` — Section 11 (Plato API), Section 15 (Appointment Booking Flow)
- `docs/v2-ux-spec.md` — Booking Flow screens (all 4 steps)

---

## Scope

### In Scope
- Verify Laravel proxy can forward GET /api/v2/plato/facility and return valid response
- Verify Laravel proxy can forward GET /api/v2/plato/appointment/calendars
- Verify Laravel proxy can forward POST /api/v2/plato/appointment/slots with proper parameters
- Confirm Plato /systemsetup endpoint is accessible for calendar validation
- Document any gaps that block Process 5 tasks

### Out of Scope
- Creating Flutter booking screens (those are separate tasks)
- Creating Laravel admin appointment management UI (P5-T07)
- Full Process 2 (Laravel Admin Panel) implementation

---

## Technical Spec

### API Endpoints to Verify
- `GET /api/v2/plato/facility` — returns list of facilities (needed for branch/doctor data)
- `GET /api/v2/plato/appointment/calendars` — returns available calendars
- `GET /api/v2/plato/appointment/codes` — returns appointment color codes
- `POST /api/v2/plato/appointment/slots` — checks slot availability (verification with test payload)

### Test Payload for /appointment/slots
```json
{
  "month": "Aug 2026",
  "check_for_conflicts": ["color-id-here"],
  "simultaneous": 1,
  "interval": 15,
  "starttime": "09:00",
  "endtime": "17:00"
}
```

### Files to Check
- `laravel/routes/api.php` — confirm proxy routes exist for all Plato endpoints
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — confirm proxy handles all HTTP methods
- `laravel/.env` — confirm PLATO_API_TOKEN is set and valid

### Constraints
- Laravel proxy must forward Plato access token from .env (never in mobile APK)
- All proxy calls must require Sanctum auth (return 401 if unauthenticated)
- If any endpoint fails, document the exact error and escalate

---

## Acceptance Criteria

- [ ] GET /facility via Laravel proxy returns valid JSON with facility data
- [ ] GET /appointment/calendars via Laravel proxy returns calendar list
- [ ] POST /appointment/slots via Laravel proxy returns slot availability (may be empty but not an error)
- [ ] Sanctum auth is enforced — unauthenticated request returns 401
- [ ] Gaps or blockers are documented in the Implementation Notes section
- [ ] Plato access token is confirmed active (proxy calls succeed, not 403)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled}

### Files Changed
- {To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] GET /facility — PASS / FAIL
- [ ] GET /appointment/calendars — PASS / FAIL
- [ ] POST /appointment/slots — PASS / FAIL
- [ ] Sanctum auth enforced — PASS / FAIL
- [ ] Gaps documented — PASS / FAIL
- [ ] Token active — PASS / FAIL

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: N/A (validation task)

### Rejection Reason
{If REJECTED}
