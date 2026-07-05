# P5-T02 — Branch Selection Screen

## Task ID
P5-T02

## Title
Branch Selection Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T02 |
| Slug | branch-selection-screen |
| Process | 5 — Booking Flow |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P5-T01 |
| Blocked Reason | N/A |

---

## Description

Create the branch selection screen for the Booking Flow (Step 1 of 4 in the booking wizard). The user selects a clinic branch from a vertical list. Data comes from the Laravel proxy via GET /facility (Plato), mapped through the Admin Panel's branches configuration. Per v2-decisions.md Process 5 Step 2 and v2-ux-spec.md "Booking Flow — Step 1: Select Branch."

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 2
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 1: Select Branch" (line 492)
- `docs/v2-ux-spec.md` — Design System colors, typography, spacing, border radius, shadows
- `docs/CODEBASE.md` — Section 4 (FFAppState), Section 5 (EnvConfig), Section 6 (Routing)
- `docs/api-guidelines.md` — GET /facility endpoint

---

## Scope

### In Scope
- Create new `lib/pages/booking/` directory for booking flow screens
- Create `BranchSelectionScreen` widget in `lib/pages/booking/branch_selection_screen.dart`
- App bar with "Book Appointment" title and back arrow
- Step indicator showing: 1 Branch > 2 Doctor > 3 Date & Time > 4 Confirm (step 1 active)
- Vertical scrollable list of branch cards from GET /facility via Laravel proxy
- Each card shows: branch photo (network image), name, address, operating hours
- Selected branch gets accent border highlight (#00C9A7)
- "Next" button — disabled until a branch is selected
- Add route in GoRouter (`lib/flutter_flow/nav/nav.dart`)
- Store selected branch in FFAppState or pass via route parameters
- Apply V2 design system: colors, Plus Jakarta Sans font, spacing scale, card border radius (lg = 16px), shadow (low)

### Out of Scope
- Doctor selection screen (P5-T03)
- Date/time selection screen (P5-T04)
- Confirmation screen (P5-T05)
- WhatsApp redirect (P5-T06)

---

## Technical Spec

### Files to Create or Modify
- `lib/pages/booking/branch_selection_screen.dart` — new screen widget
- `lib/pages/booking/booking_flow_model.dart` — shared booking flow state model
- `lib/flutter_flow/nav/nav.dart` — add route for branch selection
- `lib/backend/api_requests/api_calls.dart` — add or update GetFacilityCall (if not using existing GetproviderCall)

### API Endpoints
- `GET /api/v2/plato/facility` — returns list of facilities (Plato proxy)

### Data / Schema
- Branch fields: id, name, address, image, operating_hours (from facility response)
- Store selected branch in booking flow model: selectedBranchId, selectedBranchName

### UI Components
- V2 design system: primary #0F1B3D, accent #00C9A7, bg-light #F8F9FC, surface #FFFFFF
- Plus Jakarta Sans font (heading-md 18px/600 for card titles, body-md 14px/400 for address)
- Cards: border radius 16px, shadow low (0 1px 4px rgba(0,0,0,0.06))
- Accent border: 2px solid #00C9A7 on selected card
- Loading state: skeleton cards (shimmer placeholder matching card shape)
- Empty state: illustration + "No branches available" message
- Error state: error message with retry button
- Next button: Primary style, 52px height, border radius 24px, disabled state grey

### Constraints
- All API calls must use Laravel proxy URL from EnvConfig.platomBaseUrl
- Never hardcode Plato API token
- Must handle API errors gracefully (use global error interceptor from P3-T01)

---

## Acceptance Criteria

- [ ] Screen displays a step indicator with 4 steps, step 1 highlighted as active
- [ ] Branch list loads dynamically from GET /facility endpoint (not hardcoded or Firestore)
- [ ] Each branch card shows photo, name, address, and operating hours
- [ ] Tapping a branch highlights it with accent border (#00C9A7)
- [ ] "Next" button is disabled until a branch is selected
- [ ] Tapping "Next" with a selected branch navigates to the doctor selection screen (passing branch data)
- [ ] Loading state shows skeleton placeholders while API call is in progress
- [ ] Empty state shows when API returns no branches
- [ ] Error state shows retry option when API call fails

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created BranchSelectionScreen with step indicator, API-driven branch list from GET /facility via existing GetproviderCall, card design with selection highlight, and Next navigation button. Includes loading skeleton, empty state, and error state with retry. Uses V2 design system colors (primary #0F1B3D, accent #00C9A7, bg-light #F8F9FC). BookingFlowModel singleton stores selected branch data for subsequent booking flow screens.

### Files Changed
- `lib/pages/booking/branch_selection_screen.dart` — new BranchSelectionScreenWidget with full UI
- `lib/pages/booking/booking_flow_model.dart` — new shared booking flow state model
- `lib/flutter_flow/nav/nav.dart` — added route `/branchSelectionScreen`
- `lib/index.dart` — added export for BranchSelectionScreenWidget

### Decisions Made During Implementation
- Reused existing GetproviderCall for GET /facility instead of creating a duplicate API call
- BookingFlowModel follows singleton pattern matching FFAppState pattern in codebase
- DoctorSelectionScreen route at `/doctorSelectionScreen` referenced for Next navigation (to be implemented in P5-T03)
- Branch image, address, and operating hours fields mapped to available facility response fields (id, name, nric). Image and hours fields will render when API returns data for those fields
- No external Provider dependency needed — BookingFlowModel is accessed as singleton throughout the flow

### Known Limitations
- Doctor selection screen route (`/doctorSelectionScreen`) not yet implemented (P5-T03)
- Branch photos and operating hours depend on facility API response fields that may not be populated in Plato yet
- Plus Jakarta Sans font styling inline (not via the theme system which still uses Poppins). Will be fully migrated when Design System is fully applied in future processes

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] Step indicator renders correctly — PASS / FAIL
- [ ] Branch list loads from API — PASS / FAIL
- [ ] Branch card content renders — PASS / FAIL
- [ ] Selection highlight works — PASS / FAIL
- [ ] Next button disabled until selection — PASS / FAIL
- [ ] Navigation to next screen — PASS / FAIL
- [ ] Loading state renders — PASS / FAIL
- [ ] Empty state renders — PASS / FAIL
- [ ] Error state renders — PASS / FAIL

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
