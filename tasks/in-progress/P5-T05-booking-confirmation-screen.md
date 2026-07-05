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
| Status | IN-PROGRESS |
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

- [ ] Step indicator shows 4 steps with step 4 active/highlighted, all prior steps checked/completed
- [ ] Summary card displays all 5 fields: Branch, Doctor, Date, Time, Patient (Name + NRIC)
- [ ] Patient name and NRIC are pulled from FFAppState (not hardcoded)
- [ ] Info disclaimer banner is visible with correct message text and teal styling
- [ ] "Book via WhatsApp" button is tappable and shows WhatsApp icon
- [ ] Back button returns to previous screen with data preserved
- [ ] Screen renders correctly with V2 design system (colors, fonts, spacing, card styling)

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
- [ ] Step indicator step 4 — PASS / FAIL
- [ ] Summary card 5 fields — PASS / FAIL
- [ ] Patient data from FFAppState — PASS / FAIL
- [ ] Disclaimer banner — PASS / FAIL
- [ ] WhatsApp button — PASS / FAIL
- [ ] Back navigation — PASS / FAIL
- [ ] Design system compliance — PASS / FAIL

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
