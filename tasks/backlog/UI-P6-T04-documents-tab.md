# Documents Inner Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P6-T04 |
| Slug | documents-tab |
| Process | Epic: UI Migration — Phase 6 |
| Process Step | Step 6.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P6-T01 |
| Blocked Reason | N/A |

---

## Description

Implement the Documents inner tab within the Health Tab shell. Displays admin-uploaded PDF documents from Firebase Storage via Laravel API (`GET /api/v2/patients/{id}/documents`). Uses `DocumentItem` component for each row. Tap opens PDF in viewer (`webview`). Includes skeleton loading, empty state, and error state.

---

## Context

- `docs/ui-design-system.md` — §§2, 3, 4–6, 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 6.4 (line 170)
- `docs/v2-ux-spec.md` — Health Tab — Documents section
- `docs/v2-decisions.md` — Health Tab Content Spec (lines 311–338), Admin-Uploaded Documents (lines 324–329)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Implement Documents inner tab content in the Health Tab shell (`lib/features/health/`)
- `ListView` of `DocumentItem` widgets — one per admin-uploaded document
- Fetch document list from `GET /api/v2/patients/{id}/documents` via Laravel proxy
- Tap on a `DocumentItem` → open PDF in webview viewer
- Skeleton loader (`AppSkeleton` — list item preset) during data fetch
- `AppEmptyState` with file illustration + "No documents yet" message
- `AppErrorState` with "Try Again" button on API failure
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Health Tab shell (UI-P6-T01)
- Records inner tab (UI-P6-T02)
- Vitals inner tab (UI-P6-T03)
- The `DocumentItem` component itself (built in Phase 1 — UI-P1-T17)
- PDF upload functionality (Laravel admin — Process 7)
- API endpoint logic changes

---

## Technical Spec

### Files to Create or Modify
- `lib/features/health/documents_tab.dart` — Create documents tab content widget
- `lib/core/widgets/document_item.dart` — Reuse existing DocumentItem component (Phase 1)

### API Endpoints
- `GET /api/v2/patients/{id}/documents` — List admin-uploaded PDFs (via Laravel)

### Data / Schema
- Document metadata: filename, upload_date, file_url (Firebase Storage link)
- Stored in Firebase Storage at `patients/{patient_id}/documents/{filename}`

### UI Components
- `DocumentItem` — Per-row component with file type icon, filename, upload date
- `AppSkeleton` — List item shimmer preset during loading
- `AppEmptyState` — File illustration + "No documents yet" message
- `AppErrorState` — Error icon + message + "Try Again" button

### Constraints
- All Plato API calls must route through Laravel proxy
- Documents fetched from Firebase Storage URLs via Laravel API
- PDF viewer: use webview to display PDF
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory
- Dark mode required

---

## Acceptance Criteria

- [ ] Documents tab renders inside Health Tab shell
- [ ] Document list fetched from `GET /api/v2/patients/{id}/documents`
- [ ] `DocumentItem` renders per row: file type icon, filename (heading3), upload date (body2, textSecondary)
- [ ] Tapping a document row opens PDF in webview viewer
- [ ] `AppSkeleton` shimmer shows during data fetch
- [ ] `AppEmptyState` shows file illustration + "No documents yet" when list is empty
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

