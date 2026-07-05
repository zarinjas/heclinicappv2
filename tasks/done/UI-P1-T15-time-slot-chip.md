# TimeSlotChip Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T15 |
| Slug | time-slot-chip |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 15 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `TimeSlotChip` reusable component for time slot selection in the Booking flow (Step 3 — Date & Time). Displays individual time slots as selectable chips with selected/unselected states.

---

## Context

- `docs/ui-design-system.md` — §11 (Chips — Filter Chips), §4 (Spacing)
- `docs/ui-migration-plan.md` — Phase 1, §1.15 (TimeSlotChip), Phase 4 (Booking Flow — Step 3 Date/Time)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/time_slot_chip.dart` — new file
- Chip displaying time in format "HH:MM AM/PM" (e.g., "09:30 AM")
- Selected state: accent background (`AppColors.accent`), white text, `label` style
- Unselected state: `#F3F4F6` background, `#6B7280` text, `label` style
- Dimensions: height 40px, border radius `AppRadius.sm` (8px), horizontal padding 16px
- Tap callback for selection
- Pressed scale animation (0.97)

### Out of Scope
- Time slot availability logic (passed via constructor — parent filters)
- Grid layout of multiple chips (handled by parent `Wrap` or `GridView`)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/time_slot_chip.dart` — new file

### Design Spec
- Height: 40px (slightly taller than filter chip for tap target)
- Radius: `AppRadius.sm` (8px)
- Selected: `AppColors.accent` bg, white text
- Unselected: `#F3F4F6` bg, `#6B7280` text
- Font: `AppTextStyles.label`

### Constraints
- Design tokens only
- Dark mode: unselected bg adapts to dark surface variant
- Minimum touch target 44×40px

---

## Implementation Notes

- Created `lib/core/widgets/time_slot_chip.dart`
- StatefulWidget with AnimationController for press-scale animation (0.97, 150ms)
- Selected: `AppColors.accent` bg, white text; Unselected: `AppColors.chipFilterDefaultBg` / `surfaceDark` bg, `AppColors.chipFilterDefaultText` text
- Height: 40px, radius: `AppRadius.radiusSM` (8px), horizontal padding: `AppSpacing.space16`
- `AnimatedContainer` for smooth color transitions (200ms); `Transform.scale` for press feedback
- `AppTextStyles.label` for text
- Dark mode: unselected bg switches to `surfaceDark`
- `flutter analyze`: zero errors

---

## Acceptance Criteria

- [ ] Time slot displays formatted as "HH:MM AM/PM" using label text style
- [ ] Selected chip shows accent background with white text
- [ ] Unselected chip shows #F3F4F6 background with #6B7280 text
- [ ] Chip dimensions: height 40px, 8px border radius, 16px horizontal padding
- [ ] Tap callback fires on press
- [ ] Pressed state scales to 0.97 with animation
- [ ] Dark mode: unselected background adapts to dark variant
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors

---
## QA Notes

**Build Gate:** `flutter analyze` — PASSED (zero errors)

| # | Criterion | Result |
|---|-----------|--------|
| 1 | Time formatted HH:MM AM/PM, label style | PASS |
| 2 | Selected: accent bg + white text | PASS |
| 3 | Unselected: chipFilterDefaultBg + chipFilterDefaultText | PASS |
| 4 | 40px height, 8px radius, 16px h-padding | PASS |
| 5 | Tap callback fires | PASS |
| 6 | Press scale 0.97 animation | PASS |
| 7 | Dark mode unselected bg adapts | PASS |
| 8 | No hardcoded tokens | PASS |
| 9 | flutter analyze zero errors | PASS |

**QA Verdict: PASSED**

---
## Reviewer Notes

- ui-design-system.md §11 compliance: Chip pattern matches filter chip spec
- All tokens from AppColors/AppTextStyles/AppSpacing/AppRadius. No hardcoded values.
- Dark mode: Supported (unselected bg→surfaceDark)
- Press-scale animation: 0.97, 150ms via AnimationController
- v2-decisions.md alignment: PASS
- v2-ux-spec.md alignment: PASS (matches time slot chip in Booking Flow Step 3)

**Reviewer Decision: APPROVED**
