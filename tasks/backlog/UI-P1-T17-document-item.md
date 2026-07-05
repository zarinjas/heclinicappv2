# DocumentItem Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T17 |
| Slug | document-item |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 17 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `DocumentItem` reusable component for displaying documents in the Health tab (Documents inner tab). Displays document name, type, upload date, and file size. Tap opens PDF viewer.

---

## Context

- `docs/ui-design-system.md` — §7 (Icons), §10 (Cards)
- `docs/ui-migration-plan.md` — Phase 1, §1.17 (DocumentItem), Phase 6 (Health Tab — Documents inner tab)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/document_item.dart` — new file
- Leading: document type icon 40px circle with accent-tinted bg (pdf= picture_as_pdf, image= image, other= insert_drive_file)
- Document name: `heading3` style, 1 line with ellipsis
- Document type label: `body2`, `textSecondary` (e.g., "PDF", "Lab Report", "X-Ray")
- Metadata row: upload date + file size, `body2`, `textSecondary`
- Trailing: chevron right icon
- Tap callback → opens PDF via webview or external viewer
- Skeleton loader: 40px circle + 3 text bars

### Out of Scope
- Document data fetching (data passed via constructor)
- PDF rendering/viewer logic (handled by parent via callback)
- File download (separate service)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/document_item.dart` — new file

### Design Spec
- Leading icon: 40px circle, accent-tinted bg, file-type icon
- Title: heading3
- Type label: body2, textSecondary
- Metadata: body2, textSecondary, formatted date + file size
- Trailing: Icons.chevron_right
- Card: uses AppCard base

### Constraints
- Design tokens only
- Dark mode support
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Leading icon renders as 40px circle with accent-tinted background; PDF icon for PDFs, image icon for images, generic file icon for other types
- [ ] Document name displays in heading3 style, single line with ellipsis overflow
- [ ] Document type label displays in body2/textSecondary (e.g., "PDF", "Lab Report")
- [ ] Metadata row shows formatted upload date and file size in body2/textSecondary
- [ ] Trailing chevron (Icons.chevron_right) renders on right side
- [ ] Tap callback fires for PDF viewing
- [ ] Skeleton loader renders shimmer with 40px circle + text bars matching layout
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
