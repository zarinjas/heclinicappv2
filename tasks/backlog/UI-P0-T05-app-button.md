# AppButton — Reusable Button Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T05 |
| Slug | app-button |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 5 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_button.dart` — the single button component that replaces all `FFButtonWidget` and one-off button implementations across the app. Implements 6 variants: Primary, Secondary, Ghost, Destructive, Disabled, and WhatsApp. Supports loading state with spinner and press scale animation.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §8 Buttons (lines 186–218)
- `docs/ui-migration-plan.md` — Phase 0 item 0.5 (line 32)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T05, Compliance Check: §8
- `docs/design-system-v2.png` — visual reference for button appearance

---

## Scope

### In Scope
- Create `lib/core/widgets/app_button.dart` with `AppButton` StatelessWidget
- Support 6 variants via enum or named constructors: `AppButton.primary()`, `AppButton.secondary()`, `AppButton.ghost()`, `AppButton.destructive()`, `AppButton.whatsApp()`, plus disabled state via `onPressed: null`
- Dimensions: 52px height, full width default, border radius 24px (`AppRadius.radiusXL`)
- Typography: `AppTextStyles.button` (15px, w600)
- Padding: 24px horizontal
- Loading state: replace label with 20px white `CircularProgressIndicator` (strokeWidth 2)
- Press interaction: scale 0.97 with 150ms ease animation
- Accept `String label` and `VoidCallback? onPressed` as minimum params
- Optional `Widget? icon` for icon+label buttons with 8px spacing

### Out of Scope
- Form-wide submit validation logic
- OTP input button (specialized — separate task)
- Any business logic in the button

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_button.dart` — AppButton widget

### Button Variants
| Variant | Background | Text Color | Border |
|---------|-----------|------------|--------|
| Primary | `AppColors.accent` | white | none |
| Secondary | transparent | `AppColors.accent` | 1.5px solid accent |
| Ghost | transparent | `AppColors.accent` | none |
| Destructive | `AppColors.error` | white | none |
| WhatsApp | `#25D366` | white | none |
| Disabled | `#E5E7EB` | `#9CA3AF` | none |

### Widget API
```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
}
```

### Constraints
- Use `AppColors` tokens only — no hardcoded hex
- Use `AppTextStyles.button` for label
- Use `AppRadius.radiusXL` for border radius
- Use `flutter_animate` package for press animation (already in pubspec)
- `isLoading` replaces label, not adds to it

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_button.dart` exists with `AppButton` widget
- [ ] Primary variant renders with accent background and white text
- [ ] Secondary variant renders with transparent bg, accent border, accent text
- [ ] Ghost variant renders with transparent bg, no border, accent text
- [ ] Destructive variant renders with red background and white text
- [ ] WhatsApp variant renders with #25D366 green background
- [ ] Disabled state renders with grey bg and grey text, no interaction
- [ ] Loading state shows white spinner instead of label, button is non-interactive
- [ ] Press animation scales to 0.97 in 150ms
- [ ] All dimensions match spec: 52px height, 24px radius, 24px horizontal padding
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_button.dart`

### Decisions Made During Implementation
{}

### Known Limitations
{}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PENDING

### Criteria Results
- [ ] AppButton widget exists — PENDING
- [ ] Primary variant correct — PENDING
- [ ] Secondary variant correct — PENDING
- [ ] Ghost variant correct — PENDING
- [ ] Destructive variant correct — PENDING
- [ ] WhatsApp variant correct — PENDING
- [ ] Disabled state correct — PENDING
- [ ] Loading spinner replaces label — PENDING
- [ ] Press scale animation works — PENDING
- [ ] Dimensions match spec — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §8 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- No hardcoded colors/sizes — PENDING

### Rejection Reason
{}
