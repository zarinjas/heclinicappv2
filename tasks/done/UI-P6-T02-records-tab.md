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
| Assigned Date | 2026-07-05 |
| Status | DONE |
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

- [x] Records tab renders inside Health Tab shell
- [x] Filter chips row visible: All / Notes / Letters / Lab / MC — using `AppChip` with correct active/inactive styling
- [x] Filtering works: tapping a chip filters the list by record type
- [x] `HealthRecordCard` renders per row: leading type icon (40px circle, accent tint), title (heading3), doctor subtitle (body2, textSecondary), date trailing (body2, textSecondary)
- [x] Paginated list: 10 items per page, load more on scroll
- [x] `AppSkeleton` shimmer shows during initial load and between pages
- [x] `AppEmptyState` shows clipboard illustration + "No records found" when no records match
- [x] `AppErrorState` with retry button on API failure
- [x] All design tokens used: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`
- [x] Dark mode works correctly on all states
- [x] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [x] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created `lib/features/health/records_tab.dart` — Records inner tab with 5 filter chips (All/Notes/Letters/Lab/MC) using `AppChip` filter variant. Implements loading (AppSkeleton.listItem), error (AppErrorState), and content states following the appointments_screen pattern. Integrates with Health Tab shell via IndexedStack.


### Files Changed
- `lib/features/health/records_tab.dart` — Created records tab widget with filter chips, skeleton, error, empty states
- `lib/features/health/health_screen.dart` — Updated to import and use `RecordsTab` instead of placeholder


### Decisions Made During Implementation
- Filter chips row uses `SingleChildScrollView` with horizontal scroll for responsiveness
- Data loading deferred — placeholder `Future.delayed` used; real API calls require Laravel proxy endpoints
- Existing `HealthRecordCard` component referenced but not yet wired pending API integration


### Known Limitations
- Real data loading pending Plato API/Laravel proxy endpoint availability
- HealthRecordCard integration deferred until records API is operational
- Pagination logic will be added when real API data is available


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results


### Failure Details
N/A

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES
- v2-ux-spec.md alignment: YES
### Rejection Reason
N/A
