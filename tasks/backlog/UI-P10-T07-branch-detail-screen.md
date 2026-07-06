# Branch Detail Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T07 |
| Slug | branch-detail-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.7 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | N/A |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Branch Detail screen — shows full branch information: hero image, name, address, operating hours, with "Get Directions" and "WhatsApp Us" action buttons. Accessible from booking flow branch selection or branch references throughout the app. Replaces the existing hardcoded BranchLocationNewCopy page.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.7 (lines 257–258)
- `docs/v2-ux-spec.md` — Branch Detail screen (lines 671–680)
- `docs/v2-decisions.md` — Branch Management
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `branch_location_new_copy/` existing ref (line 178)

---

## Scope

### In Scope
- Create `lib/features/branch/branch_detail_screen.dart` with V2 design system
- Hero image (branch photo, 220px, full width)
- Branch name (heading-lg)
- Address (body-md)
- Operating hours (body-md)
- "Get Directions" `AppButton` (secondary) — opens `maps.google.com/?q={lat},{lng}`
- "WhatsApp Us" `AppButton` (whatsapp variant) — opens WA deep link with branch WA number
- `AppSkeleton` shimmer while loading branch data
- `AppErrorState` with retry on fetch failure
- Support dark mode
- `AppAppBar` (sub-page) with branch name and back arrow

### Out of Scope
- CMS backend CRUD (already DONE — Process 9)
- Registering route in GoRouter (Phase 12)
- Deleting old BranchLocationNewCopy page (Phase 13 legacy cleanup)
- Branch list screen (booking flow branch selection — Phase 4, already DONE)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/branch/branch_detail_screen.dart` — Create Branch Detail screen

### API Endpoints
- `GET /api/v2/config/branches/{id}` — fetch single branch detail

### Data / Schema
- Branch: id, name, photo_url, address, operating_hours, latitude, longitude, whatsapp_number, is_active

### UI Components
- `AppAppBar` (sub-page) — branch name title with back arrow
- Hero image — `ClipRRect` full width, 220px height
- Branch name — `AppTextStyles.heading2`
- Address — `AppTextStyles.body1`, `AppColors.textSecondary`
- Operating hours — `AppTextStyles.body1`
- `AppButton.secondary` — "Get Directions" (opens Google Maps URL)
- `AppButton.whatsapp` — "WhatsApp Us" (opens WA deep link)
- `AppSkeleton` — shimmer image rect + text bars
- `AppErrorState` — error + retry button

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- WhatsApp number fetched dynamically per branch (not hardcoded)
- Google Maps link uses coordinates from branch data
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/branch/branch_detail_screen.dart`
- [ ] `AppAppBar` with branch name and back arrow
- [ ] Hero image (branch photo, 220px, full width) at top
- [ ] Branch name (heading-lg) displayed
- [ ] Address (body-md, text-secondary) displayed
- [ ] Operating hours (body-md) displayed
- [ ] "Get Directions" button opens Google Maps with branch coordinates
- [ ] "WhatsApp Us" button opens WA deep link with branch WA number
- [ ] `AppSkeleton` shimmer while loading branch data
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] Dark mode: correct background and text colors
- [ ] WhatsApp number fetched dynamically (not hardcoded)
- [ ] All colors use `AppColors` tokens
- [ ] All typography uses `AppTextStyles`
- [ ] All spacing uses `AppSpacing` constants
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
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
