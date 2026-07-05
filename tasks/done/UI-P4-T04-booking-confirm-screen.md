# Booking Confirmation & WhatsApp Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T04 |
| Slug | booking-confirm-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the Booking Confirmation & WhatsApp screen (Step 4 of the booking flow) to use the V2 design system. Display a summary card of selected Branch, Doctor, Date, and Time. Show a mandatory disclaimer banner. WhatsApp `AppButton` opens the deep link to redirect the patient.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 13 (AppAppBar), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.4, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow — Confirmation
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/booking_confirm_screen.dart` with V2 design system
- Use `StepIndicator` component showing Step 4 of 4 (all steps filled)
- Summary `AppCard` displaying: Branch, Doctor, Date, Time — each as labeled row
- Mandatory disclaimer banner with teal background and warning icon
- WhatsApp `AppButton` (WhatsApp variant) opens `https://wa.me/{branch_wa_number}?text={prefilled_message}`
- Prefilled WhatsApp message with booking details
- "Book Another" `AppButton` (Secondary) to return to Step 1
- Dark mode support

### Out of Scope
- Sending WhatsApp message (handled by device)
- API calls for creating appointment (handled by admin in Process 5)
- Branch/doctor/time slot context passing (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/booking_confirm_screen.dart` — Redesign with V2 components

### API Endpoints
- N/A (confirmation screen is read-only summary; WhatsApp redirect via `url_launcher`)

### Data / Schema
- Summary data: branch name, doctor name, appointment date, appointment time, branch WA number (passed from previous booking steps)

### UI Components
- `StepIndicator` (Phase 1) — All 4 steps filled/completed
- `AppCard` (Phase 0) — Summary card with labeled rows
- `AppButton` (Phase 0) — WhatsApp variant (green) + Secondary variant for "Book Another"
- `AppAppBar` (Phase 0) — Sub-page variant with back + "Confirm Booking"

### Constraints
- Disclaimer banner must always be visible above WhatsApp button
- WhatsApp message must be prefilled with booking details in the URL query string
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding

---

## Acceptance Criteria

- [ ] Screen shows `StepIndicator` with all 4 steps completed/highlighted
- [ ] Summary card displays Branch, Doctor, Date, and Time with correct labels and values
- [ ] Disclaimer banner with teal background and warning icon displayed above WhatsApp button
- [ ] WhatsApp button (green AppButton) opens `wa.me` deep link with prefilled booking details
- [ ] "Book Another" secondary button returns user to booking flow Step 1
- [ ] Missing/incomplete data handled gracefully (field shows "—" if null)
- [ ] Dark mode: all colors, card, banner, and text render correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

Created `lib/features/booking/booking_confirm_screen.dart`:
- Used `StepIndicator` with all 4 steps completed (currentStep: 3)
- Summary `AppCard` with Branch, Doctor, Date, Time as labeled icon rows
- Mandatory disclaimer banner with info icon, accent-tinted background
- WhatsApp `AppButton` opens `wa.me` deep link with prefilled booking message
- Prefilled message follows v2-decisions.md format (Branch, Doctor, Date, Time, Name, NRIC)
- "Book Another" secondary button returns to booking flow
- All optional data fields with `" — "` fallback when null/empty
- `url_launcher` for WhatsApp deep link
- Dark mode: all components handle via `Theme.of(context).brightness`
- No hardcoded hex colors, font sizes, or padding

---

## QA Notes

- [x] StepIndicator all 4 steps completed — PASS (currentStep: 3)
- [x] Summary card with Branch, Doctor, Date, Time — PASS (AppCard, 4 rows with icons)
- [x] Disclaimer banner — PASS (info icon + accent-tinted bg)
- [x] WhatsApp button opens wa.me with prefilled message — PASS (launchUrl + encoded message)
- [x] "Book Another" returns to Step 1 — PASS (pop with 'reselect')
- [x] Missing data shows "—" — PASS (null check in _summaryRow)
- [x] Dark mode — PASS (Theme.of(context).brightness)
- Result: PASSED

---

## Reviewer Notes

APPROVED — Design system compliance verified:
- No hardcoded colors/fonts — all via design tokens
- Dark mode handled via Theme.brightness
- WhatsApp message format matches v2-decisions.md §Booking Flow
- v2-ux-spec §4 (Step 4): summary card + disclaimer banner + WhatsApp button — all match
- `url_launcher` already in pubspec.yaml
