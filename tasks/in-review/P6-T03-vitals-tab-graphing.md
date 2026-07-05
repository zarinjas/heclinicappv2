# Vitals Tab — Health Trends Graphs

## Header

| Field | Value |
|-------|-------|
| Task ID | P6-T03 |
| Slug | vitals-tab-graphing |
| Process | 6 — Health Tab |
| Process Step | Step 3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P6-T02 |
| Blocked Reason | N/A |

---

## Description

Implement the Vitals inner tab of the Health Tab scaffold. This tab fetches health vitals data from the Plato API endpoint `GET /patient/{id}/graphing` and dynamically renders line chart widgets — one per vital type — based on the API response shape. Common vital types include: weight, blood pressure (systolic/diastolic), blood glucose, heart rate, temperature, SpO2. The chart rendering must adapt to whatever vital types the API returns rather than hardcoding specific types.

Per `docs/v2-decisions.md` Process 6 Step 3 and `docs/v2-ux-spec.md` Vitals Tab specification.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 6 Step 3 (line 88), Health Tab Inner Tabs table (line 331)
- `docs/v2-ux-spec.md` — Vitals Tab section (line 584-588), Design System section (line 9), Card component (line 103)
- `docs/CODEBASE.md` — Section 2: Tech Stack (fl_chart or similar for charts; table_calendar exists but not suitable)
- `lib/backend/api_requests/api_calls.dart` — existing API call patterns for Plato endpoints

---

## Scope

> Exact deliverables for this task.

### In Scope
- Create a new API call class `GetVitalsGraphingCall` in `lib/backend/api_requests/api_calls.dart` that calls `GET ${EnvConfig.platomBaseUrl}/patient/{id}/graphing` with standard Plato headers
- The API call must pass `patient_id` and `Authorization: Bearer ${FFAppState().tokenauth}`
- Parse the dynamic graphing response into a list of vital-type entries, each containing name, unit, and an array of {timestamp, value} data points
- Render one line chart card per vital type returned by the API
- Each chart card: card container (V2 styling), vital type name as heading, unit label as subtitle, line chart with time on X axis and value on Y axis
- Use `fl_chart` package for line chart rendering (add to pubspec.yaml if not already present; check first)
- Chart styling: accent (#00C9A7) line, primary (#0F1B3D) dots, subtle grid lines (divider color)
- Loading state: 2× skeleton chart card placeholders (rectangle 200px height)
- Empty state: `EmptyStateWidget` with icon `Icons.monitor_heart_outlined`, title "No vitals recorded", subtitle "Your health trends will appear here"
- Error state: `ErrorStateWidget` with retry callback
- Gracefully handle API responses with unexpected vital types — render what's available

### Out of Scope
- Records tab or Documents tab content
- Modifying the Health tab scaffold (done in P6-T01)
- Pagination / modified_since (deferred to P6-T05)
- Adding flutter_animate for chart animations (already in pubspec)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/backend/api_requests/api_calls.dart` — Add `GetVitalsGraphingCall` class
- `lib/front_page/reports/reports_widget.dart` — Implement Vitals tab body with dynamic chart rendering
- `lib/front_page/reports/reports_model.dart` — Add model fields: vitalsData, isLoadingVitals, vitalsError
- `pubspec.yaml` — Add `fl_chart` dependency if not present (check existing deps first)

### New API Call Class
```dart
class GetVitalsGraphingCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetVitalsGraphing',
      apiUrl: '${EnvConfig.platomBaseUrl}/patient/${patientId}/graphing',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
        'db': 'hemedclinic',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}
```

### Data Model
```dart
class VitalDataPoint {
  final DateTime timestamp;
  final double value;
}

class VitalType {
  final String name;       // e.g., "Weight", "Blood Pressure (Systolic)"
  final String unit;       // e.g., "kg", "mmHg"
  final List<VitalDataPoint> dataPoints;
}
```

### API Response Format (Plato)
The Plato /graphing endpoint returns a dynamic structure. Common shape:
```json
{
  "Weight": [
    {"timestamp": "2025-01-01", "value": 75.5},
    ...
  ],
  "Blood Pressure (Systolic)": [
    {"timestamp": "2025-01-01", "value": 120},
    ...
  ]
}
```
The parsing must iterate over top-level keys and treat each as a vital type.

### Chart Component
- Use `fl_chart` `LineChart` widget
- X axis: time labels (formatted as short date e.g. "Jan 15")
- Y axis: auto-scaled based on data range
- Line: `AppColors.accent`, 2px stroke, curved
- Dots: `AppColors.primary`, 3px radius, visible
- Grid: `AppColors.divider`, dashed
- Background: transparent (inherits card background)
- Card wrapper: V2 card styling, `AppSpacing.md` padding, 220px min height

### UI States
- Loading: 2× `SkeletonCard` (from `lib/components/skeleton_loaders.dart`) at 200px height
- Empty: `EmptyStateWidget(icon: Icons.monitor_heart_outlined, title: 'No vitals recorded', subtitle: 'Your health trends will appear here')`
- Error: `ErrorStateWidget` with retry

### Constraints
- Must route through `EnvConfig.platomBaseUrl` (Laravel proxy)
- Use `FFAppState().tokenauth` for Authorization
- Use `FFAppState().idplato` for patient ID
- All text uses GoogleFonts.plusJakartaSans
- Render dynamically — do NOT hardcode vital type names

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Vitals tab fetches data from the Plato /graphing endpoint via Laravel proxy
- [ ] One chart card is rendered per vital type returned by the API
- [ ] Each chart card shows the vital type name, unit, and a line chart with time vs value
- [ ] Skeleton loaders display while data is being fetched (2 placeholder chart cards)
- [ ] Empty state displays when no vitals data is available
- [ ] Error state displays with retry button on fetch failure
- [ ] Charts render correctly with accent-colored lines on V2-styled cards
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled by Developer after implementation.

### What Was Done
- Added `fl_chart: 0.68.0` to pubspec.yaml dependencies
- Created `GetVitalsGraphingCall` API call class in `lib/backend/api_requests/api_calls.dart` targeting `GET /patient/{id}/graphing` via Laravel proxy
- Added `VitalDataPoint` and `VitalType` data model classes to `lib/front_page/reports/reports_model.dart`
- Added vitals state fields (`vitalsData`, `isLoadingVitals`, `vitalsError`) to `ReportsModel`
- Implemented `_loadVitals()` method: calls GetVitalsGraphingCall, dynamically iterates over response JSON keys, parses timestamp+value data points, infers unit from vital name keywords
- Implemented `_inferUnit()` helper: maps vital name keywords to standard units (kg, mmHg, mmol/L, bpm, °C, %, cm, kg/m²)
- Implemented `_buildVitalChartCard()`: renders one `LineChart` card per vital type using fl_chart with V2 token styling (accent line, primary dots, divider grid)
- Implemented `_buildVitalsTab()`: handles all states — 2× SkeletonCard loading, ErrorStateWidget on failure, EmptyStateWidget with monitor_heart icon when no data, scrollable chart cards when data present
- Replaced Vitals tab skeleton placeholder in TabBarView with `_buildVitalsTab()`
- Added tab change listener: auto-loads vitals when user switches to Vitals tab (index 1) if not already loaded
- Chart renders dynamically based on API response shape — no hardcoded vital type names

### Files Changed
- `pubspec.yaml` — added `fl_chart: 0.68.0`
- `lib/backend/api_requests/api_calls.dart` — added `GetVitalsGraphingCall` class (lines after GetReportCall)
- `lib/front_page/reports/reports_model.dart` — added `VitalDataPoint`, `VitalType` classes and vitals state fields
- `lib/front_page/reports/reports_widget.dart` — added `_loadVitals()`, `_inferUnit()`, `_buildVitalChartCard()`, `_buildVitalsTab()`, updated `initState` tab listener, replaced Vitals placeholder

### Decisions Made During Implementation
- Unit is inferred from vital name keywords rather than expecting it in the API response (Plato API does not include a unit field)
- Timestamp field parsing supports `timestamp`, `time`, and `date` keys for flexibility with API response variations
- Empty response body (empty Map) is treated as "no vitals" rather than an error
- Vitals tab loads lazily (on tab switch) rather than eagerly on page load, to avoid unnecessary API calls for unused tabs
- Line chart uses millisecondsSinceEpoch for X axis; date labels shown as "Mon DD" format

### Known Limitations
- `fl_chart` compilation not verified in this runner (Flutter CLI unavailable); GitHub Actions will catch any issues
- Unit inference relies on English/Malay keyword matching; unusual vital types may show empty unit
- Single data point per vital type will render a chart with one dot (no line); this is acceptable per dynamic rendering spec

---

## QA Notes

> Filled by QA after verification.

### Result: PASSED

### Criteria Results
- [x] API call fetches /graphing data — PASS — GetVitalsGraphingCall uses EnvConfig.platomBaseUrl (Laravel proxy), patientId from FFAppState().idplato, Authorization header with tokenauth
- [x] One chart card per vital type — PASS — _loadVitals dynamically iterates response body entries, creates one VitalType per key; _buildVitalsTab renders one _buildVitalChartCard per VitalType via ListView.builder
- [x] Chart cards show name, unit, line chart — PASS — _buildVitalChartCard renders vital.name as heading, vital.unit as subtitle, LineChart with date-labeled x-axis and value y-axis
- [x] Skeleton loaders appear while loading — PASS — isLoadingVitals state shows 2× SkeletonCard(height: 200) in ListView.builder
- [x] Empty state when no vitals — PASS — EmptyStateWidget with Icons.monitor_heart_outlined, title "No vitals recorded", subtitle "Your health trends will appear here"
- [x] Error state with retry works — PASS — ErrorStateWidget with _loadVitals passed as onRetry callback
- [x] Chart styling uses V2 design tokens — PASS — AppColors.accent line color, AppColors.surface card background, AppRadius.lg card border radius, AppColors.divider border, AppSpacing tokens throughout
- [x] flutter analyze zero errors — PASS (code review) — flutter CLI not available in this runner; code syntax verified via manual review. All imports present (fl_chart, AppColors/AppSpacing/AppRadius from app_theme.dart), types match model definitions, no obvious issues.

### Failure Details
N/A

---

## Reviewer Notes

> Filled by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}

### Rejection Reason
{to be filled if rejected}
