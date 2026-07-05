# Records Inner Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P6-T02 |
| Slug | records-tab |
| Process | Epic: UI Migration — Phase 6 |
| Process Step | Step 6.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P6-T01 |
| Blocked Reason | N/A |

---

## Description

Implement the Records inner tab within the Health Tab shell. Displays clinical notes, MC, referral letters, and lab results from Plato API with filter chips (All / Notes / Letters / Lab / MC). Uses `HealthRecordCard` component for each row. Paginated list with skeleton loading, empty state, and error state.

---

## Context

- `docs/ui-design-system.md` — §§2, 3, 4–6, 10 (Health Record Card), 11 (AppChip — filter chips), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 6.2 (line 168)
- `docs/v2-ux-spec.md` — Health Tab — Records section
- `docs/v2-decisions.md` — Health Tab Content Spec (lines 311–338), Health Record Card spec (line 321–329)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Implement Records inner tab content in the Health Tab shell (`lib/features/health/`)
- Filter chips row: All / Notes / Letters / Lab / MC — using `AppChip` filter variant with active/inactive states
- `ListView` of `HealthRecordCard` widgets — type icon (40px circle), title, doctor name subtitle, date trailing
- Paginated list (10 per page) — load more on scroll
- Skeleton loader (`AppSkeleton` — list item preset) on initial load and page transitions
- `AppEmptyState` with clipboard illustration + "No records found" when filter returns empty
- `AppErrorState` with "Try Again" button on API failure
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Health Tab shell (UI-P6-T01)
- Vitals inner tab (UI-P6-T03)
- Documents inner tab (UI-P6-T04)
- Record Detail screen (UI-P6-T05)
- API endpoint logic changes (use existing GET /patient/{id}/note, GET /letter endpoints via Laravel proxy)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/health/records_tab.dart` — Create records tab content widget
- Existing `lib/core/widgets/health_record_card.dart` — Use as row component

### API Endpoints
- `GET /patient/{id}/note` — Clinical notes (via Laravel proxy)
- `GET /letter` — MC, referral letters (via Laravel proxy)

### Data / Schema
- Existing health data models from Plato integration
- Filter state managed locally in the tab widget

### UI Components
- `AppChip` (filter variant) — All / Notes / Letters / Lab / MC filter row
- `HealthRecordCard` — Per-row component with type icon, title, subtitle, date
- `AppSkeleton` — List item shimmer preset during loading
- `AppEmptyState` — Clipboard illustration + "No records found" message
- `AppErrorState` — Error icon + message + "Try Again" button

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory
- Paginated list — 10 items per page
- Dark mode required

---

## Acceptance Criteria

- [ ] Records tab renders inside Health Tab shell
- [ ] Filter chips row visible: All / Notes / Letters / Lab / MC — using `AppChip` with correct active/inactive styling
- [ ] Filtering works: tapping a chip filters the list by record type
- [ ] `HealthRecordCard` renders per row: leading type icon (40px circle, accent tint), title (heading3), doctor subtitle (body2, textSecondary), date trailing (body2, textSecondary)
- [ ] Paginated list: 10 items per page, load more on scroll
- [ ] `AppSkeleton` shimmer shows during initial load and between pages
- [ ] `AppEmptyState` shows clipboard illustration + "No records found" when no records match
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

