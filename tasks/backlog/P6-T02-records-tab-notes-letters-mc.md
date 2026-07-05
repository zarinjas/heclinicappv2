# Records Tab — Clinical Notes, Letters, MC, Filter Chips

## Header

| Field | Value |
|-------|-------|
| Task ID | P6-T02 |
| Slug | records-tab-notes-letters-mc |
| Process | 6 — Health Tab |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | TBD |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P6-T01 |
| Blocked Reason | N/A |

---

## Description

Implement the Records inner tab of the Health Tab scaffold. This tab displays clinical notes, letters, and medical certificates (MC) fetched from Plato API endpoints. A horizontal filter chip row at the top allows the patient to filter records by type: **All**, **Notes**, **Letters**, and **MC**. Each list item shows a type icon, title/subject, date, and doctor/author name. The existing `GetReportCall`, `LetterCall`, and `GetMedicalCertificateCall` API call classes already exist in `lib/backend/api_requests/api_calls.dart` and must be used.

Per `docs/v2-decisions.md` Process 6 Step 2 and `docs/v2-ux-spec.md` Records Tab specification.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 6 Step 2 (line 87), Health Tab Inner Tabs table (line 331)
- `docs/v2-ux-spec.md` — Records Tab section (line 578-582), Design System section (line 9), Component Library (line 77)
- `docs/CODEBASE.md` — Section 3: backend/api_requests/api_calls.dart
- `lib/backend/api_requests/api_calls.dart` — GetReportCall (line 1113), LetterCall (line 1202), GetMedicalCertificateCall (line 509)

---

## Scope

> Exact deliverables for this task.

### In Scope
- Filter chip row: All (default selected), Notes, Letters, MC — horizontal scroll, using V2 chip styling (rounded pills, accent fill when selected)
- Fetch clinical notes via `GetReportCall.call(patientId: FFAppState().idplato)` when "All" or "Notes" filter selected
- Fetch letters via `LetterCall.call(patientId: FFAppState().idplato)` when "All" or "Letters" filter selected
- Fetch MC via `GetMedicalCertificateCall()` when "All" or "MC" filter selected
- Combine all data types when "All" filter is active, deduplicated and sorted by date (newest first)
- Each record card: leading icon (Icons.description for notes, Icons.mail_outline for letters, Icons.assignment_outlined for MC), title (note text first 80 chars / letter subject / MC filename), date formatted, author/doctor name
- Loading: 4× `SkeletonListTile` while fetching
- Empty state: `EmptyStateWidget` with icon `Icons.article_outlined`, title "No records found", subtitle "Your clinical notes will appear here"
- Error state: `ErrorStateWidget` with retry callback
- Tap a record to open detail (for notes: use existing `AlertReportWidget` already at `lib/component/alert_report/alert_report_widget.dart`; for letters: show HTML content in bottom sheet; for MC: use WebViewX+ to display PDF via URL)

### Out of Scope
- Vitals tab or Documents tab content
- Adding new API endpoints to PlatomeApiGroup
- Modifying the Health tab scaffold (done in P6-T01)
- Pagination / modified_since (deferred to P6-T05)

---

## Technical Spec

> Key implementation details.

### Files to Modify
- `lib/front_page/reports/reports_widget.dart` — Implement Records tab body with filter chips + dynamic list
- `lib/front_page/reports/reports_model.dart` — Add model fields: selectedFilter (enum/string), recordsList, isLoading, errorMessage

### Existing API Call Classes (Use These, Do Not Create New Ones)
- `GetReportCall.call(patientId:)` — returns note[], time[], kategori[], author[]
- `LetterCall.call(patientId:)` — returns subject[], html[], tgl[], author[]
- `GetMedicalCertificateCall()` — returns path[], tgl[], data[] (instanced, not static)

### Data Model (Create a Simple Data Class)
```dart
enum RecordType { note, letter, mc }
enum FilterType { all, notes, letters, mc }

class HealthRecord {
  final RecordType type;
  final String title;
  final String date;
  final String author;
  final String? detailData; // full note text, letter HTML, or MC path
}
```

### UI Components
- Filter chips: `ChoiceChip` styled with V2 design — unselected: `AppColors.divider` border, selected: `AppColors.accent` background with white text, border radius `AppRadius.full` (9999px), padding horizontal 16px
- Record card: `Card` with `AppColors.surface` background, `AppRadius.lg` (16px) radius, `AppSpacing.md` (16px) padding, shadow: low
- Card leading: 40px circle with `AppColors.primary` background, white icon
- Card title: GoogleFonts.plusJakartaSans 14px weight 600
- Card subtitle: GoogleFonts.plusJakartaSans 12px weight 400, AppColors.textSecondary
- Loading: `SkeletonListTile` component
- Empty: `EmptyStateWidget` component
- Error: `ErrorStateWidget` component

### Constraints
- Must route all Plato API calls through `EnvConfig.platomBaseUrl` (already handled by existing call classes)
- Use `FFAppState().tokenauth` for Authorization header (already in existing call classes)
- Use `FFAppState().idplato` for patient ID
- All text uses GoogleFonts.plusJakartaSans

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Records tab loads and displays filter chips: All (selected by default), Notes, Letters, MC
- [ ] Tapping a filter chip re-fetches and filters the list correctly (All shows combined data, Notes shows only notes, etc.)
- [ ] Each record card shows a type-distinct icon, title, date, and author
- [ ] Skeleton loaders appear while data is fetching (4 items)
- [ ] Empty state displays when no records exist for the selected filter
- [ ] Error state displays with retry button on fetch failure
- [ ] Tapping a note record opens the existing AlertReportWidget with the note content
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled by Developer after implementation.

### What Was Done
{to be filled}

### Files Changed
{to be filled}

### Decisions Made During Implementation
{to be filled}

### Known Limitations
{to be filled}

---

## QA Notes

> Filled by QA after verification.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] Filter chips render and are interactive — {PASS / FAIL} — {note}
- [ ] Filter switching re-fetches and filters correctly — {PASS / FAIL} — {note}
- [ ] Record cards show correct icon, title, date, author — {PASS / FAIL} — {note}
- [ ] Skeleton loaders appear while loading — {PASS / FAIL} — {note}
- [ ] Empty state displays when no records — {PASS / FAIL} — {note}
- [ ] Error state with retry works — {PASS / FAIL} — {note}
- [ ] Tapping note opens AlertReportWidget — {PASS / FAIL} — {note}
- [ ] flutter analyze zero errors — {PASS / FAIL} — {note}

### Failure Details
{to be filled if failed}

---

## Reviewer Notes

> Filled by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}

### Rejection Reason
{to be filled if rejected}
