# P5-T09 — Appointments Tab Display

## Task ID
P5-T09

## Title
Appointments Tab Display

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T09 |
| Slug | appointments-tab-display |
| Process | 5 — Booking Flow |
| Process Step | Step 9 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P5-T08 |
| Blocked Reason | N/A |

---

## Description

Ensure confirmed appointments appear in the Appointments tab (the 2nd tab in the 5-tab bottom navigation). After an appointment is confirmed by the admin (P5-T07) and the patient receives the notification (P5-T08), the appointment should display in a dedicated appointments list view showing upcoming and past appointments. Per v2-decisions.md Process 5 Step 9 and Process 4 Step 2 (5-tab bottom navigation: Home, Appointments, Health, Notifications, Profile).

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 9; Process 4, Step 2 (bottom nav 5 tabs)
- `docs/CODEBASE.md` — Section 11 (Plato API — GET /appointment), Section 4 (FFAppState)
- `docs/CODEBASE.md` — Section 6 (Routing — /myBookingPage)
- `lib/flutter_flow/nav/nav.dart` — existing routes, bottom nav configuration
- `docs/v2-ux-spec.md` — Design System (component library)
- Existing: `lib/booking_page/my_booking_page/` — current MyBookingPage widget

---

## Scope

### In Scope
- Ensure Appointments tab (index 1 in bottom nav) navigates to an appointments list screen
- Build or refactor the existing `MyBookingPageWidget` to display appointments from Plato API
- GET /appointment via Laravel proxy — display all appointments for the logged-in patient
- Split into "Upcoming" and "Past" sections (or tabs) based on appointment date
- Each appointment card shows:
  - Appointment date and time
  - Branch/clinic name
  - Doctor name (or "No Preference")
  - Status indicator (Confirmed, Pending, Completed, Cancelled)
  - Color coded by appointment calendar color
- Pull-to-refresh to reload appointments
- Apply V2 design system styling consistently
- Empty state when no appointments exist: "No appointments yet. Book your first appointment!"
- Loading state with skeleton cards while fetching
- Error state with retry when API call fails

### Out of Scope
- Changing bottom nav tab order (handled by P4-T02)
- Appointment rescheduling or cancellation (Process 10)
- Queue tracker (Process 10)
- Invoice integration in appointment detail (Process 10)

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/appointments/appointments_screen.dart` — new or refactored appointments list
- `lib/pages/appointments/appointment_card.dart` — reusable appointment card widget
- `lib/booking_page/my_booking_page/my_booking_page_widget.dart` — replace/refactor existing
- `lib/flutter_flow/nav/nav.dart` — ensure route for appointments tab is correct
- `lib/backend/api_requests/api_calls.dart` — ensure GetAppointmentCall is functional and uses proxy

### API Endpoints
- `GET /api/v2/plato/appointment` — returns list of appointments (existing GetAppointmentCall needs to use proxy URL)
- `GET /api/v2/plato/appointment` — with pagination (current_page) and modified_since for incremental refresh

### Data / Schema
- Appointment fields: id, patient_id, doctor_name, facility/branch_name, appointment_date, appointment_time, status, color (calendar color code), notes
- FFAppState variables used: idplato (for filtering patient appointments)

### UI Components
- Appointments tab: 2nd tab (index 1) in bottom nav bar
- Section headers: "Upcoming" and "Past" with heading-md (18px/600)
- Appointment card: surface bg, radius 16px, shadow low
  - Left color bar: 4px wide, colored by appointment calendar color
  - Top row: date + time (heading-sm 16px/600)
  - Middle row: branch name + doctor name (body-md 14px/400)
  - Bottom row: status chip (label 13px/500 with background color)
- Status chip colors: Confirmed = #10B981, Pending = #F59E0B, Completed = #6B7280, Cancelled = #EF4444
- Loading: skeleton appointment cards (3 shimmer placeholders)
- Empty: centered illustration + "No appointments yet" message
- Error: "Could not load appointments" with Retry button

### Constraints
- Use existing pagination helper (from P3-T02) for /appointment list
- Use modified_since (from P3-T03) for incremental refresh
- All API calls through Laravel proxy URL from EnvConfig
- Respect rate limits using existing rate limit monitor (P3-T05)

---

## Acceptance Criteria

- [ ] Appointments tab (index 1) in bottom nav displays an appointments list screen
- [ ] Appointments load from GET /appointment via Laravel proxy
- [ ] Appointments are split into Upcoming and Past sections based on date
- [ ] Each appointment card shows date, time, branch, doctor, and status
- [ ] Appointment cards are color-coded based on calendar color from Plato
- [ ] Pull-to-refresh reloads the appointments list
- [ ] Loading state shows skeleton cards while API call is in progress
- [ ] Empty state displays when the patient has no appointments
- [ ] Error state shows retry option when API call fails
- [ ] Tapping an appointment card shows additional detail (or navigates to detail screen)

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
- [ ] Appointments tab navigation — PASS / FAIL
- [ ] API loading from proxy — PASS / FAIL
- [ ] Upcoming/Past split — PASS / FAIL
- [ ] Appointment card rendering — PASS / FAIL
- [ ] Color coding — PASS / FAIL
- [ ] Pull-to-refresh — PASS / FAIL
- [ ] Loading skeleton — PASS / FAIL
- [ ] Empty state — PASS / FAIL
- [ ] Error state — PASS / FAIL
- [ ] Detail navigation — PASS / FAIL

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
