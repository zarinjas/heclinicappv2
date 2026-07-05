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
| Status | IN-REVIEW |
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

---

## Implementation Notes

Created `lib/core/widgets/document_item.dart`:
- `DocumentFileType` enum: pdf, image, other with mapped Material Icons
- `DocumentItem` widget: AppCard wrapper with Row layout (leading icon | text column | chevron)
- Leading: 40px circle Container with accent-tinted bg (20/30 alpha dark/light) + file-type icon
- Name: AppTextStyles.heading3, maxLines: 1, ellipsis
- Type label: AppTextStyles.body2 with textSecondary coloring
- Metadata: uploadedAt + formatted file size (B/KB/MB), body2 + textSecondary
- Trailing: Icons.chevron_right, 20px
- onTap callback via AppCard.onTap
- Dark mode: all text colors, icon bg alpha adapt
- Skeleton: DocumentItemSkeleton with 40px circle + 3 text bars + chevron bar
- All tokens: AppColors, AppTextStyles, AppSpacing, AppRadius

## QA Notes

QA=PASSED
- Leading icon: 40px circle, accent-tinted bg, correct icons per file type
- Name: heading3 style, single line, ellipsis overflow
- Type label: body2/textSecondary
- Metadata: formatted date + size in body2/textSecondary
- Trailing: chevron_right icon present
- onTap callback via AppCard onTap parameter
- Skeleton: DocumentItemSkeleton with circle + 3 bars matching layout
- Dark mode: isDark checks for colors
- All tokens from AppColors, AppTextStyles, AppSpacing, AppRadius
- flutter analyze: zero errors

## Reviewer Notes

APPROVED
- All design tokens used — no hardcoded hex or sizes
- AppCard wrapper with onTap for press interaction
- Dark mode supported throughout
- Skeleton, empty, and error states — skeleton implemented per spec
- File size formatting (B/KB/MB) included
- Chevron trailing icon matches design spec
- Design system compliant
