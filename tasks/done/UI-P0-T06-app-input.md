# AppInput — Reusable Input Field Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T06 |
| Slug | app-input |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 6 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_input.dart` — the single text input component that replaces all styled `TextField` and form field implementations in the app. Supports label above field, validation on blur, error/helper text below, password toggle, and all visual states from the design system §9.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §9 Input Fields (lines 221–255)
- `docs/ui-migration-plan.md` — Phase 0 item 0.6 (line 33)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T06, Compliance Check: §9

---

## Scope

### In Scope
- Create `lib/core/widgets/app_input.dart` with `AppInput` widget
- Label always above field (`AppTextStyles.label`, `AppColors.primary` color)
- Dimensions: 52px height, 12px border radius (`AppRadius.radiusMD`)
- Background: `AppColors.surface` white, filled
- Border states: rest = 1.5px solid `#E5E7EB`, focus = 1.5px solid `AppColors.accent`, error = 1.5px solid `AppColors.error`
- Padding: 16px horizontal, 14px vertical
- Placeholder: `AppTextStyles.body1`, `AppColors.textSecondary`
- Helper text below field: `AppTextStyles.body2`, `AppColors.textSecondary`
- Error text below field: `AppTextStyles.body2`, `AppColors.error`
- Validation: triggered on blur, not keystroke; error clears on valid change
- Password variant: show/hide toggle (eye icon in trailing position)
- Accept `TextEditingController`, `FocusNode`, `String? Function(String?)? validator`

### Out of Scope
- Phone number input (uses existing `phonefield` widget — migrated later)
- Date picker input (uses date picker bottom sheet — migrated later)
- OTP input (UI-P1-T10 handles this)
- Dropdown input (uses existing `nationality` widget — migrated later)
- Nationality picker (existing widget with custom data)
- Form-wide submit validation (handled by `Form` widget at screen level)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_input.dart` — AppInput widget

### Widget API
```dart
class AppInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? placeholder;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;
}
```

### Validation Behavior
- `validator` called on focus loss (blur)
- Error state shown with red border + red message below
- Error cleared immediately when input becomes valid (on change, after first error)
- No success visual needed

### Constraints
- Use `AppColors` tokens only — no hardcoded hex
- Use `AppTextStyles` for all text
- Use `AppRadius.radiusMD`
- Use `AppSpacing.space16`, `AppSpacing.space12` for padding/spacing
- Must work inside Flutter `Form` widget (expose controller)

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_input.dart` exists with `AppInput` widget
- [ ] Label renders above field in `AppTextStyles.label` + primary color
- [ ] Input is 52px height with 12px border radius
- [ ] Rest state: 1.5px solid #E5E7EB border, white background
- [ ] Focus state: border changes to accent color (#3B8DFF)
- [ ] Error state: border changes to red, error message appears below in red
- [ ] Validation triggered on blur, not on keystroke
- [ ] Error clears on valid input change after first error
- [ ] Password variant shows/hides toggle icon
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/core/widgets/app_input.dart` with `AppInput` StatefulWidget. Implements label-above-field layout, validation on blur, error clear on valid change, password show/hide toggle, dark mode support via brightness check, and all design system tokens. All border states (rest/focus/error) use AppColors tokens. No hardcoded hex values.

### Files Changed
- `lib/core/widgets/app_input.dart` (created)

### Decisions Made During Implementation
Dark mode awareness uses `Theme.of(context).brightness` to switch surface/text/border colors per design system §24. Validation triggers on blur (not keystroke), error clears on valid change after first error. Password toggle defaults to obscured, respects disabled state. Multiline variant uses null height constraint for natural expansion.

### Known Limitations
None.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppInput widget exists — PASS
- [x] Label above field correct — PASS
- [x] Dimensions correct (52px, 12px radius) — PASS
- [x] Rest border state correct — PASS
- [x] Focus border state correct — PASS
- [x] Error border + message correct — PASS
- [x] Blur validation works — PASS
- [x] Error clears on valid change — PASS
- [x] Password toggle works — PASS
- [x] flutter analyze passes — PASS

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md §9 alignment: PASS — All input field properties match spec exactly (52px height, 12px radius, 1.5px borders, label above, blur validation, error recovery)
- ui-migration-plan.md alignment: PASS — Phase 0 item 0.6 implemented
- No hardcoded colors/sizes — PASS — All values use AppColors, AppTextStyles, AppSpacing, AppRadius tokens. No magic numbers.
- Dark mode support — PASS — Surface/text/border colors switch via brightness check per §24
- Skeleton/empty/error states — N/A (form input component, not a list/content screen)

### Rejection Reason
{}
