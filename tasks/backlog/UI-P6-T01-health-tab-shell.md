# Health Tab Shell

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P6-T01 |
| Slug | health-tab-shell |
| Process | Epic: UI Migration — Phase 6 |
| Process Step | Step 6.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Health Tab shell — the 3rd bottom nav tab. Contains a 3-tab inner navigation (Records / Vitals / Documents) using `AppChip`-style tab buttons. This is the entry point to the health section and slots the three inner tab content areas. All health data comes from Plato API via Laravel proxy.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 11 (AppChip), 12 (AppNavBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 6 (lines 164–180)
- `docs/v2-ux-spec.md` — Health Tab screen specifications
- `docs/v2-decisions.md` — Health Tab Content Spec (lines 311–338)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/health/health_screen.dart` with V2 design system
- Inner tab switcher: Records / Vitals / Documents — use `AppChip`-style toggle buttons with selected/unselected styling (NOT default Flutter `TabBar`)
- `IndexedStack` or equivalent to preserve tab state across switches
- Skeleton loader (`AppSkeleton`) during initial data load
- `AppEmptyState` for each tab context
- `AppErrorState` with retry for API failures
- `AppAppBar` (sub-page variant) — "Health" title
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Records inner tab content implementation (separate task UI-P6-T02)
- Vitals inner tab content implementation (separate task UI-P6-T03)
- Documents inner tab content implementation (separate task UI-P6-T04)
- Record Detail / Viewer screen (separate task UI-P6-T05)
- Navigation wiring to bottom nav (Phase 12 task)
- API endpoint logic (keep existing business logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/health/health_screen.dart` — Create new shell screen with 3-tab inner switcher

### API Endpoints
- N/A — Reuse existing health-related endpoints

### Data / Schema
- Existing patient/health data models
- `FFAppState` variables for health data (preserve existing logic)

### UI Components
- `AppChip` — for Records / Vitals / Documents tab toggle buttons
- `AppAppBar` (sub-page variant) — "Health" title
- `AppSkeleton` — shimmer while fetching health data
- `AppEmptyState` — context-specific illustration + subtitle per tab
- `AppErrorState` — error icon + message + "Try Again" button
- `AppBottomSheet` — (if needed for detail views)

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory
- Dark mode required on all states

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/health/health_screen.dart`
- [ ] 3 inner tabs visible: Records, Vitals, Documents — using `AppChip`-style buttons, NOT default `TabBar`
- [ ] Tab switching works correctly with smooth fade animation (200ms)
- [ ] `AppSkeleton` shows shimmer during initial load
- [ ] `AppEmptyState` renders with context-appropriate illustration and subtitle for each tab
- [ ] `AppErrorState` renders with retry button on API failure
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold background `#0A0E1A`, surface `#141C2E`, correct text colors
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results


### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check


### Rejection Reason

