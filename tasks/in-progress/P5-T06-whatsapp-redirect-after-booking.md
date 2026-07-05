# P5-T06 — WhatsApp Redirect After Booking

## Task ID
P5-T06

## Title
WhatsApp Redirect After Booking

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T06 |
| Slug | whatsapp-redirect-after-booking |
| Process | 5 — Booking Flow |
| Process Step | Step 6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P5-T05 |
| Blocked Reason | N/A |

---

## Description

Implement the WhatsApp deep link redirect from the confirmation screen. When the user taps "Book via WhatsApp," the app constructs a pre-filled message with booking details and opens WhatsApp via the `https://wa.me/{branch_wa_number}?text={prefilled_message}` deep link. The WhatsApp number is fetched dynamically from the admin panel's branch configuration. Per v2-decisions.md Process 5 Step 6 and v2-ux-spec.md confirmation screen flow.

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 6
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 4: Confirm & WhatsApp" (line 540), pre-filled message format (line 557-569)
- `docs/CODEBASE.md` — Section 20 (Dynamic WhatsApp Number per branch)
- `docs/v2-decisions.md` — Dynamic WhatsApp Number (editable per branch in Admin Panel)

---

## Scope

### In Scope
- Implement WhatsApp deep link handling on the confirmation screen button tap
- Construct the pre-filled message using the exact format from v2-ux-spec.md:
  ```
  Hi He Clinic [Branch Name]!

  I would like to book an appointment:
  - Name: [Patient Name]
  - NRIC: [Patient NRIC]
  - Branch: [Branch Name]
  - Doctor: [Doctor Name / No Preference]
  - Date: [Selected Date]
  - Time: [Selected Time]

  Please confirm my appointment. Thank you!
  ```
- URL-encode the message for the WhatsApp deep link
- Open the deep link using `url_launcher` (add to pubspec.yaml if not already present)
- Handle the case where WhatsApp is not installed (show error dialog with fallback)
- Branch WhatsApp number must be dynamic (from selected branch, not hardcoded)

### Out of Scope
- Admin Panel WhatsApp management (Process 7)
- WhatsApp Center bulk messaging (Process 10)
- Plato API POST /whatsapp/send integration

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/booking/confirmation_screen.dart` — add WhatsApp redirect logic to the "Book via WhatsApp" button
- `lib/utils/whatsapp_helper.dart` — new utility for constructing WhatsApp deep links
- `pubspec.yaml` — add `url_launcher` dependency if not already present

### Data / Schema
- Branch WhatsApp number: from branch data in booking flow model
- Patient name: FFAppState().name
- Patient NRIC: FFAppState().nationalman
- Branch name, doctor name, date, time: from booking flow model

### WhatsApp Deep Link Format
```
https://wa.me/{branch_whatsapp_number}?text={url_encoded_message}
```
Note: WhatsApp deep link uses international format without +, spaces, or dashes.

### UI Components
- Loading indicator while launching WhatsApp
- Error dialog if WhatsApp is not installed: "WhatsApp is not installed. Please install WhatsApp to complete your booking."
  with options: "Install WhatsApp" (opens play/app store) and "Cancel"
- Success: app transitions to previous screen or homepage after redirect

### Constraints
- WhatsApp number must NOT be hardcoded — fetch from branch data
- Message must be URL-encoded to handle special characters (newlines, spaces, etc.)
- Test on both iOS and Android for WhatsApp scheme detection

---

## Acceptance Criteria

- [ ] Tapping "Book via WhatsApp" constructs the pre-filled message with all selected booking details
- [ ] Branch name, doctor, date, and time in the message match the user's selections
- [ ] Patient name and NRIC in the message match FFAppState data
- [ ] WhatsApp app opens with the pre-filled message ready to send (when WhatsApp is installed)
- [ ] If WhatsApp is not installed, user sees an error dialog with instructions to install WhatsApp
- [ ] WhatsApp phone number is dynamic — changes based on selected branch
- [ ] Pre-filled message follows the exact format from v2-ux-spec.md including line breaks
- [ ] Special characters in patient name or branch name are properly URL-encoded

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
- [ ] Message contains all booking details — PASS / FAIL
- [ ] Branch/doctor/date/time match selections — PASS / FAIL
- [ ] Patient data matches FFAppState — PASS / FAIL
- [ ] WhatsApp opens with pre-filled message — PASS / FAIL
- [ ] Error dialog when WhatsApp not installed — PASS / FAIL
- [ ] Dynamic phone number per branch — PASS / FAIL
- [ ] Message format matches spec — PASS / FAIL
- [ ] URL encoding handles special characters — PASS / FAIL

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
