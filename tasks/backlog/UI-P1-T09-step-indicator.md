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
| Status | BACKLOG |
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
