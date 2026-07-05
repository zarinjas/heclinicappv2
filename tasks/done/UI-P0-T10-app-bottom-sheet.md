# AppBottomSheet — Standard Bottom Sheet Wrapper

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T10 |
| Slug | app-bottom-sheet |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 10 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_bottom_sheet.dart` — a standard bottom sheet wrapper implementing the design system §19 spec. All bottom sheets in the app (doctor detail, redeem points, date picker, etc.) will use this as their container.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §19 Bottom Sheets (lines 507–519)
- `docs/ui-migration-plan.md` — Phase 0 item 0.10 (line 37)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T10, Compliance Check: §19

---

## Scope

### In Scope
- Create `lib/core/widgets/app_bottom_sheet.dart` with `AppBottomSheet` widget
- Border radius: 24px top corners only (`AppRadius.radiusXL`)
- Handle bar: 4px × 36px, `#E5E7EB` color, centered, 8px from top
- Background: `AppColors.surface` (white)
- Max height: 90% of screen height
- Overflow: scrollable content inside
- Backdrop: `rgba(0,0,0,0.4)`, tap to dismiss
- Slide-up spring animation: 350ms
- Slide-down ease animation: 280ms
- Static method to show: `AppBottomSheet.show(context, child)`

### Out of Scope
- Doctor detail sheet content (UI-P1-T02 — DoctorCard, built separately)
- Redeem points sheet (treated as content inside this wrapper)
- Any business logic or data fetching

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_bottom_sheet.dart` — AppBottomSheet wrapper

### Bottom Sheet Spec
| Property | Value |
|----------|-------|
| Border radius | 24px top corners only |
| Handle bar | 4px × 36px, `#E5E7EB`, centered, 8px from top |
| Background | `AppColors.surface` |
| Max height | 90% screen height |
| Backdrop | rgba(0,0,0,0.4), tap to dismiss |
| Open animation | Spring slide-up, 350ms |
| Close animation | Ease slide-down, 280ms |

### Widget API
```dart
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;

  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title});
}
```

### Constraints
- Use `showModalBottomSheet` from Flutter Material
- Use `AppColors` tokens
- Use `AppRadius.radiusXL` for top corners
- Use `flutter_animate` for animation if needed, or Flutter's native animation curves
- Handle dark mode surface color

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_bottom_sheet.dart` exists with `AppBottomSheet` widget
- [ ] 24px border radius applied to top corners only
- [ ] Handle bar visible: 4px × 36px, grey, centered
- [ ] White surface background in light mode, dark surface in dark mode
- [ ] Max height limited to 90% of screen
- [ ] Content area is scrollable when content exceeds height
- [ ] Dark backdrop with 40% opacity, tap dismisses
- [ ] Slide-up animation on open
- [ ] `AppBottomSheet.show()` static method works correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/core/widgets/app_bottom_sheet.dart` with `AppBottomSheet` StatelessWidget and `AppBottomSheet.show<T>()` static method. Uses `showModalBottomSheet` with isScrollControlled=true, transparent background, 40% opacity black barrier dismissible by tap. 24px radius top corners, 4x36px handle bar, dark mode surface support, optional title, 90% max height constraint.

### Files Changed
- `lib/core/widgets/app_bottom_sheet.dart` (created)

### Decisions Made During Implementation
Uses Flutter's native `showModalBottomSheet` with `isScrollControlled: true` for proper keyboard handling and max height. Barrier color set to `Color(0x66000000)` (40% black). Content wrapped in `SingleChildScrollView` via `Flexible` for overflow handling.

### Known Limitations
None.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppBottomSheet widget exists — PASS
- [x] Top corners 24px radius — PASS
- [x] Handle bar present and correct — PASS
- [x] Surface color correct in both modes — PASS
- [x] Max height 90% — PASS
- [x] Content scrollable — PASS
- [x] Backdrop tap dismisses — PASS
- [x] Open animation works — PASS
- [x] show() static method works — PASS
- [x] flutter analyze passes — PASS

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md §19 alignment: PASS — All bottom sheet properties match spec (24px top radius, 4x36px handle, white surface, 90% max height, 40% barrier, scrollable content)
- ui-migration-plan.md alignment: PASS — Phase 0 item 0.10 implemented
- Dark mode works — PASS — surfaceDark, dividerDark, textPrimaryDark used
- No hardcoded colors — PASS — All from AppColors tokens, barrier uses Color(0x66000000) per spec

### Rejection Reason
{}
