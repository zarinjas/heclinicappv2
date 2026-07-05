# HealthRecordCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T06 |
| Slug | health-record-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `HealthRecordCard` reusable component for displaying clinical records in the Health tab. Used in Records inner tab for notes, letters, lab results, and MCs. Displays type icon, record title, doctor name subtitle, and date.

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Health Record Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.6 (HealthRecordCard), Phase 6 (Health Tab — Records inner tab)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/health_record_card.dart` — new file
- Leading type icon: 40px circle with accent-tinted background, icon varies by record type (note=description, letter=mail, lab=science, MC=assignment)
- Title: `heading3`, record title/type name
- Subtitle: doctor name, `body2`, `textSecondary`
- Trailing: formatted date, `body2`, `textSecondary`
- Tap callback for navigation to record detail/viewer
- Skeleton loader: 40px circle + 3 text bars
- Support all record types: Notes, Letters, Lab Results, MC

### Out of Scope
- Record data fetching (data passed via constructor)
- PDF/rich text rendering (handled by detail screen)
- Record type filter logic (handled by parent)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/health_record_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Leading icon: 40px circle bg, accent tint, type-specific icon
- Title: heading3
- Subtitle: body2, textSecondary
- Trailing: body2, textSecondary, formatted date
- All inside base card structure from AppCard

### Constraints
- Design tokens only
- Dark mode support
- Skeleton loader defined
- Presentational only

---

## Acceptance Criteria

- [ ] Leading icon renders as 40px circle with accent-tinted background; correct icon per record type (note/letter/lab/MC)
- [ ] Record title displays in heading3 style
- [ ] Doctor name subtitle displays in body2/textSecondary
- [ ] Trailing date displays formatted in body2/textSecondary
- [ ] Tap callback fires correctly
- [ ] Skeleton loader renders shimmer with 40px circle + 3 text bars matching layout
- [ ] Dark mode renders with correct surface colors and icon backgrounds
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
