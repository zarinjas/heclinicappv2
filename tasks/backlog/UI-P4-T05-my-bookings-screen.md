# My Bookings / Appointments List Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T05 |
| Slug | my-bookings-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the My Bookings / Appointments List screen to use the V2 design system. Display a paginated list of patient's appointments using `AppointmentCard` with status chips. Include skeleton loader, empty state with "Book Now" CTA, and error state with retry.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.5, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow — My Bookings
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/my_bookings_screen.dart` with V2 design system
- Paginated list of `AppointmentCard` components — 10 per page
- Each card shows: doctor name, branch, date, time, status chip
- Status chips: Confirmed (green), Pending (amber), Cancelled (red), Completed (default)
- Tap card navigates to `AppointmentDetailScreen` (UI-P4-T06)
- Skeleton loader (`AppSkeleton`) on initial load and pagination fetch
- `AppEmptyState` with calendar illustration + "Book Now" CTA button when no appointments
- `AppErrorState` with retry on API failure
- Dark mode support

### Out of Scope
- Appointment data model (keep existing model from Plato API)
- Appointment cancellation logic (keep existing API calls)
- Filter by status (handled in Phase 5 Appointments tab)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/my_bookings_screen.dart` — Redesign with V2 components

### API Endpoints
- `GET /appointment` — Patient appointments via Laravel proxy (existing)

### Data / Schema
- Appointment model: id, doctor_name, branch_name, appointment_date, appointment_time, status (existing model preserved)

### UI Components
- `AppointmentCard` (Phase 1) — List variant with status chip overlay
- `AppChip` (Phase 0) — Status variants: Confirmed (green), Pending (amber), Cancelled (red), Completed (default)
- `AppSkeleton` (Phase 0) — List skeleton preset while loading
- `AppEmptyState` (Phase 0) — "No appointments yet" + "Book Now" CTA
- `AppErrorState` (Phase 0) — Error icon + "Try Again"
- `AppAppBar` (Phase 0) — Sub-page variant with back + "My Bookings"

### Constraints
- Paginated: 10 appointments per page
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding
- Skeleton + empty + error states mandatory

---

## Acceptance Criteria

- [ ] Page displays paginated list of `AppointmentCard` components (10 per page)
- [ ] Each card shows doctor name, branch, date, time, and status chip with correct color
- [ ] Status chip colors: Confirmed=green, Pending=amber, Cancelled=red, Completed=default
- [ ] Tapping a card navigates to Appointment Detail screen
- [ ] Skeleton loader displays on initial load and pagination fetch
- [ ] Empty state with calendar illustration and "Book Now" CTA button displays when no appointments
- [ ] Error state with "Try Again" button displays on API failure
- [ ] Scroll to bottom triggers next page fetch with loading indicator
- [ ] Dark mode: all colors, cards, chips, and text render correctly
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
