# Vitals Inner Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P6-T03 |
| Slug | vitals-tab |
| Process | Epic: UI Migration — Phase 6 |
| Process Step | Step 6.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P6-T01 |
| Blocked Reason | N/A |

---

## Description

Implement the Vitals inner tab within the Health Tab shell. Displays health trend graphs from Plato API (`GET /patient/{id}/graphing`). Renders `VitalsChart` components dynamically based on API response shape — one chart per vital type. Includes skeleton loading, empty state, and error state.

---

## Context

- `docs/ui-design-system.md` — §§2, 3, 4–6, 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 6.3 (line 169)
- `docs/v2-ux-spec.md` — Health Tab — Vitals section
- `docs/v2-decisions.md` — Health Tab Content Spec (lines 311–338, line 321 — VitalsChart)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Implement Vitals inner tab content in the Health Tab shell (`lib/features/health/`)
- Render `VitalsChart` widget dynamically per vital type from API response
- Line graph visualization for each vital metric (blood pressure, heart rate, weight, etc.)
- Skeleton loader (`AppSkeleton`) during data fetch
- `AppEmptyState` when no vitals data exists — "No vitals recorded yet" with heart illustration
- `AppErrorState` with "Try Again" button on API failure
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Health Tab shell (UI-P6-T01)
- Records inner tab (UI-P6-T02)
- Documents inner tab (UI-P6-T04)
- The `VitalsChart` component itself (built in Phase 1 — UI-P1-T16)
- API endpoint logic changes (use existing GET /patient/{id}/graphing via Laravel proxy)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/health/vitals_tab.dart` — Create vitals tab content widget
- `lib/core/widgets/vitals_chart.dart` — Reuse existing VitalsChart component (Phase 1)

### API Endpoints
- `GET /patient/{id}/graphing` — Health trends graph data (via Laravel proxy)

### Data / Schema
- Dynamic response from `GET /patient/{id}/graphing` — render chart per vital type in response
- Handle varying response shapes gracefully

### UI Components
- `VitalsChart` — One per vital type, rendered from Phase 1 component
- `AppSkeleton` — Chart-area shimmer preset during loading
- `AppEmptyState` — Heart illustration + "No vitals recorded yet" message
- `AppErrorState` — Error icon + message + "Try Again" button

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory
- Charts must render dynamically — do not hardcode chart types
- Dark mode required

---

## Acceptance Criteria

- [ ] Vitals tab renders inside Health Tab shell
- [ ] `VitalsChart` widgets render dynamically — one chart per vital type from API response
- [ ] Line graph styling uses `AppColors.accent` for line, `AppColors.primary` for labels
- [ ] `AppSkeleton` shimmer shows during data fetch
- [ ] `AppEmptyState` shows heart illustration + "No vitals recorded yet" when API returns no data
- [ ] `AppErrorState` with retry button on API failure
- [ ] All design tokens used: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`
- [ ] Dark mode works correctly on all states
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

