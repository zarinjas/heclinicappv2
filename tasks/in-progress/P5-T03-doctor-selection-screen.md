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
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P5-T02, Process 2 (Laravel Admin Panel) |
| Blocked Reason | |

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
- Created `DoctorSelectionScreenWidget` in `lib/pages/booking/doctor_selection_screen.dart`
- Added step indicator with 4 steps (step 2 active: Doctor)
- Added "No Preference" card at top with groups icon, label, and subtitle
- Added dynamic doctor list from GET /facility API via Laravel proxy
- Doctor cards show circle avatar (64px), name, specialty
- Selected doctor/no-preference gets accent border highlight (#00C9A7)
- "Next" button disabled until selection made
- Extended BookingFlowModel with `selectDoctor()`, `selectedDoctorId`, `selectedDoctorName`, `isNoPreference`
- Registered route `/doctorSelectionScreen` in GoRouter
- Exported widget from `lib/index.dart`
- Implemented loading (skeleton), error (retry), and empty states per v2-ux-spec

### Files Changed
- lib/pages/booking/doctor_selection_screen.dart — new screen widget (387 lines)
- lib/pages/booking/booking_flow_model.dart — added doctor selection state
- lib/flutter_flow/nav/nav.dart — added doctor selection route
- lib/index.dart — exported new screen widget

### Decisions Made During Implementation
- Used GET /facility endpoint (GetproviderCall) for doctor data since Admin Panel with MySQL doctors table is not yet built (Process 2)
- `is_visible_in_app` filter not implemented client-side: data source is Admin Panel MySQL which doesn't exist yet. All facility results shown as doctors for now.
- Branch filtering deferred: Plato facility API does not provide parent facility ID field.
- "No Preference" selection stored with empty doctorId and isNoPreference=true flag.

### Known Limitations
- Cannot filter doctors by `is_visible_in_app` until Admin Panel (Process 2) is built
- Cannot filter doctors by selected branch until Plato API returns facility hierarchy data
- Doctor avatars use initial letters (no photo URLs available from current API response)

---

## QA Notes

> Filled in by QA after verification.

### Result: FAILED

### Criteria Results
- [x] Step indicator step 2 active — PASS: 4 steps rendered with step 2 highlighted (accent circle + white text)
- [x] No Preference card at top — PASS: Groups icon, "No Preference" label, subtitle text; always first in list
- [ ] Doctor list filtered by branch — FAIL: Branch filtering not implemented. Plato GET /facility API does not return parent facility ID on doctor records. Requires Admin Panel (Process 2) branch-doctor mapping or Plato API augmentation.
- [ ] is_visible_in_app filter works — FAIL: Not implemented. is_visible_in_app is a MySQL field managed by Admin Panel (Process 2), which has not been built yet. All facility results shown as doctors.
- [x] Doctor card rendering — PASS: CircleAvatar (64px), initial-letter avatar, name (16px/600), specialty (12px/400)
- [x] Selection highlight — PASS: 2px solid #00C9A7 border + check_circle icon on selected item
- [x] Next button disabled state — PASS: Disabled (grey #E5E7EB) when no selection; enabled (accent) after selection
- [x] Navigation to next screen — PASS: context.push('/dateTimeSlotSelection') triggered on Next; doctor data stored in BookingFlowModel
- [x] Loading state — PASS: 5 skeleton cards with circle + text bar placeholders during API load
- [x] Empty state — PASS: person_off icon, "No doctors available for this branch" message displayed when doctor list is empty

### Failure Details
Criteria 3 (branch filtering) and 4 (is_visible_in_app) FAIL. Both depend on Process 2 — Admin Panel Scaffold with MySQL doctors table and branch-doctor mapping, which has not been executed yet (currently at position 6 in the fixed process order; Process 5 is being built before Process 2). All other 8 criteria PASS. Implementation correctly documents these limitations.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
