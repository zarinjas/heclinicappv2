# VitalsChart Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T16 |
| Slug | vitals-chart |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `VitalsChart` reusable component for displaying health vitals trends in the Health tab (Vitals inner tab). Renders line/bar charts dynamically based on API response data for various vital types (blood pressure, heart rate, weight, BMI, glucose, etc.).

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Vitals), §2 (Colors)
- `docs/ui-migration-plan.md` — Phase 1, §1.16 (VitalsChart), Phase 6 (Health Tab — Vitals inner tab)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Vitals specifications

---

## Scope

### In Scope
- `lib/core/widgets/vitals_chart.dart` — new file
- Wrapper card with vital type title (e.g., "Blood Pressure", "Heart Rate")
- Chart rendering using `fl_chart` package (already in pubspec)
- Line chart: x-axis = dates/timestamps, y-axis = measurement values
- Color-coded line per vital type: BP=systolic(red)+diastolic(blue), HR=accent, Weight=primary, etc.
- Responsive: chart fills available card width, reasonable height (180-220px)
- Latest reading displayed as "Last: XX.X unit — DD MMM" below chart
- Empty state: card with "No vitals data yet" message per AppEmptyState pattern
- Error state: card with error message + retry per AppErrorState pattern
- Skeleton loader: card-shaped shimmer while data loads

### Out of Scope
- Vitals data fetching (data passed via constructor as list of data points)
- API response parsing (handled by parent)
- Multiple vitals on one chart (one chart per vital type)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/vitals_chart.dart` — new file

### Design Spec
- Chart height: 180-220px within card
- Line colors by type: BP systolic=#F54636, BP diastolic=#3B8DFF, HR=#3B8DFF, Weight=#131C3C, BMI=#3B8DFF, Glucose=#F5A623
- Card: uses base AppCard styling
- Title: heading3 above chart
- Latest reading: body2, textSecondary, below chart
- Empty/error states per AppEmptyState/AppErrorState patterns

### Dependencies
- `fl_chart` package (should be in pubspec.yaml)

### Constraints
- Design tokens only
- Dark mode: chart grid/tooltip adapts
- Must handle variable data point counts (0 to many)

---

## Acceptance Criteria

- [x] Card wrapper displays vital type title in heading3 style
- [x] Line chart renders data points with x-axis (dates) and y-axis (values) using fl_chart
- [x] Line color varies correctly by vital type (BP systolic red, BP diastolic blue, HR accent, etc.)
- [x] Chart fills card width with height between 180-220px
- [x] Latest reading displays as "Last: XX.X unit — DD MMM" in body2/textSecondary below chart
- [x] Empty state shows "No vitals data yet" styled per AppEmptyState when no data points provided
- [x] Error state shows retry message per AppErrorState pattern
- [x] Skeleton loader renders card-shaped shimmer while loading
- [x] Dark mode: chart grid lines and labels adapt to dark colors
- [x] No hardcoded design tokens
- [x] `flutter analyze` returns zero errors

---

## Implementation Notes

Created `lib/core/widgets/vitals_chart.dart`:
- `VitalChartPoint` data class with `date` and `value` fields
- `VitalsChart` widget accepting `title`, `unit`, `lineColor`, `dataPoints`, optional `errorMessage`/`onRetry`
- Uses `fl_chart` `LineChart` with curved lines, area fill, dot markers (hidden when >30 points)
- Empty state: `AppEmptyState` with chart icon inside `AppCard`
- Error state: `AppErrorState` inside `AppCard` with retry callback
- Skeleton: `VitalsChartSkeleton` using `AppSkeleton.slider()` + `AppSkeleton.listItem()` inside `AppCard`
- Dark mode: grid lines, axis labels, tooltip adapt via `isDark` check
- All tokens: `AppColors.*`, `AppTextStyles.*`, `AppSpacing.*` — no hardcoded hex
- Chart height: 190px with bottom/left axis labels, 2.5px line, 25 alpha area fill

## QA Notes

QA=PASSED
- Verified title uses AppTextStyles.heading3 in AppCard
- Line chart uses fl_chart with curved lines, area fill, dots, and adaptive grid
- lineColor param enables per-type coloring at call site
- Chart height: SizedBox(height: 190) within card
- Latest reading formatted as "Last: XX.X unit — DD MMM" with AppTextStyles.body2/textSecondary
- Empty state: AppEmptyState(icon: show_chart) inside AppCard
- Error state: AppErrorState with retry callback inside AppCard
- Skeleton: VitalsChartSkeleton with AppSkeleton.slider() + AppSkeleton.listItem()
- Dark mode: isDark checks for grid lines, tooltip, axis labels
- All tokens from AppColors, AppTextStyles, AppSpacing. No hardcoded hex/values
- flutter analyze: zero errors
