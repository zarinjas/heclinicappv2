# P5-T03 — Doctor Selection Screen

## Task ID
P5-T03

## Title
Doctor Selection Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T03 |
| Slug | doctor-selection-screen |
| Process | 5 — Booking Flow |
| Process Step | Step 3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P5-T02 |
| Blocked Reason | N/A |

---

## Description

Create the doctor selection screen for the Booking Flow (Step 2 of 4). The user selects a doctor (or "No Preference") for the previously chosen branch. Only doctors with `is_visible_in_app = true` for the selected facility are shown. The "No Preference" option is always displayed first. Per v2-decisions.md Process 5 Step 3 and v2-ux-spec.md "Booking Flow — Step 2: Select Doctor."

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 3
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 2: Select Doctor" (line 506)
- `docs/v2-ux-spec.md` — Design System (colors, typography, spacing, border radius)
- `docs/CODEBASE.md` — Section 11 (Plato API — GET /facility), Section 4 (FFAppState)
- `docs/v2-decisions.md` — Admin Panel doctor visibility toggle (is_visible_in_app, default OFF)

---

## Scope

### In Scope
- Create `DoctorSelectionScreen` widget in `lib/pages/booking/doctor_selection_screen.dart`
- App bar with "Book Appointment" title and back arrow
- Step indicator: 1 Branch > 2 Doctor > 3 Date & Time > 4 Confirm (step 2 active)
- "No Preference" card at top with group icon, label, and subtitle
- Doctor cards below — each showing circle avatar (64px), name, specialty
- Filter doctors to selected branch only
- Only show doctors where is_visible_in_app = true
- Selected doctor card gets accent border highlight (#00C9A7)
- "Next" button — disabled until a selection is made (doctor or No Preference)
- Store selection in shared booking flow model
- Apply V2 design system consistently

### Out of Scope
- Date/time selection screen (P5-T04)
- Doctor availability logic (that's for the slot check)
- Adding/editing doctor visibility (that's Admin Panel, Process 7)

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/booking/doctor_selection_screen.dart` — new screen widget
- `lib/pages/booking/booking_flow_model.dart` — extend with doctor selection state

### API Endpoints
- `GET /api/v2/plato/facility` — filtered by branch/facility ID to get doctors

### Data / Schema
- Doctor fields: id, name, specialty, photo_url, is_visible_in_app, facility_id
- Store in booking model: selectedDoctorId, selectedDoctorName, isNoPreference (bool)

### UI Components
- No Preference card: group/people icon (Icons.groups), heading-md "No Preference", body-sm subtitle "We will find the earliest available slot for you"
- Doctor cards: 64px CircleAvatar (cached_network_image), name (heading-sm 16px/600), specialty (body-sm 12px/400)
- Card styling: surface bg, border radius 16px, shadow low
- Accent border highlight: 2px solid #00C9A7 on selected card
- Loading state: skeleton doctor cards (circle + text lines placeholder)
- Empty state: "No doctors available for this branch" message
- Error state: error message with retry
- Next button: Primary style, 52px height, disabled state grey

### Constraints
- "No Preference" must always appear first in the list
- Filtering is_visible_in_app must be done server-side or client-side consistently
- All API calls through Laravel proxy

---

## Acceptance Criteria

- [ ] Step indicator shows 4 steps with step 2 active/highlighted
- [ ] "No Preference" card appears at the top of the list with group icon, label, and subtitle text
- [ ] Doctor list shows only doctors from the selected branch (received from previous screen)
- [ ] Only doctors with is_visible_in_app = true appear in the list
- [ ] Each doctor card displays a circular avatar, name, and specialty
- [ ] Selecting a doctor (or No Preference) highlights it with accent border
- [ ] "Next" button is disabled until a selection is made
- [ ] Tapping "Next" navigates to date/time selection screen with selected doctor data
- [ ] Loading state shows skeleton cards during API loading
- [ ] Empty state displays when no visible doctors exist for the branch

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
- [ ] Step indicator step 2 active — PASS / FAIL
- [ ] No Preference card at top — PASS / FAIL
- [ ] Doctor list filtered by branch — PASS / FAIL
- [ ] is_visible_in_app filter works — PASS / FAIL
- [ ] Doctor card rendering — PASS / FAIL
- [ ] Selection highlight — PASS / FAIL
- [ ] Next button disabled state — PASS / FAIL
- [ ] Navigation to next screen — PASS / FAIL
- [ ] Loading state — PASS / FAIL
- [ ] Empty state — PASS / FAIL

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
