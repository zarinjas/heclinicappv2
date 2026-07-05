# P5-T05 — Booking Confirmation Screen

## Task ID
P5-T05

## Title
Booking Confirmation Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T05 |
| Slug | booking-confirmation-screen |
| Process | 5 — Booking Flow |
| Process Step | Step 5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P5-T04 |
| Blocked Reason | N/A |

---

## Description

Create the booking confirmation screen for the Booking Flow (Step 4 of 4). This screen shows a summary of the patient's selections — Branch, Doctor, Date, Time, and Patient details. It includes an info disclaimer banner and a primary action button to send the booking via WhatsApp. Per v2-decisions.md Process 5 Step 5 and v2-ux-spec.md "Booking Flow — Step 4: Confirm & WhatsApp."

---

## Context

- `docs/v2-decisions.md` — Process 5, Steps 5 and 6
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 4: Confirm & WhatsApp" (line 540)
- `docs/v2-ux-spec.md` — Design System (component library, colors, typography)
- `docs/CODEBASE.md` — Section 4 (FFAppState — patient name, NRIC, phone), Section 20 (Dynamic WhatsApp per branch)
- `docs/v2-decisions.md` — Dynamic WhatsApp Number per branch (line ~962 of CODEBASE.md)

---

## Scope

### In Scope
- Create `BookingConfirmationScreen` widget in `lib/pages/booking/confirmation_screen.dart`
- App bar with "Book Appointment" title and back arrow
- Step indicator: 1 Branch > 2 Doctor > 3 Date & Time > 4 Confirm (step 4 active)
- Summary card displaying:
  - Branch: [Branch Name]
  - Doctor: [Doctor Name / No Preference]
  - Date: [Selected Date in readable format, e.g. "15 August 2026"]
  - Time: [Selected Time, e.g. "10:00 AM"]
  - Patient: [Name], [NRIC]
- Info banner with teal background and white text:
  "Your preferred slot is not confirmed until our team responds via WhatsApp."
- "Book via WhatsApp" primary button with WhatsApp icon (Icons.whatsapp or similar)
- Apply V2 design system styling throughout

### Out of Scope
- WhatsApp deep link redirection (P5-T06 handles that)
- Creating the actual appointment (Admin side, P5-T07)
- Sending notifications (Process 8)

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/booking/confirmation_screen.dart` — new screen widget

### Data Source
- Branch data from P5-T02 selection (passed via booking flow model)
- Doctor data from P5-T03 selection
- Date/time data from P5-T04 selection
- Patient data from FFAppState (name, nationalman/NRIC)

### UI Components
- Summary card: surface bg (#FFFFFF), border radius 16px, shadow low, internal padding 16px
- Summary rows: label (body-sm 12px/400, text-secondary #6B7280) + value (body-md 14px/400, text-primary #0F1B3D)
- Info banner: accent teal bg (#00C9A7 at 15% opacity or similar), white text on darker teal, body-sm 12px/400, padding 12px, border radius 8px
- Book button: Primary style, 52px height, WhatsApp icon left-aligned, "Book via WhatsApp" text, #00C9A7 bg
- Divider lines between summary rows: 0.5px #E5E7EB

### Constraints
- Screen must be self-contained — all data received from previous screens in booking flow model
- WhatsApp number must come from the selected branch data (dynamic per-branch)
- All UI elements must follow V2 design system colors and spacing

---

## Acceptance Criteria

- [x] Step indicator shows 4 steps with step 4 active/highlighted, all prior steps checked/completed
- [x] Summary card displays all 5 fields: Branch, Doctor, Date, Time, Patient (Name + NRIC)
- [x] Patient name and NRIC are pulled from FFAppState (not hardcoded)
- [x] Info disclaimer banner is visible with correct message text and teal styling
- [x] "Book via WhatsApp" button is tappable and shows WhatsApp icon
- [x] Back button returns to previous screen with data preserved
- [x] Screen renders correctly with V2 design system (colors, fonts, spacing, card styling)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
- Created `lib/pages/booking/confirmation_screen.dart` — BookingConfirmationScreenWidget (StatelessWidget)
- Registered route `/bookingConfirmation` in `lib/flutter_flow/nav/nav.dart`
- Added export in `lib/index.dart`

Implementation details:
- AppBar: dark navy (#0F1B3D) with white back arrow and "Book Appointment" title, matching pattern from branch_selection_screen
- Step indicator: 4 steps with check icons in accent green circles for completed steps, white text, placed in navy container below app bar
- Summary card: white surface, 16px border radius, low shadow, 1px #E5E7EB border, 16px internal padding
  - "Appointment Summary" heading (18px/600)
  - 5 rows: Branch, Doctor, Date, Time, Patient — each with 72px label column (12px/400, #6B7280) + value (14px/400, #0F1B3D)
  - 0.5px #E5E7EB dividers between rows
- Info banner: #00C9A7 at 12% opacity background, 1px 30% opacity border, info icon + disclaimer text (12px/400)
- Book button: full-width, 52px height, accent teal (#00C9A7), 24px border radius, chat icon + "Book via WhatsApp" text (15px/600), white foreground
  - onTap: shows SnackBar placeholder message (actual WhatsApp deep link deferred to P5-T06)
- Patient name from `FFAppState().name`, NRIC from `FFAppState().nationalman`
- Doctor display: shows "No Preference" when isNoPreference is true
- Date formatting: "15 Aug 2026" style
- Time formatting: converts "14:00" to "2:00 PM" display format
- Back navigation: calls `context.pop()` to preserve previous screen state

### Files Changed
- `lib/pages/booking/confirmation_screen.dart` — created (new file)
- `lib/flutter_flow/nav/nav.dart` — added import and FFRoute registration
- `lib/index.dart` — added export for BookingConfirmationScreenWidget

### Decisions Made During Implementation
1. Used `StatelessWidget` (not StatefulWidget) since screen is purely display — all data from singleton BookingFlowModel and FFAppState
2. Used `Icons.chat` (not Icons.whatsapp) since the Flutter Material Icons set doesn't include a WhatsApp icon; chat bubble is the closest standard icon
3. Used `FFAppState().nationalman` as NRIC per task specification; V2 may later fetch NRIC from Plato profile API
4. Book button onTap shows placeholder SnackBar — actual WhatsApp deep link with pre-filled message and url_launcher is P5-T06 scope
5. Step indicator shows check icons for ALL steps (not just completed ones) since all 4 steps are completed at this point
6. Format order in summary card follows the UX spec layout

### Known Limitations
- WhatsApp button does not yet open WhatsApp (P5-T06)
- NRIC uses `nationalman` field from FFAppState, not the dedicated Plato NRIC field (Plato profile API not yet integrated in V2 booking flow)
- Screen does not pre-populate patient phone number (not in task scope)
- Route does not have auth guard (booking flow routes follow existing pattern of no auth required before confirmation)

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] Step indicator step 4 — PASS: All 4 steps visible, step 4 text highlighted (white w600), others dimmed (white60 w400). All circles filled accent with check icons for completed status.
- [x] Summary card 5 fields — PASS: Branch, Doctor, Date, Time, Patient (Name + NRIC) all present in card with dividers between rows.
- [x] Patient data from FFAppState — PASS: `FFAppState().name` (line 119) and `FFAppState().nationalman` (line 120-121), no hardcoded values.
- [x] Disclaimer banner — PASS: Teal (12% opacity bg, 30% opacity border), info_outline icon, correct message text "Your preferred slot is not confirmed until our team responds via WhatsApp." (line 325).
- [x] WhatsApp button — PASS: ElevatedButton.icon with onPressed handler (line 358), chat icon (line 359), "Book via WhatsApp" text (line 361), accent teal (line 368), 52px height (line 355), 24px border radius (line 371). Tappable with SnackBar feedback.
- [x] Back navigation — PASS: `context.pop()` on back arrow (line 130), data preserved via BookingFlowModel singleton.
- [x] Design system compliance — PASS: V2 bg-light #F8F9FC, primary #0F1B3D, accent #00C9A7, text-secondary #6B7280, surface white, 16px card radius, 24px button radius, low shadow, consistent with branch/doctor/date-time screens.

### Failure Details
None — all criteria PASSED.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
