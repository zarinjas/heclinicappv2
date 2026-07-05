# AppToast — Toast / Snackbar Utility

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T12 |
| Slug | app-toast |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 12 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_toast.dart` implementing 4 toast/snackbar types from the design system §18: Success, Error, Warning, and Info. Positioned at bottom of screen above the nav bar with auto-dismiss.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §18 Toast / Snackbar (lines 489–504)
- `docs/ui-migration-plan.md` — Phase 0 item 0.12 (line 39)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T12, Compliance Check: §18

---

## Scope

### In Scope
- Create `lib/core/widgets/app_toast.dart` with `AppToast` utility
- 4 types:
  - Success: `#27F5A3` left bar, `check_circle_outline` icon
  - Error: `#F54636` left bar, `error_outline` icon
  - Warning: `#F5A623` left bar, `warning_amber` icon
  - Info: `#131C3C` background, white text, `info_outline` icon
- Position: bottom of screen, above nav bar
- Shape: pill/rounded, `AppRadius.radiusXL` (24px)
- Auto-dismiss: 3 seconds
- Max width: screen width − 32px
- Animation: slide up + fade in, 250ms
- Static show methods: `AppToast.success()`, `AppToast.error()`, `AppToast.warning()`, `AppToast.info()`

### Out of Scope
- Inline form validation messages (those are AppInput responsibility)
- Persistent banner notifications (OfflineBanner is UI-P1-T18)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_toast.dart` — AppToast utility

### Toast Types
| Type | Accent / BG | Icon |
|------|-------------|------|
| Success | `#27F5A3` left bar | `check_circle_outline` |
| Error | `#F54636` left bar | `error_outline` |
| Warning | `#F5A623` left bar | `warning_amber` |
| Info | `#131C3C` bg, white text | `info_outline` |

### Widget API
```dart
class AppToast {
  static void success(BuildContext context, String message);
  static void error(BuildContext context, String message);
  static void warning(BuildContext context, String message);
  static void info(BuildContext context, String message);
}
```

### Constraints
- Use `ScaffoldMessenger.of(context).showSnackBar()` or `Overlay` for custom positioning
- Must account for bottom nav bar height (64px + safe area) when positioning
- Use `AppTextStyles.body1` for message text
- Use `AppRadius.radiusXL` for pill shape
- Use Material Icons

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_toast.dart` exists with `AppToast` class
- [ ] Success toast renders with green left bar and check icon
- [ ] Error toast renders with red left bar and error icon
- [ ] Warning toast renders with orange left bar and warning icon
- [ ] Info toast renders with primary background, white text, info icon
- [ ] Positioned at bottom of screen above nav bar
- [ ] Pill shape with 24px border radius
- [ ] Auto-dismisses after 3 seconds
- [ ] Slide-up + fade-in animation on appear
- [ ] Max width = screen width − 32px
- [ ] All 4 static methods (`success`, `error`, `warning`, `info`) work
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_toast.dart`

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
- [ ] AppToast class exists — PENDING
- [ ] Success toast correct — PENDING
- [ ] Error toast correct — PENDING
- [ ] Warning toast correct — PENDING
- [ ] Info toast correct — PENDING
- [ ] Positioned above nav bar — PENDING
- [ ] Pill shape with 24px radius — PENDING
- [ ] Auto-dismiss 3 seconds — PENDING
- [ ] Animation works — PENDING
- [ ] Max width correct — PENDING
- [ ] All 4 static methods work — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §18 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
