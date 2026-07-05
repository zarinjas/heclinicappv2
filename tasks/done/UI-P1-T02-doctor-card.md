# DoctorCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T02 |
| Slug | doctor-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `DoctorCard` reusable component for displaying doctor profiles. Used on Home screen (horizontal scroll), Doctor list screen, and Booking Step 2 (doctor selection). Two variants: horizontal card (compact for scrollable lists) and vertical card (full for selection grids/lists).

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Doctor Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.2 (DoctorCard)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/doctor_card.dart` — new file
- Horizontal variant: 80px circle avatar, centered name (heading3), centered specialty (body2/textSecondary)
- Vertical variant: larger layout for selection screens with photo + name + specialty
- Star rating row with star icon + rating text (caption), shown when data present
- "Available Today" chip in success color when doctor is available
- Photo from CMS URL, fallback to placeholder avatar
- Skeleton loader for both variants

### Out of Scope
- Doctor data fetching (data passed as constructor param)
- Doctor Detail bottom sheet (separate component)
- Rating API logic

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/doctor_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Horizontal: 80px circle avatar, name heading3 centered, specialty body2 textSecondary centered
- Star icon + rating (caption) when available
- "Available Today" chip in success color
- Vertical: Row layout with photo + name/specialty + chevron

---

## Acceptance Criteria

- [x] Horizontal variant renders 80px circle avatar, centered name (heading3), centered specialty (body2/textSecondary) — PASS
- [x] Star rating row with star icon and rating text (caption) renders when rating data present; hidden when absent — PASS
- [x] "Available Today" chip renders with success color when doctor is available — PASS
- [x] Vertical variant shows photo, name, specialty, and chevron indicator — PASS
- [x] Photo loads from URL; placeholder avatar shown when photo is null/loading — PASS
- [x] Skeleton loader with circle + text bars matching dimensions — PASS
- [x] Tap callback fires correctly — PASS
- [x] Dark mode renders with correct surface colors — PASS
- [x] No hardcoded tokens — all design tokens from shared constants — PASS
- [x] flutter analyze returns zero errors — PASS

---

## Implementation Notes

### What Was Done
Built the `DoctorCard` component with two variants: horizontal (compact, 160px wide for scrollable lists) and vertical (full-width Row card for selection lists). Includes doctor avatar, name, specialty, star rating (optional), and "Available Today" chip using `AppChip`.

### Files Changed
- `lib/core/widgets/doctor_card.dart` — new file (created)

### Decisions Made During Implementation
- Used `DoctorCardVariant` enum to switch between horizontal and vertical layouts
- Horizontal card constrained to 160px width with Column layout; vertical uses Row with expanded text
- Rating uses `Icons.star` with `AppColors.warning` color per design system
- "Available Today" chip reuses `AppChip` with `StatusChipVariant.confirmed`
- Vertical variant has chevron_right icon when onTap is provided

### Known Limitations
- Skeleton uses static colored containers rather than animated shimmer
- Doctor bio excerpt not in vertical variant (belongs in detail sheet)

---

## QA Notes

### Result: PASSED

### Criteria Results
All 10 acceptance criteria verified against implementation. Build gate: flutter analyze returns zero errors.

---

## Reviewer Notes

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES
- ui-design-system.md alignment: YES — §10 Doctor Card spec matched (80px avatar, heading3 name, rating, "Available Today" chip)
- No hardcoded tokens: PASS
- Dark mode supported: PASS
- Skeleton defined: PASS
- AppChip used for status: PASS
