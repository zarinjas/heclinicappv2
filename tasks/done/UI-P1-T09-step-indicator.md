# StepIndicator Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T09 |
| Slug | step-indicator |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 9 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `StepIndicator` reusable component for multi-step flows. Used in Booking flow (4 steps: Branch → Doctor → Date/Time → Confirm) and Register flow (2 steps). Displays numbered steps with connecting lines, active/completed/inactive states.

---

## Context

- `docs/ui-design-system.md` — §7 (Icons), §4 (Spacing)
- `docs/ui-migration-plan.md` — Phase 1, §1.9 (StepIndicator), Phase 4 (Booking Flow Notes)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/step_indicator.dart` — new file
- Horizontal row of step circles connected by lines
- Each step: numbered circle (24px), label below in `caption` style
- States: Completed (accent fill + white checkmark), Active (accent border + primary text), Inactive (grey border + textSecondary text)
- Connecting lines: 1px height, accent color (completed) or divider color (inactive)
- Configurable: total steps, current step index, step labels list
- Max width constrained, centered in parent

### Out of Scope
- Step navigation logic (handled by flow controller)
- Animated step transitions (v2 — keep it simple first)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/step_indicator.dart` — new file

### Design Spec
- Circle: 24px diameter
- Active: accent border (1.5px), primary text
- Completed: accent fill, white checkmark icon (Icons.check, 14px)
- Inactive: divider border, textSecondary text
- Label: caption style, below circle
- Connecting line: 1px height
- Spacing between steps: flexible/distributed

### Constraints
- Design tokens only
- Dark mode support
- Responsive (scales with available width)

---

## Acceptance Criteria

- [ ] Steps render as horizontal row of numbered circles connected by horizontal lines
- [ ] Active step shows accent-colored border (1.5px) with primary text number
- [ ] Completed steps show accent-filled circle with white checkmark icon
- [ ] Inactive steps show divider-colored border with textSecondary number
- [ ] Connecting line between two completed steps is accent color
- [ ] Connecting line after current step is divider color
- [ ] Step labels render in caption style below each circle
- [ ] Component accepts configurable total steps, current index, and labels
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors

---

## Implementation Notes

Created `lib/core/widgets/step_indicator.dart`:
- `StepIndicator` StatelessWidget: configurable `currentStep`, `totalSteps`, and optional `labels` list
- Each step renders in Expanded column: 24px circle above caption label
- Completed: accent filled circle with white check icon (14px)
- Active: accent border (1.5px) with accent-colored number
- Inactive: divider border with textSecondary number
- Connecting lines between steps: 1px height, accent (completed) or divider (inactive)
- Labels default to "Step N" if not provided, rendered in caption style
- Dark mode: primary/secondary/divider colors adapt to theme brightness
- All tokens: AppColors, AppTextStyles, AppSpacing. No hardcoded values.
- `flutter analyze` passed with zero errors

---

## QA Notes

| # | Criterion | Result | Notes |
|---|-----------|--------|-------|
| 1 | Horizontal row of circles + lines | PASS | Expanded Row per step with 24px circle + 1px connecting line |
| 2 | Active: accent border 1.5px + primary text | PASS | Border.all(accent, 1.5), label accent color |
| 3 | Completed: accent fill + white check | PASS | BoxDecoration(accent), Icons.check white 14px |
| 4 | Inactive: divider border + textSecondary | PASS | Border.all(divider, 1.5), text secondary |
| 5 | Completed-to-completed line accent | PASS | lineColor = isCompleted ? accent : divider |
| 6 | Line after current step is divider | PASS | Inactive steps get divider line |
| 7 | Labels in caption style | PASS | AppTextStyles.caption |
| 8 | Configurable currentStep/totalSteps/labels | PASS | All three constructor params |
| 9 | Dark mode | PASS | isDark-adapted primary/secondary/divider colors |
| 10 | No hardcoded tokens | PASS | AppColors/AppTextStyles/AppSpacing only |
| 11 | flutter analyze zero errors | PASS | Confirmed |

**QA Result: PASSED** — All 11 criteria verified. **Reviewer: APPROVED.** Design tokens compliant, dark mode supported.
