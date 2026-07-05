# AppDialog — Modal Dialog Component (4 Variants)

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T11 |
| Slug | app-dialog |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 11 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_dialog.dart` implementing all 4 dialog/modal variants defined in the design system §20: Confirmation, Success, Loading, and Redemption Code. These replace 24+ one-off modal widgets currently in the `component/` directory.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §20 Dialogs / Modals (lines 522–560)
- `docs/ui-migration-plan.md` — Phase 0 item 0.11 (line 38), Phase 11 (Dialog Consolidation, lines 265–278)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T11, Compliance Check: §20

---

## Scope

### In Scope
- Create `lib/core/widgets/app_dialog.dart` with `AppDialog` widget
- **Confirmation variant:**
  - Warning/question icon (48px, `warning` color)
  - Title: "Are you sure?" (`heading3`, centered)
  - Body message: consequence text (`body1`, `textSecondary`, centered)
  - Actions: Cancel (ghost) + Confirm (destructive or primary)
- **Success variant:**
  - Animated checkmark (64px, `accent` color)
  - Title: "Done!" (`heading3`, centered)
  - Body: context message (`body1`, `textSecondary`, centered)
  - CTA: Primary button full width
- **Loading variant:**
  - `CircularProgressIndicator` (accent, 32px)
  - Label: "Please wait…" (`body1`, `textSecondary`)
  - Blocks all interaction (barrierDismissible: false)
- **Redemption Code variant:**
  - Animated checkmark (64px, `accent`)
  - Title: "Your Redemption Code" (`heading3`, centered)
  - Code block: large monospace, accent border, `radiusMD`
  - Discount text: "RM X.XX discount" (`heading2`, accent, centered)
  - Instructions: `body2`, `textSecondary`, centered
  - Done button (primary)
- All dialogs: `radiusXL` (24px), white surface background
- Static show methods: `AppDialog.confirm()`, `AppDialog.success()`, `AppDialog.loading()`, `AppDialog.redemptionCode()`

### Out of Scope
- Appointment-specific dialog logic (uses AppDialog.confirm with destructive variant)
- Booking confirmation dialog content
- Actual redemption code generation logic

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_dialog.dart` — AppDialog widget

### Dialog Variants Summary
| Variant | Icon | Title | Actions |
|---------|------|-------|---------|
| Confirmation | Warning 48px, warning color | "Are you sure?" | Cancel ghost + Confirm |
| Success | Animated checkmark 64px, accent | "Done!" | Primary button |
| Loading | Spinner 32px, accent | "Please wait…" | None (auto-dismiss or programmatic) |
| Redemption Code | Checkmark 64px, accent | "Your Redemption Code" | Done primary |

### Widget API
```dart
class AppDialog extends StatelessWidget {
  static Future<bool?> confirm(BuildContext context, {String title, String message, String confirmLabel, bool isDestructive});
  static Future<void> success(BuildContext context, {String title, String message, String buttonLabel, VoidCallback? onDone});
  static void loading(BuildContext context, {String message});
  static void hideLoading(BuildContext context);
  static void redemptionCode(BuildContext context, {String code, double discount, String instructions});
}
```

### Constraints
- Use `showDialog` from Flutter Material
- Use `AppColors`, `AppTextStyles`, `AppRadius` tokens
- Use `flutter_animate` for checkmark animation
- Dark mode: surface and text colors must adapt

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_dialog.dart` exists with `AppDialog` widget
- [ ] Confirmation dialog renders with warning icon, title, message, Cancel + Confirm buttons
- [ ] Confirm button supports destructive (red) or primary (accent) style
- [ ] Success dialog renders with animated checkmark, "Done!" title, primary button
- [ ] Loading dialog renders spinner + "Please wait…", blocks background interaction
- [ ] Redemption Code dialog renders code block, discount text, Done button
- [ ] All dialogs have 24px border radius and white surface bg
- [ ] Dark mode: surface and text colors adapt correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_dialog.dart`

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
- [ ] AppDialog widget exists — PENDING
- [ ] Confirmation variant correct — PENDING
- [ ] Destructive vs primary confirm toggle — PENDING
- [ ] Success variant with checkmark — PENDING
- [ ] Loading variant blocks interaction — PENDING
- [ ] Redemption code variant correct — PENDING
- [ ] 24px radius on all dialogs — PENDING
- [ ] Dark mode adapts — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §20 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- Dark mode works — PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
