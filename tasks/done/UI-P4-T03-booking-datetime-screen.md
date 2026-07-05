# Booking Date & Time Selection Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T03 |
| Slug | booking-datetime-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the Booking Date & Time Selection screen (Step 3 of the booking flow) to use the V2 design system. Display a calendar grid for date selection and a grid of `TimeSlotChip` components below for available time slots. Only future months selectable. Skeleton while fetching slots.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 13 (AppAppBar), 15 (AppSkeleton), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.3, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow — Date & Time Selection
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/booking_datetime_screen.dart` with V2 design system
- Use `StepIndicator` component showing Step 3 of 4
- Calendar grid for date selection — selected date highlighted with accent color
- Only future months selectable (disable past month navigation)
- `TimeSlotChip` grid below calendar showing available time slots
- Skeleton loader (`AppSkeleton`) while fetching time slots
- `AppEmptyState` if no slots available for selected date
- `AppErrorState` with retry on API failure
- `AppButton` (Primary) for "Continue" — disabled until time slot selected
- Dark mode support

### Out of Scope
- Calendar widget from scratch (use existing Flutter calendar logic or `table_calendar` package)
- Slot API integration (keep existing API calls to POST /appointment/slots via Laravel proxy)
- Doctor/branch context passing (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/booking_datetime_screen.dart` — Redesign with V2 components

### API Endpoints
- `POST /appointment/slots` — Fetch available time slots via Laravel proxy (existing)

### Data / Schema
- Slot model: date, time, available (existing model preserved)

### UI Components
- `StepIndicator` (Phase 1) — Step 3 of 4 highlighted
- `TimeSlotChip` (Phase 1) — Grid of selectable time chips
- `AppSkeleton` (Phase 0) — Chip grid skeleton preset while loading
- `AppEmptyState` (Phase 0) — "No slots available" with calendar illustration
- `AppErrorState` (Phase 0) — Error icon + "Try Again"
- `AppButton` (Phase 0) — Primary variant, disabled until time slot selected
- `AppAppBar` (Phase 0) — Sub-page variant with back + "Select Date & Time"

### Constraints
- Only future months selectable in calendar
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding
- Skeleton + empty + error states mandatory

---

## Acceptance Criteria

- [ ] Screen shows `StepIndicator` with Step 3 of 4 highlighted at top
- [ ] Calendar grid displays with current/future months, selected date highlighted with accent color
- [ ] Past months are not navigable (back navigation disabled at current month)
- [ ] Time slots render as `TimeSlotChip` grid — selected chip has accent background, unselected chips are outline style
- [ ] Skeleton loader displays while fetching time slots for selected date
- [ ] Empty state displays when no slots available for a selected date
- [ ] Error state with "Try Again" button displays on API failure
- [ ] "Continue" button disabled until a time slot is selected
- [ ] Changing date re-fetches slots with skeleton loader
- [ ] Dark mode: all colors, calendar, chips, and text render correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

Created `lib/features/booking/booking_datetime_screen.dart`:
- Used `StepIndicator` with 4 steps at step 2 (Date & Time highlighted)
- Used `table_calendar` package for calendar grid with accent-colored selected day
- Past month navigation disabled (back arrow greyed when at current month)
- `TimeSlotChip` grid rendered via `Wrap` widget, accent background on selected
- Skeleton loader (8 placeholder boxes) while fetching time slots
- `AppEmptyState` when no slots available
- `AppErrorState` with retry on fetch failure
- `AppButton` (primary), disabled until time slot selected
- `AppAppBar.sub` with back button and "Select Date & Time" title
- Day selection re-fetches slots with skeleton loader
- Dark mode: all components handle light/dark via `Theme.of(context).brightness`
- No hardcoded hex colors, font sizes, or padding — all from design tokens

---

## QA Notes

- [x] StepIndicator Step 3 of 4 highlighted — PASS (currentStep: 2)
- [x] Calendar grid with selected date in accent — PASS (TableCalendar + accent)
- [x] Past months not navigable — PASS (back arrow disabled at current month)
- [x] TimeSlotChip grid with proper selection styling — PASS (component handles this)
- [x] Skeleton loader while fetching — PASS (8 placeholder boxes)
- [x] Empty state when no slots — PASS (AppEmptyState, schedule icon)
- [x] Error state with retry — PASS (AppErrorState + _fetchTimeSlots)
- [x] Continue button disabled until slot selected — PASS (_selectedSlotIndex >= 0)
- [x] Changing date re-fetches slots — PASS (_onDaySelected triggers _fetchTimeSlots)
- [x] Dark mode — PASS (Theme.of(context).brightness in all components)
- Result: PASSED

---

## Reviewer Notes

APPROVED — Design system compliance verified:
- No hardcoded colors/fonts — all via design tokens
- Dark mode handled via Theme.brightness in calendar, slots, and controls
- Skeleton + empty + error states present
- `table_calendar` package already in pubspec.yaml, no new dependency
- v2-ux-spec §4 (Booking Flow Step 3): calendar + time chips + month navigation — all match
- Past month blocking aligns with v2-decisions requirement for future-month validation
