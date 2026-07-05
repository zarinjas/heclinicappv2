# Record Detail / Viewer

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P6-T05 |
| Slug | record-detail-viewer |
| Process | Epic: UI Migration — Phase 6 |
| Process Step | Step 6.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P6-T01 |
| Blocked Reason | N/A |

---

## Description

Build the Record Detail / Viewer screen for the Health Tab. Tapping a `HealthRecordCard` from the Records tab navigates here to show the full record content. Displays record type header, doctor info, date, formatted clinical notes/letter body, and attachment previews if available. Uses `AppAppBar` with back navigation.

---

## Context

- `docs/ui-design-system.md` — §§2, 3, 4–6, 10 (Health Record Card), 13 (AppBar — sub-page variant), 15 (AppSkeleton), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 6.5 (line 171)
- `docs/v2-ux-spec.md` — Health Tab — Record Detail section
- `docs/v2-decisions.md` — Health Tab Content Spec (lines 311–338)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/health/record_detail_screen.dart` with V2 design system
- Record type header with icon (note / letter / lab / MC)
- Doctor name + specialty display
- Date of record
- Full body content (rich text or plain — handle HTML content from Plato)
- Attachment previews if included in record data (tap to view/zoom)
- `AppAppBar` (sub-page variant) with back arrow and "Record Detail" title
- Skeleton loader during data fetch
- `AppErrorState` with retry if record fails to load
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Health Tab shell (UI-P6-T01)
- Records inner tab (UI-P6-T02)
- Vitals inner tab (UI-P6-T03)
- Documents inner tab (UI-P6-T04)
- Navigation wiring (existing routing preserved)
- API endpoint logic changes

---

## Technical Spec

### Files to Create or Modify
- `lib/features/health/record_detail_screen.dart` — Create record detail viewer screen

### API Endpoints
- `GET /patient/{id}/note/{note_id}` — Individual clinical note detail (via Laravel proxy)
- `GET /letter/{letter_id}` — Individual letter detail (via Laravel proxy)

### Data / Schema
- Record data: type, doctor_name, doctor_specialty, date, body_content (HTML/text), attachments (URLs)
- Existing health data models from Plato integration

### UI Components
- `AppAppBar` (sub-page variant) — Back arrow + "Record Detail" title
- `AppSkeleton` — Content-block shimmer preset during loading
- `AppErrorState` — Error icon + message + "Try Again" button
- `AppCard` — For structured content sections
- `AppChip` — Record type badge at top

### Constraints
- All Plato API calls must route through Laravel proxy
- Handle HTML body content from Plato — use `flutter_html` or equivalent for rendering
- Attachments: tap to open in fullscreen image viewer or PDF viewer
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory
- Dark mode required

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/health/record_detail_screen.dart`
- [ ] `AppAppBar` shows "Record Detail" title with back arrow navigation
- [ ] Record type displayed as `AppChip` badge (Note / Letter / Lab / MC) at top
- [ ] Doctor name + specialty displayed correctly
- [ ] Record date displayed in `dd MMM yyyy` format
- [ ] Full body content rendered correctly (handles both plain text and HTML)
- [ ] Attachments displayed as tappable previews if present in record data
- [ ] `AppSkeleton` shimmer during data fetch
- [ ] `AppErrorState` with retry on load failure
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

