# AppErrorState — Error State Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T14 |
| Slug | app-error-state |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 14 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_error_state.dart` — the error state component used when data fetching fails. Every list, tab, and page must have a defined error state. This component provides: error icon + title + context-specific message + "Try Again" CTA.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §17 Error States (lines 475–484)
- `docs/ui-migration-plan.md` — Phase 0 item 0.14 (line 41)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T14, Compliance Check: §17

---

## Scope

### In Scope
- Create `lib/core/widgets/app_error_state.dart` with `AppErrorState` widget
- Layout: centered column
  - Icon: `error_outline`, 40px, `AppColors.error` color
  - Title: "Something went wrong" (`heading3`) — configurable
  - Subtitle: context-specific message (`body1`, `textSecondary`) — configurable
  - CTA: "Try Again" ghost button with `onRetry` callback — optional
- Support custom title and subtitle message
- Support optional retry callback (if null, hide button)

### Out of Scope
- Empty state (UI-P0-T13 handles that separately)
- Network connectivity detection (OfflineBanner is UI-P1-T18)
- Automatic retry logic (each screen manages retry behavior)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_error_state.dart` — AppErrorState widget

### Error State Spec (§17)
| Property | Value |
|----------|-------|
| Icon | `error_outline`, 40px, `error` color |
| Title | "Something went wrong", `heading3` |
| Subtitle | Context-specific, `body1`, `textSecondary` |
| CTA | "Try Again" ghost button |

### Widget API
```dart
class AppErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
}
```

### Constraints
- Use `AppColors.error` for icon color
- Use `AppTextStyles.heading3` for title
- Use `AppTextStyles.body1` with `AppColors.textSecondary` for subtitle
- CTA uses `AppButton.ghost()` variant
- Must work in both light and dark mode

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_error_state.dart` exists with `AppErrorState` widget
- [ ] Renders `error_outline` icon at 40px in `AppColors.error`
- [ ] Default title: "Something went wrong" in `heading3`
- [ ] Subtitle message in `body1` + `textSecondary`, configurable via parameter
- [ ] "Try Again" ghost button renders when `onRetry` callback provided
- [ ] Retry button hidden when `onRetry` is null
- [ ] Entire layout is centered vertically
- [ ] Dark mode: text and icon adapt to theme
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_error_state.dart`

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
- [ ] AppErrorState widget exists — PENDING
- [ ] Error icon correct — PENDING
- [ ] Default title correct — PENDING
- [ ] Subtitle configurable and styled — PENDING
- [ ] Try Again button renders with callback — PENDING
- [ ] Retry button hidden without callback — PENDING
- [ ] Layout centered vertically — PENDING
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
- ui-design-system.md §17 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- Dark mode works — PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
