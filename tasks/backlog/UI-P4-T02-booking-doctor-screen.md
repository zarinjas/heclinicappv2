# Booking Doctor Selection Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T02 |
| Slug | booking-doctor-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the Booking Doctor Selection screen (Step 2 of the booking flow) to use the V2 design system. Show "No Preference" card at top always, then list active doctors (`is_visible_in_app = true`) for the selected branch using `DoctorCard` component. Doctor photos from Admin Panel CMS.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 13 (AppAppBar), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.2, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow — Doctor Selection
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/booking_doctor_screen.dart` with V2 design system
- Use `StepIndicator` component showing Step 2 of 4
- "No Preference" card (`AppCard`) always first item, selectable
- Remaining doctors rendered as `DoctorCard` list, filtered to `is_visible_in_app = true`
- Skeleton loader (`AppSkeleton`) while fetching doctor list
- `AppEmptyState` if no active doctors for the branch
- `AppErrorState` with retry on API failure
- `AppButton` (Primary) for "Continue" — disabled until selection made
- Dark mode support

### Out of Scope
- Doctor detail bottom sheet (handled in Phase 10)
- Branch context passing (keep existing business logic)
- Doctor API integration (keep existing API calls)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/booking_doctor_screen.dart` — Redesign with V2 components

### API Endpoints
- `GET /facility` — Facility/doctor data via Laravel proxy (existing)

### Data / Schema
- Doctor model: id, name, specialty, photo_url, is_visible_in_app, facility_id (existing model preserved)

### UI Components
- `StepIndicator` (Phase 1) — Step 2 of 4 highlighted
- `DoctorCard` (Phase 1) — List variant, with photo, name, specialty
- `AppCard` (Phase 0) — "No Preference" card with icon
- `AppSkeleton` (Phase 0) — Doctor list skeleton preset while loading
- `AppEmptyState` (Phase 0) — "No doctors available" with stethoscope illustration
- `AppErrorState` (Phase 0) — Error icon + "Try Again"
- `AppButton` (Phase 0) — Primary variant, disabled until selection
- `AppAppBar` (Phase 0) — Sub-page variant with back + "Select Doctor"

### Constraints
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding
- Skeleton + empty + error states mandatory

---

## Acceptance Criteria

- [ ] Screen shows `StepIndicator` with Step 2 of 4 highlighted at top
- [ ] "No Preference" card always shown as first item, visually distinct from doctor cards
- [ ] Active doctors (`is_visible_in_app = true`) rendered as `DoctorCard` list below "No Preference"
- [ ] Doctor photo displayed from CMS URL, fallback placeholder if no photo
- [ ] Skeleton loader displays while API call is in flight
- [ ] Empty state displays when no active doctors found
- [ ] Error state with "Try Again" button displays on API failure
- [ ] "Continue" button disabled until a doctor (or "No Preference") is selected
- [ ] Dark mode: all colors, cards, and text render correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation. Leave blank until implementation is complete.

---

## QA Notes

> Filled in by QA after verification. Leave blank until QA picks up the task.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes. Leave blank until Reviewer picks up the task.
