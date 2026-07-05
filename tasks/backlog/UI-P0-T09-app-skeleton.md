# AppSkeleton — Shimmer Skeleton Loaders

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T09 |
| Slug | app-skeleton |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 9 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_skeleton.dart` with shimmer skeleton loading presets for all common UI patterns. Replaces spinners for list/content loading. Uses `flutter_animate` for shimmer animation. Must support both light and dark theme skeleton colors.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §15 Skeleton Loaders (lines 437–455)
- `docs/ui-migration-plan.md` — Phase 0 item 0.9 (line 36)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T09, Compliance Check: §15

---

## Scope

### In Scope
- Create `lib/core/widgets/app_skeleton.dart` with `AppSkeleton` base shimmer widget
- Provide factory presets via named constructors or static methods:
  - `.listItem()` — 48px circle (left) + 2 text bars (right)
  - `.card()` — full card rect: image top + 3 text bars
  - `.articleCard()` — 140px image rect + 3 bars
  - `.videoGrid()` — 2-column 16:9 rects + 2 bars each
  - `.appointmentCard()` — full card rect with 3 bars
  - `.doctorHorizontal()` — circle + 2 bars, repeated
  - `.slider()` — full-width 180px rect
- Shimmer animation: left-to-right sweep, 1.5s loop
- Light mode colors: base `#E5E7EB` → shimmer `#F3F4F6`
- Dark mode colors: base `#1F2937` → shimmer `#374151`
- Use `flutter_animate` package for shimmer effect

### Out of Scope
- Any business logic or real data fetching
- Screen-level skeleton layouts (those are to be defined per screen)
- Skeleton-to-content crossfade transition (handled at screen level)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_skeleton.dart` — AppSkeleton widget with presets

### Skeleton Patterns Reference

| Pattern | Shape |
|---------|-------|
| List item | 48px circle (left) + 2 text bars (right) |
| Card | Full card rect — image top + 3 text bars |
| Article card | 140px image rect + 3 bars |
| Video grid | 2-col 16:9 rects + 2 bars each |
| Appointment card | Full card rect with 3 bars |
| Doctor horizontal | Circle + 2 bars, repeated |
| Slider | Full-width 180px rect |

### Animation
- `flutter_animate` ShimmerEffect: duration 1500ms, colors [base, shimmer, base]
- Left-to-right gradient sweep

### Constraints
- Use `AppColors.skeletonBase`, `AppColors.skeletonShimmer` for light mode
- Use `AppColors.skeletonBaseDark`, `AppColors.skeletonShimmerDark` for dark mode
- Use `AppRadius.radiusLG` (16px) for card corners in skeleton
- Use `AppRadius.radiusFull` (9999) for circular avatar placeholders
- Must respect `Theme.of(context).brightness`

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_skeleton.dart` exists with `AppSkeleton` widget
- [ ] Base shimmer animation: left-to-right sweep, 1.5s loop
- [ ] `.listItem()` preset renders circle + 2 bars
- [ ] `.card()` preset renders image rect + 3 bars
- [ ] `.articleCard()` preset renders 140px image + 3 bars
- [ ] `.videoGrid()` preset renders 2-column 16:9 rect grid
- [ ] `.appointmentCard()` preset renders full card + 3 bars
- [ ] `.doctorHorizontal()` preset renders circle + 2 bars
- [ ] `.slider()` preset renders 180px rect
- [ ] Light mode: uses `#E5E7EB` → `#F3F4F6` shimmer
- [ ] Dark mode: uses `#1F2937` → `#374151` shimmer
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_skeleton.dart`

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
- [ ] AppSkeleton widget exists — PENDING
- [ ] Shimmer animation works — PENDING
- [ ] .listItem() correct — PENDING
- [ ] .card() correct — PENDING
- [ ] .articleCard() correct — PENDING
- [ ] .videoGrid() correct — PENDING
- [ ] .appointmentCard() correct — PENDING
- [ ] .doctorHorizontal() correct — PENDING
- [ ] .slider() correct — PENDING
- [ ] Light mode colors correct — PENDING
- [ ] Dark mode colors correct — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §15 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- Dark mode works — PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
