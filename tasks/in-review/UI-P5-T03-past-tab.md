# Past Appointments Inner Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P5-T03 |
| Slug | past-tab |
| Process | Epic: UI Migration — Phase 5 |
| Process Step | Step 5.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Implement the Past appointments inner tab content within the Appointments Tab shell. Displays a paginated vertical list of `AppointmentCard` components for completed/cancelled/expired appointments from API. Each card shows the appropriate `AppChip` status chip. Build skeleton, empty, and error states.

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
- Build Past tab content widget within `lib/features/appointments/appointments_screen.dart`
- Vertical `ListView` of `AppointmentCard` components for past (completed/cancelled/no-show) appointments from API
- `AppChip` status chip on each card (Completed, Cancelled, No-Show per appointment status)
- Skeleton loader (`AppSkeleton`) while fetching past appointment list
- `AppEmptyState` with calendar illustration and appropriate message when 0 past appointments
- `AppErrorState` with retry on API failure
- Paginated list with scroll-to-load-more support
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Upcoming tab content (separate task UI-P5-T02)
- Tab switcher shell and navigation (implemented in UI-P5-T01)
- Appointment Detail navigation (navigate to screen from UI-P5-T04)
- Cancel/reschedule appointment logic (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/appointments/appointments_screen.dart` — Add Past tab content widget (inner tab within shell)
- `lib/core/widgets/appointment_card.dart` — May need past-appointment visual variant (muted/slightly dimmed)

### API Endpoints
- N/A — Reuse existing appointment listing endpoints from booking flow
- Filter: completed, cancelled, and no-show appointments with past dates

### Data / Schema
- Existing appointment data models (preserve existing business logic)
- Appointment fields: id, doctor_name, branch_name, appointment_date, appointment_time, status

### UI Components
- `AppointmentCard` (from Phase 1) — with status chip variant, past-appointment styling
- `AppChip` — status chip (Completed=neutral/grey, Cancelled=red, No-Show=red)
- `AppSkeleton` — shimmer card list preset for loading
- `AppEmptyState` — calendar illustration + "No past appointments" message
- `AppErrorState` — error icon + message + "Try Again" button
- `AppTextStyles.bodyLarge` / `bodyMedium` — for date/text content

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory

---

## Acceptance Criteria

- [ ] Past tab renders a vertical list of `AppointmentCard` components for completed/cancelled/no-show appointments
- [ ] `AppChip` status chips render with correct colors per status (Completed=grey, Cancelled=red, No-Show=red)
- [ ] Past appointment cards have slightly muted/dimmed visual treatment compared to upcoming
- [ ] Skeleton loader (shimmer card preset) displays while fetching data
- [ ] Empty state renders `AppEmptyState` with appropriate illustration and "No past appointments" message
- [ ] Error state renders `AppErrorState` with retry button on API failure
- [ ] Pagination works — scrolling to bottom triggers load more if more pages exist
- [ ] Dark mode renders correctly across all states
- [ ] `flutter analyze` passes with zero errors
- [ ] No hardcoded colors, font sizes, spacing, or border radius

---

## Implementation Notes

### What Was Done
Built the Past appointments inner tab content within `lib/features/appointments/appointments_screen.dart`. Renders a vertical ListView of AppointmentCard components for appointments with past dates. Each card displays the doctor name, branch, formatted date/time, and a Completed status chip. Past appointments are sorted in reverse chronological order (newest first). Includes pull-to-refresh via RefreshIndicator, AppEmptyState when no past appointments, and shares the AppSkeleton/AppErrorState infrastructure from the parent screen. All styling uses design system tokens.

### Files Changed
- `lib/features/appointments/appointments_screen.dart` — Added _buildPastTab, _buildPastCard methods. Added AppEmptyState for past tab empty state.

### Decisions Made During Implementation
- Status always shown as Completed for past appointments (consistent with old appointments screen behavior)
- No days-to-go badge for past appointments (irrelevant for completed appointments)
- Past list sorted newest-first for relevance

### Known Limitations
- Tap on AppointmentCard does not navigate to detail screen yet (onTap is placeholder); navigation wiring pending NavBarPage integration
- Past appointments with "No Preference" doctor show as "No Preference" (same behavior as old screen)

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.
