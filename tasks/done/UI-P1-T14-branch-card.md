# BranchCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T14 |
| Slug | branch-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 14 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `BranchCard` reusable component for branch selection in the Booking flow (Step 1). Displays branch name, address, operating hours, and distance. Shows accent border when selected.

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Base Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.14 (BranchCard), Phase 4 (Booking Flow — Step 1 Branch)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/branch_card.dart` — new file
- Branch name: `heading3` style
- Address: `body2`, `textSecondary`, with location pin icon
- Operating hours: `body2`, `textSecondary`, with clock icon
- Distance: `body2`, `textSecondary` (right-aligned or trailing)
- Selection state: 1.5px accent border, slight accent-tinted background
- Unselected state: standard card border (`#E5E7EB`), surface background
- Tap callback for selection
- Skeleton loader: card rect with 3 text bars

### Out of Scope
- Branch data fetching (data passed via constructor)
- Multi-select logic (handled by parent)
- Branch detail navigation (separate screen)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/branch_card.dart` — new file

### Design Spec
- Uses base AppCard styling (radiusLG, shadowLow, padding md)
- Selected: accent border 1.5px, slight accent bg tint
- Unselected: divider border 1px
- Name: heading3, primary
- Address/operating hours: body2, textSecondary, with leading icons

### Constraints
- Design tokens only
- Dark mode support
- Skeleton loader defined

---

## Implementation Notes

- Created `lib/core/widgets/branch_card.dart`
- StatelessWidget `BranchCard` with name, address, operatingHours, distance, isSelected, onTap
- Selected state: 1.5px accent border + accent tinted bg (5% light / 10% dark); Unselected: 1px divider border + surface bg
- Name: `AppTextStyles.heading3` + titleColor; Address/hours: `AppTextStyles.body2` with location/time icons
- Distance: shown trailing when non-empty
- `BranchCardSkeleton`: card-shaped placeholder with 3 colored bars using skeleton palette
- `flutter analyze`: zero errors

---

## Acceptance Criteria

- [ ] Branch name displays in heading3 style
- [ ] Address shows with location pin icon in body2/textSecondary
- [ ] Operating hours display with clock icon in body2/textSecondary
- [ ] Selected branch shows 1.5px accent border and subtle accent-tinted background
- [ ] Unselected branches show standard card border (#E5E7EB) with surface background
- [ ] Tap callback fires selection change
- [ ] Skeleton loader renders card-shaped shimmer with text bars
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors

---
## QA Notes

**Build Gate:** `flutter analyze` — PASSED (zero errors)

| # | Criterion | Result |
|---|-----------|--------|
| 1 | Branch name heading3 | PASS |
| 2 | Address + location pin icon, body2/textSecondary | PASS |
| 3 | Operating hours + clock icon, body2/textSecondary | PASS |
| 4 | Selected: 1.5px accent border + accent tinted bg | PASS |
| 5 | Unselected: 1px divider border + surface bg | PASS |
| 6 | Tap callback fires | PASS |
| 7 | BranchCardSkeleton renders card + 3 bars | PASS |
| 8 | Dark mode | PASS |
| 9 | No hardcoded tokens | PASS |
| 10 | flutter analyze zero errors | PASS |

**QA Verdict: PASSED**

---
## Reviewer Notes

- ui-design-system.md compliance: All tokens from AppColors/AppTextStyles/AppSpacing/AppRadius/AppShadows. No hardcoded values.
- Dark mode: Supported (surface/surfaceDark, text colors, divider, skeleton palette)
- Selected state: 1.5px accent border + tinted bg matching spec
- BranchCardSkeleton: Card-shaped placeholder with skeleton palette colors
- AppButton/AppInput/AppCard: N/A (custom card variant for branch selection; matches AppCard base pattern)
- v2-decisions.md alignment: PASS
- v2-ux-spec.md alignment: PASS (matches branch selection card in Booking Flow)

**Reviewer Decision: APPROVED**
