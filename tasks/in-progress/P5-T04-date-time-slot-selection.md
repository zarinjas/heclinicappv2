# P5-T04 — Date and Time Slot Selection

## Task ID
P5-T04

## Title
Date and Time Slot Selection

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T04 |
| Slug | date-time-slot-selection |
| Process | 5 — Booking Flow |
| Process Step | Step 4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P5-T03 |
| Blocked Reason | N/A |

---

## Description

Create the date and time slot selection screen for the Booking Flow (Step 3 of 4). The user selects a date from a calendar and then picks an available time slot. Available slots are fetched from the Plato API via POST /appointment/slots through the Laravel proxy. The month must be validated as future (no past months). Skeleton loader shows while fetching slots. Per v2-decisions.md Process 5 Step 4 and v2-ux-spec.md "Booking Flow — Step 3: Date & Time."

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 4
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 3: Date & Time" (line 521)
- `docs/api-guidelines.md` — POST /appointment/slots parameters (month, check_for_conflicts, simultaneous, interval, starttime, endtime)
- `docs/CODEBASE.md` — Section 11 (Plato API endpoints), Section 13 (Rate Limiting & Pagination)
- `docs/CODEBASE.md` — Section 15 (Appointment Booking Flow steps)
- `lib/backend/api_requests/rate_limit_monitor.dart` — existing rate limit handling

---

## Scope

### In Scope
- Create `DateTimeSlotSelectionScreen` widget in `lib/pages/booking/date_time_slot_screen.dart`
- App bar with "Book Appointment" title and back arrow
- Step indicator: 1 Branch > 2 Doctor > 3 Date & Time > 4 Confirm (step 3 active)
- Month selector: left/right arrows, current month label center (only future months)
- Calendar grid using `table_calendar` package (already in pubspec.yaml)
- Days with available slots highlighted on calendar
- Time slot chips below calendar on day tap: outlined accent (available), solid grey (unavailable), solid accent (selected)
- POST /appointment/slots API call via Laravel proxy with proper parameters
- Skeleton loader while fetching slots (matching calendar + chip shapes)
- "Continue" button — disabled until a time slot is selected
- Store selected date and time in booking flow model

### Out of Scope
- Creating appointment in Plato (that's Admin side, P5-T07)
- Confirmation screen (P5-T05)
- Modifying the existing select_date widget (build new booking-specific screen)

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/booking/date_time_slot_screen.dart` — new screen widget
- `lib/backend/api_requests/api_calls.dart` — add PostAppointmentSlotsCall class
- `lib/pages/booking/booking_flow_model.dart` — extend with date/time selection state

### API Endpoints
- `POST /api/v2/plato/appointment/slots` — check available slots
  - Body parameters (from api-guidelines.md):
    - `month`: string, e.g. "Aug 2026"
    - `check_for_conflicts`: array of calendar color IDs
    - `simultaneous`: int (1 for single booking)
    - `interval`: int (15 for 15-min slots)
    - `starttime`: string "HH:MM"
    - `endtime`: string "HH:MM"

### Data / Schema
- Booking model additions: selectedDate (DateTime), selectedTime (String), slotId (String)
- Calendar color IDs from GET /appointment/codes (already implemented as GetAppointmentCodeCall)

### UI Components
- Month selector: IconButton arrows (Icons.chevron_left/right), month label (heading-md 18px/600), center aligned
- Calendar grid: table_calendar with custom dayBuilder for slot availability indicators
- Day cell: accent dot or subtle background for days with slots
- Time slot chips: horizontal Wrap or GridView, border radius sm (8px), outlined accent for available, filled accent for selected
- Skeleton loader: Shimmer mimicking calendar grid and chip layout
- Continue button: Primary style, 52px height, radius 24px
- Empty state: "No available slots this month" when API returns empty
- Error state: error message with retry

### Constraints
- Only future months allowed — validate before API call (reject past months client-side)
- Use existing `ApiInterceptor` for error handling
- Respect rate limits — use existing `RateLimitMonitor` from P3-T05
- All calls through Laravel proxy

---

## Acceptance Criteria

- [ ] Step indicator shows 4 steps with step 3 active/highlighted
- [ ] Month selector shows current month, only navigates to future months (not past)
- [ ] Calendar grid renders with day cells, today highlighted
- [ ] Tapping a day with available slots shows time slot chips below the calendar
- [ ] POST /appointment/slots sends correct parameters (month, check_for_conflicts, simultaneous, interval, starttime, endtime)
- [ ] Available time slots display as tappable outlined accent chips
- [ ] Selected time slot highlights as filled accent chip
- [ ] Skeleton loader appears while slots are being fetched
- [ ] "Continue" button is disabled until a time slot is selected
- [ ] Tapping "Continue" navigates to confirmation screen with selected date/time
- [ ] Empty state displays when no slots are available for a selected day
- [ ] Back navigation preserves previously selected data

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
- [ ] Step indicator step 3 active — PASS / FAIL
- [ ] Month selector future-only — PASS / FAIL
- [ ] Calendar grid renders — PASS / FAIL
- [ ] Slot chips appear on day tap — PASS / FAIL
- [ ] API call parameters correct — PASS / FAIL
- [ ] Slot chip interaction — PASS / FAIL
- [ ] Skeleton loader — PASS / FAIL
- [ ] Continue button disabled state — PASS / FAIL
- [ ] Navigation to confirmation — PASS / FAIL
- [ ] Empty state — PASS / FAIL
- [ ] Back navigation preserves data — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
