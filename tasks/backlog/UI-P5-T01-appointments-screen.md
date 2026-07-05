# Appointments Tab Shell

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P5-T01 |
| Slug | appointments-screen |
| Process | Epic: UI Migration — Phase 5 |
| Process Step | Step 5.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Appointments Tab shell — the 5th bottom nav tab. Contains an Upcoming/Past tab switcher using `AppChip`-style buttons (not default `TabBar`) and slots for the two inner tab content areas. This is the entry point to the appointments feature and replaces the old `BookingPage` as the main appointments tab in the bottom navigation.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 11 (AppChip), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 5 (lines 145–161), Phase 12 (Navigation Migration)
- `docs/v2-ux-spec.md` — Appointments Tab screen specifications
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/appointments/appointments_screen.dart` with V2 design system
- Tab switcher: Upcoming / Past — use `AppChip`-style tap buttons with selected/unselected styling (NOT default Flutter `TabBar`)
- Skeleton loader (`AppSkeleton`) during initial data load
- `AppEmptyState` with calendar illustration + "Book Now" CTA button for both tabs
- `AppErrorState` with retry for API failures
- Paginated list support structure (delegates to `AppointmentCard` for each row)
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- The Upcoming and Past inner tab content implementations (separate tasks UI-P5-T02, UI-P5-T03)
- Appointment Detail screen (separate task UI-P5-T04)
- Navigation wiring to bottom nav (Phase 12 task)
- API endpoint logic (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/appointments/appointments_screen.dart` — Create new shell screen with tab switcher

### API Endpoints
- N/A — Reuse existing appointment listing endpoints from booking flow

### Data / Schema
- Existing appointment data models from booking flow
- `FFAppState` variables for appointment list (preserve existing logic)

### UI Components
- `AppChip` — for Upcoming/Past tab toggle buttons
- `AppAppBar` (sub-page variant) — "Appointments" title
- `AppSkeleton` — shimmer while fetching appointments
- `AppEmptyState` — calendar illustration + subtitle + "Book Now" CTA
- `AppErrorState` — error icon + message + "Try Again" button

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory

---

## Acceptance Criteria

- [ ] `appointments_screen.dart` exists and compiles with `flutter analyze` (zero errors)
- [ ] Tab switcher renders as `AppChip`-style buttons — "Upcoming" and "Past" with selected/unselected visual states
- [ ] Skeleton loader appears while fetching appointment data
- [ ] Empty state renders AppEmptyState with illustration and "Book Now" button when no appointments
- [ ] Error state renders AppErrorState with retry button on API failure
- [ ] Dark mode renders correctly — background, text, and component colors match design tokens
- [ ] No hardcoded colors (hex), font sizes, spacing, or border radius in the file
- [ ] No `FFButtonWidget`, `FlutterFlowTheme`, or inline style references

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
