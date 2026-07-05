# Upcoming Appointments Inner Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P5-T02 |
| Slug | upcoming-tab |
| Process | Epic: UI Migration — Phase 5 |
| Process Step | Step 5.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Implement the Upcoming appointments inner tab content within the Appointments Tab shell. Displays a paginated vertical list of `AppointmentCard` components (confirmed/pending appointments from API). Each card shows an "X days to go" badge in the top-right corner. Build skeleton, empty, and error states.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 7 (AppCard), 11 (AppChip — status chip), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 5 (lines 145–161), Appointments Tab Notes
- `docs/v2-ux-spec.md` — Appointments Tab screen specifications
- `docs/design-system-v2.png` — Visual target reference
- Check existing `AppointmentCard` component in `lib/core/widgets/appointment_card.dart` (from Phase 1)

---

## Scope

### In Scope
- Build Upcoming tab content widget within `lib/features/appointments/appointments_screen.dart`
- Vertical `ListView` of `AppointmentCard` components for upcoming (confirmed/pending) appointments from API
- "X days to go" badge on top-right corner of each card (counts days until appointment date)
- `AppChip` status chip on each card (Confirmed/Pending per appointment status)
- Skeleton loader (`AppSkeleton`) while fetching appointment list
- `AppEmptyState` with calendar illustration and "Book Now" CTA when 0 upcoming appointments
- `AppErrorState` with retry on API failure
- Paginated list with scroll-to-load-more support
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Past tab content (separate task UI-P5-T03)
- Tab switcher shell and navigation (implemented in UI-P5-T01)
- Appointment Detail navigation (navigate to screen from UI-P5-T04)
- Cancel/reschedule appointment logic (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/appointments/appointments_screen.dart` — Add Upcoming tab content widget (inner tab within shell)
- `lib/core/widgets/appointment_card.dart` — May need "X days to go" badge variant

### API Endpoints
- N/A — Reuse existing appointment listing endpoints from booking flow
- Filter: only confirmed and pending appointments with future dates

### Data / Schema
- Existing appointment data models (preserve existing business logic)
- Appointment fields: id, doctor_name, branch_name, appointment_date, appointment_time, status

### UI Components
- `AppointmentCard` (from Phase 1) — with status chip variant, "X days to go" badge
- `AppChip` — status chip (Confirmed=green, Pending=amber)
- `AppSkeleton` — shimmer card list preset for loading
- `AppEmptyState` — calendar illustration + "Book Now" CTA
- `AppErrorState` — error icon + message + "Try Again" button
- `AppTextStyles.bodyLarge` / `bodyMedium` — for date/text content

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory

---

## Acceptance Criteria

- [ ] Upcoming tab renders a vertical list of `AppointmentCard` components for confirmed/pending future appointments
- [ ] "X days to go" badge displays correctly on top-right corner of each card (counts days from today to appointment date)
- [ ] `AppChip` status chips render with correct colors per status (Confirmed=green, Pending=amber)
- [ ] Skeleton loader (shimmer card preset) displays while fetching data
- [ ] Empty state renders `AppEmptyState` with calendar illustration and "Book Now" CTA
- [ ] Error state renders `AppErrorState` with retry button on API failure
- [ ] Pagination works — scrolling to bottom triggers load more if more pages exist
- [ ] Dark mode renders correctly across all states
- [ ] `flutter analyze` passes with zero errors
- [ ] No hardcoded colors, font sizes, spacing, or border radius

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.
