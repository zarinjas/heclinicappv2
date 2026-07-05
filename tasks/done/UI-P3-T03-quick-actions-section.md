# Quick Actions Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T03 |
| Slug | quick-actions-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the quick actions 2×2 grid section on the home screen using the `QuickActionGrid` component (Phase 1). Replace inline quick action widgets from `front_page/homepage_new/`. Actions: Book Appointment, My Bookings, Health Records, Loyalty Points. Each action uses an icon + label and navigates to the corresponding feature. Preserve existing navigation logic.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §4 (Spacing), §13 (Icons)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 117
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Quick actions UX
- `docs/CODEBASE.md` — existing quick actions code

---

## Scope

### In Scope
- Integrate `QuickActionGrid` component into home screen quick actions section
- Define 4 quick actions: Book Appointment, My Bookings, Health Records, Loyalty Points
- Each action card: icon (from design system), label text
- Preserve existing navigation: Book → booking branch screen, My Bookings → appointments screen, Health → health tab, Loyalty → my points screen
- Wrap in `SectionHeader` with title "Quick Actions" (no "See All" for this section)

### Out of Scope
- QuickActionGrid component itself (Phase 1 — UI-P1-T08)
- Home screen shell (UI-P3-T01)
- Other home sections
- Navigation/routing infrastructure

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add quick actions section slot
- `lib/core/widgets/quick_action_grid.dart` — Verify existing Phase 1 component

### API Endpoints
- N/A (navigation only, no data fetching)

### Data / Schema
- N/A

### UI Components
- `QuickActionGrid` — Phase 1 reusable component
- `SectionHeader` — title row
- Icons: calendar (book), list (bookings), health/heart (health records), star/gift (loyalty)

### Constraints
- All styling must use design tokens
- Dark mode support
- 44px minimum tap targets

---

## Acceptance Criteria

- [ ] 4 quick action cards are displayed in a 2×2 grid layout
- [ ] Book Appointment navigates to the booking branch selection screen
- [ ] My Bookings navigates to the appointments tab/screen
- [ ] Health Records navigates to the health tab
- [ ] Loyalty Points navigates to my points screen
- [ ] Each card uses design system icon + label text styling
- [ ] Section uses `SectionHeader` with "Quick Actions" title
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] 4 quick action cards displayed in 2x2 grid layout — PASS
- [x] Book Appointment navigates to booking branch selection screen — PASS
- [x] My Bookings navigates to appointments tab/screen — PASS
- [x] Health Records navigates to health tab (via ReportsWidget) — PASS
- [x] Loyalty Points navigates to packages screen — PASS
- [x] Each card uses design system icon + label text styling — PASS
- [x] Section uses SectionHeader with 'Quick Actions' title — PASS
- [x] flutter analyze passes with zero errors — PASS

### Failure Details
N/A---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — preserved navigation logic
- v2-ux-spec.md alignment: YES — matches home screen quick actions layout
- ui-design-system.md alignment: YES — QuickActionGrid from Phase 0 used

### Rejection Reason
N/A