# All Doctors List Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T06 |
| Slug | all-doctors-list-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | N/A |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the All Doctors List screen — a searchable vertical list of all doctors (`is_visible_in_app = true`). Accessible from Home (Our Doctors → See All). Each row uses the DoctorCard component (vertical variant). Tap opens the Doctor Detail Bottom Sheet (Phase 10.5). Skeleton, empty state, and error state defined.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 6 (DoctorCard), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 19 (AppBottomSheet), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.6 (lines 255–256)
- `docs/v2-decisions.md` — Doctor Management (§390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `telehealth/` existing reference (line 188)

---

## Scope

### In Scope
- Create `lib/features/doctors/doctors_list_screen.dart` with V2 design system
- Searchable `ListView` of `DoctorCard` (vertical variant) — filtered to `is_visible_in_app = true`
- Search bar at top (AppInput with search icon) filtering by name/specialty
- Tap card → opens Doctor Detail Bottom Sheet (Phase 10.5 widget)
- `AppSkeleton` shimmer while loading
- `AppEmptyState` with "No doctors found" + illustration
- `AppErrorState` with retry on fetch failure
- `RefreshIndicator` pull-to-refresh
- Support dark mode
- `AppAppBar` (sub-page) with "All Doctors" title and back arrow

### Out of Scope
- Doctor Detail Bottom Sheet implementation (Phase 10.5 — separate task)
- CMS backend CRUD (already DONE — Process 9)
- Registering route in GoRouter (Phase 12)
- Telehealth/video call functionality (removed in V2)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/doctors/doctors_list_screen.dart` — Create All Doctors List screen

### API Endpoints
- `GET /api/v2/config/doctors` — fetch doctors list (filter `is_visible_in_app=true`)

### Data / Schema
- Doctor: id, full_name, specialty, photo_url, branch_name, bio, is_visible_in_app

### UI Components
- `AppAppBar` (sub-page) — "All Doctors" title with back arrow
- Search bar — `AppInput` with search icon, filters list by name/specialty
- `ListView.builder` — vertical `DoctorCard` per doctor
- `DoctorCard` (vertical variant from Phase 1)
- Doctor Detail Bottom Sheet — `showModalBottomSheet` → Phase 10.5 widget
- `AppSkeleton` — shimmer card + list item presets
- `AppEmptyState` — "No doctors found" + illustration
- `AppErrorState` — error + retry button
- `RefreshIndicator`

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Only show doctors with `is_visible_in_app = true`
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/doctors/doctors_list_screen.dart`
- [ ] `AppAppBar` with "All Doctors" title and back arrow
- [ ] Search bar (`AppInput` with search icon) filters doctors by name/specialty
- [ ] Vertical `ListView` of `DoctorCard` (vertical variant)
- [ ] Only doctors with `is_visible_in_app = true` displayed
- [ ] Tap card → opens Doctor Detail Bottom Sheet
- [ ] `AppSkeleton` shimmer while loading
- [ ] `AppEmptyState` with "No doctors found" + illustration on zero results
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] `RefreshIndicator` pull-to-refresh
- [ ] Dark mode: correct background and text colors
- [ ] All colors use `AppColors` tokens
- [ ] All typography uses `AppTextStyles`
- [ ] All spacing uses `AppSpacing` constants
- [ ] Balance radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Zero `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled by developer}

### Files Changed
- {To be filled by developer}

### Decisions Made During Implementation
{To be filled by developer}

### Known Limitations
{To be filled by developer}

---

## QA Notes

> Filled in by QA after verification.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] {Criterion} — {PASS / FAIL} — {note}

### Failure Details
{If FAILED: describe what was wrong.}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}
- ui-design-system.md compliance: {YES / NO} — {note}

### Rejection Reason
{If REJECTED: describe specific deviation.}
