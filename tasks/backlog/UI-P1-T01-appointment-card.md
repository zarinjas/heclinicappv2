# AppointmentCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T01 |
| Slug | appointment-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A (Phase 0 components built) |
| Blocked Reason | N/A |

---

## Description

Build the `AppointmentCard` reusable component used across the Appointments tab, Home screen (upcoming appointment section), and Appointment Detail screen. Displays doctor photo, name, specialty, branch, date/time, and status chip in a structured card layout per the design system spec.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §10 (Cards — Appointment Card), §11 (Chips — Status Chips)
- `docs/ui-migration-plan.md` — Phase 1, §1.1 (AppointmentCard), Phase 5 (Appointments Tab notes)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Appointment card layout in relevant screen sections

---

## Scope

### In Scope
- `lib/core/widgets/appointment_card.dart` — new file
- Doctor photo (56px circle avatar, leading)
- Doctor name (`heading3`) + specialty (`body2`, `textSecondary`)
- Branch name row with location icon
- Bottom row: date + time (left), status chip (right)
- Upcoming variant: "X days to go" badge (top-right corner, accent bg)
- Support status chip variants: Confirmed, Pending, Cancelled, Completed (per §11 colors)
- Tap callback → navigation to Appointment Detail
- Skeleton loader variant for loading state

### Out of Scope
- Appointment Detail screen navigation (handled by parent screen)
- Actual API data fetching (component is presentational)
- Swipe actions (handled by parent list)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/appointment_card.dart` — create new component widget

### API Endpoints
- N/A (presentational component — data passed via constructor)

### UI Components
- `AppCard` (base card from UI-P0-T07)
- `AppChip` status variants (from UI-P0-T08)
- `AppSkeleton` shimmer (from UI-P0-T09)

### Design Spec (from ui-design-system.md §10)
- Background: `#FFFFFF` (surface)
- Border radius: 16px (`AppRadius.lg`)
- Padding: 16px (`AppSpacing.md`)
- Shadow: `AppShadows.low`
- Border: 1px solid `#E5E7EB` (light mode)
- Doctor photo: 56px circle, leading
- Title: doctor name, heading3
- Subtitle: specialty, body2, textSecondary
- Meta row: branch name with `Icons.location_on_outlined`
- Bottom row: date + time (left), status chip (right)
- Upcoming badge: top-right, accent bg, "X days to go"

### Constraints
- All colors must use `AppColors` tokens (no hardcoded hex)
- All text must use `AppTextStyles` (no hardcoded TextStyle)
- All spacing must use `AppSpacing` constants
- Must support dark mode (`ThemeMode.dark`)
- Component is presentational only — no business logic

---

## Acceptance Criteria

- [ ] Doctor photo renders as 56px circle avatar on the left
- [ ] Doctor name displayed in heading3 style, specialty in body2 with textSecondary
- [ ] Branch name row displays with location icon and branch name
- [ ] Bottom row shows formatted date/time on left and status chip on right with correct colors (Confirmed=green, Pending=amber, Cancelled=red, Completed=blue)
- [ ] Upcoming variant displays "X days to go" badge in top-right corner with accent background
- [ ] Tap callback fires correctly (tested with mock onTap)
- [ ] Skeleton loader variant renders shimmer placeholder matching card layout
- [ ] Dark mode renders correctly (card bg=#141C2E, text=#FFFFFF, divider=#1F2937)
- [ ] No hardcoded colors, text styles, spacing, or radius values
- [ ] `flutter analyze` returns zero errors

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
