# Our Doctors Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T06 |
| Slug | doctors-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the "Our Doctors" horizontal scroll section on the home screen using the `DoctorCard` component (Phase 1). Fetch doctors whose `is_visible_in_app = true` from `GET /api/v2/config/doctors` (admin CMS). Display as a horizontal `ListView` of `DoctorCard` components. Show `AppSkeleton` while loading. Hide section if 0 visible doctors. "See All" navigates to All Doctors list screen (Phase 10). Replace all 17 hardcoded doctor modals.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §10 (AppCard), §15 (Skeleton), §16 (EmptyState)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 120
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Doctor card UX
- `docs/CODEBASE.md` — existing doctor components, doctor modals

---

## Scope

### In Scope
- Integrate horizontal scroll `DoctorCard` list into home screen doctors section
- Fetch visible doctors from `GET /api/v2/config/doctors` (filter `is_visible_in_app = true`)
- Render horizontal `ListView.builder` with `DoctorCard` components
- Show `AppSkeleton` shimmer (3-4 card placeholders) while loading
- Hide section if 0 visible doctors
- "See All" navigates to All Doctors list (Phase 10)
- Tap a doctor card opens `DoctorDetailBottomSheet` (Phase 10)
- Remove hardcoded doctor modals (17+ old component widgets) — references only

### Out of Scope
- DoctorCard component itself (Phase 1 — UI-P1-T02)
- All Doctors list screen (Phase 10)
- Doctor detail bottom sheet (Phase 10)
- Doctor management CMS (Process 9)
- Home screen shell (UI-P3-T01)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add doctors section slot
- `lib/core/widgets/doctor_card.dart` — Use existing Phase 1 component

### API Endpoints
- `GET /api/v2/config/doctors` — fetch visible doctors (via Laravel proxy)

### Data / Schema
- Doctor: `id`, `name`, `specialty`, `photo_url`, `is_visible_in_app`, `branch_id`

### UI Components
- `DoctorCard` — Phase 1 reusable, horizontal compact variant
- `AppSkeleton` — shimmer doctor card placeholders
- `SectionHeader` — "Our Doctors" + "See All"

### Constraints
- All styling must use design tokens
- Dark mode support
- Replace all hardcoded doctor modals with dynamic DoctorCard + DoctorDetailBottomSheet
- Only `is_visible_in_app = true` doctors shown

---

## Acceptance Criteria

- [ ] Doctors section displays a horizontal scrollable list of `DoctorCard` components
- [ ] Only doctors with `is_visible_in_app = true` are shown
- [ ] `AppSkeleton` shimmer (3-4 placeholder cards) is displayed while loading
- [ ] Section is hidden when 0 visible doctors exist
- [ ] "See All" tap navigates to All Doctors list screen
- [ ] Tapping a doctor card opens DoctorDetailBottomSheet
- [ ] No hardcoded doctor modal components are referenced from the home screen
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

### Result: PASSED / FAILED

### Criteria Results

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason

