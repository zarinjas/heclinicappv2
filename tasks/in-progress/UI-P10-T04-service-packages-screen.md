# Service Packages Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T04 |
| Slug | service-packages-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-06 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Service Packages screen — displays clinic service packages with dynamic CMS-driven cards. Replaces the existing 4 hardcoded static images in `lib/service_package/` with a dynamic, paginated list of package cards (name, image, description, price). Accessible from Home (Quick Actions → Packages). Skeleton shimmer during load, empty/error states defined.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.4 (lines 251–252)
- `docs/v2-decisions.md` — CMS Content Management (§115, §390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `service_package/` existing ref (line 187), known issue §902 (4 static images)

---

## Scope

### In Scope
- Create `lib/features/content/packages_screen.dart` with V2 design system
- Dynamic list of package cards (name, image, description, price) fetched from CMS
- Each card: featured image (full width, rounded top corners), package name (heading-sm), short description (body-md, text-secondary), price label (body-lg, accent)
- Paginated list (10 items/page)
- `AppSkeleton` shimmer while loading
- `AppEmptyState` with "No packages available" + illustration
- `AppErrorState` with retry on fetch failure
- `RefreshIndicator` pull-to-refresh
- Support dark mode
- `AppAppBar` (sub-page) with "Service Packages" title and back arrow

### Out of Scope
- Package detail/booking from this screen (booking flow is Phase 4 — already DONE)
- CMS backend CRUD (already DONE — Process 9)
- Registering screen in GoRouter (Phase 12)
- Replacing old static service package page (legacy cleanup is Phase 13)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/content/packages_screen.dart` — Create new Service Packages screen

### API Endpoints
- `GET /api/v2/cms/packages` (paginated, 10/page) — Laravel proxy

### Data / Schema
- CMS service packages: id, name, slug, image_url, description, price (RM), is_published, sort_order

### UI Components
- `AppAppBar` (sub-page) — "Service Packages" title with back arrow
- `ListView.builder` paginated
- Package card (`AppCard` with image header + content)
- `AppSkeleton` — shimmer card + text bar presets
- `AppEmptyState` — illustration + message
- `AppErrorState` — error + retry button
- `RefreshIndicator`

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required (scaffold `#0A0E1A`, surface `#141C2E`)
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Package images fetched dynamically (no static/hardcoded images)
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/content/packages_screen.dart`
- [ ] `AppAppBar` with "Service Packages" title and back arrow displayed
- [ ] Dynamic paginated list of package cards fetched from CMS API (10/page)
- [ ] Package card: featured image with rounded top corners
- [ ] Package card: package name (heading-sm), description (body-md, text-secondary)
- [ ] Package card: price label (body-lg, accent color)
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppEmptyState` with "No packages available" + illustration on zero results
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] `RefreshIndicator` pull-to-refresh working
- [ ] Dark mode: correct background and text colors
- [ ] No hardcoded static images — all fetched from CMS API
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
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
