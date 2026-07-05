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
| Status | DONE |
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
- Added `selectedBranchWhatsApp` field to `BookingFlowModel` to store per-branch WhatsApp number
- Added `phone` field to `BranchItem` and wired it through branch selection flow
- Added `telephone` JSON field extractor to `GetproviderCall` API class
- Created `lib/utils/whatsapp_helper.dart` with `buildPreFilledMessage()`, `buildDeepLink()`, and `getWhatsAppInstallUrl()` utilities
- Replaced stub `_onBookViaWhatsApp` in confirmation screen with real WhatsApp deep-link implementation
- Added error handling: shows dialog when WhatsApp is not installed with "Install WhatsApp" option
- Pre-filled message follows exact format from v2-ux-spec.md (line 557-569)
- WhatsApp number is dynamic per branch (not hardcoded)

### Files Changed
- `lib/pages/booking/booking_flow_model.dart` — added `_selectedBranchWhatsApp` field + parameter to `selectBranch()`
- `lib/pages/booking/branch_selection_screen.dart` — added `phone` to `BranchItem`, extract from API, pass to model
- `lib/utils/whatsapp_helper.dart` — new file: WhatsApp deep-link construction utilities
- `lib/backend/api_requests/api_calls.dart` — added `telephone` static getter to `GetproviderCall`
- `lib/pages/booking/confirmation_screen.dart` — replaced stub with full WhatsApp redirect implementation

### Decisions Made During Implementation
- Used `url_launcher` (already present in pubspec.yaml) for launching WhatsApp deep links
- Phone number is extracted from Plato API `$[:].telephone` field; if not present, branch phone will be empty and user sees snackbar
- WhatsApp deep link uses `LaunchMode.externalApplication` to open in WhatsApp app directly
- `canLaunchUrl()` is used to detect WhatsApp availability before attempting launch
- Error dialog includes "Install WhatsApp" button that opens the appropriate app store

### Known Limitations
- WhatsApp number depends on Plato API returning a `telephone` field; if the API does not include this field, branch phone will be empty
- `WhatsAppHelper.isWhatsAppAvailable` is a stub that always returns true (actual detection uses `canLaunchUrl`)
- On web platform, WhatsApp deep linking may not work as expected

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] Message contains all booking details — PASS (WhatsAppHelper.buildPreFilledMessage includes branch, doctor, date, time, patient name, NRIC)
- [x] Branch/doctor/date/time match selections — PASS (data sourced from BookingFlowModel singleton, same instance used in build())
- [x] Patient data matches FFAppState — PASS (FFAppState().name and FFAppState().nationalman used directly)
- [x] WhatsApp opens with pre-filled message — PASS (canLaunchUrl + launchUrl with LaunchMode.externalApplication, Uri.encodeComponent for encoding)
- [x] Error dialog when WhatsApp not installed — PASS (_showWhatsAppNotInstalledDialog with Cancel + Install WhatsApp buttons)
- [x] Dynamic phone number per branch — PASS (selectedBranchWhatsApp from BookingFlowModel, populated from branch selection API)
- [x] Message format matches spec — PASS (exact format from v2-ux-spec.md lines 557-569, including blank lines)
- [x] URL encoding handles special characters — PASS (Uri.encodeComponent used in buildDeepLink)

### Failure Details
N/A — All criteria PASSED.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — WhatsApp redirect uses https://wa.me/{branch_wa_number}?text={prefilled_message} per Process 5 Step 6, dynamic per-branch number, pre-filled message format matches
- v2-ux-spec.md alignment: YES — Pre-filled message format matches lines 557-569 exactly, confirmation screen button "Book via WhatsApp" implemented, error dialog per spec

### Rejection Reason
N/A — Approved.
