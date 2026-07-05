# Appointment Detail Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T06 |
| Slug | appointment-detail-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-06 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the Appointment Detail screen to use the V2 design system. Display full appointment information in a structured layout with status chip, detail rows, and a "Cancel Appointment" action with confirmation dialog. Replace hardcoded appointment ID logic with dynamic parameter.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 11 (AppChip), 13 (AppAppBar), 20 (AppDialog), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.6, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow — Appointment Detail
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/appointment_detail_screen.dart` with V2 design system
- Header section: doctor photo, name, specialty, status chip
- Detail card: Branch, Date, Time, Appointment Type, Notes — labeled rows
- "Cancel Appointment" `AppButton` (Destructive variant) with `AppDialog` confirmation
- Loading state while fetching appointment details
- `AppErrorState` if appointment not found or fetch fails
- Support dark mode

### Out of Scope
- Appointment cancellation API logic (keep existing business logic)
- Editing appointment details (not in scope — admin function)
- Rescheduling flow (deferred)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/appointment_detail_screen.dart` — Redesign with V2 components

### API Endpoints
- `GET /appointment/{id}` — Appointment detail via Laravel proxy (existing)
- `POST /appointment/{id}/cancel` — Cancel appointment (existing)

### Data / Schema
- Appointment model: id, doctor_name, doctor_photo, specialty, branch_name, appointment_date, appointment_time, appointment_type, notes, status (existing model preserved)

### UI Components
- `AppCard` (Phase 0) — Detail card with labeled rows
- `AppChip` (Phase 0) — Status chip overlay on header
- `AppButton` (Phase 0) — Destructive variant for "Cancel Appointment", hidden if already cancelled
- `AppDialog` (Phase 0) — Confirmation variant for cancel action
- `AppSkeleton` (Phase 0) — Detail skeleton preset while loading
- `AppErrorState` (Phase 0) — Error icon + "Try Again"
- `AppAppBar` (Phase 0) — Sub-page variant with back + "Appointment Details"

### Constraints
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding
- Skeleton + error states mandatory
- Cancel button hidden for already-cancelled or completed appointments

---

## Acceptance Criteria

- [ ] Header shows doctor photo, name, specialty, and status chip with correct color
- [ ] Detail card displays Branch, Date, Time, Appointment Type, and Notes as labeled rows
- [ ] "Cancel Appointment" destructive button visible for Pending/Confirmed appointments
- [ ] "Cancel Appointment" button hidden for Cancelled and Completed appointments
- [ ] Tapping cancel shows `AppDialog` confirmation with "Are you sure?" and Cancel/Confirm buttons
- [ ] Skeleton loader displays while fetching appointment details
- [ ] Error state with "Try Again" button displays on fetch failure or appointment not found
- [ ] Status chip updates after successful cancellation
- [ ] Dark mode: all colors, cards, chips, dialog, and text render correctly
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
