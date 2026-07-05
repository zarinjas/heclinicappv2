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
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
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
Created `lib/core/widgets/app_skeleton.dart` with `AppSkeleton` base class and 7 factory presets: listItem, card, articleCard, videoGrid, appointmentCard, doctorHorizontal, slider. Uses private `_ShimmerBox`, `_ShimmerCircle`, and `_Shimmer` helper widgets with flutter_animate shimmer effect (1500ms repeat). All skeleton colors use AppColors tokens, dark mode aware.

### Files Changed
- `lib/core/widgets/app_skeleton.dart` (created)

### Decisions Made During Implementation
Shimmer applied per-element via `_Shimmer` wrapper to ensure independent sweep on each skeleton shape. Factory constructors return typed subclasses of AppSkeleton. Follows existing skeleton_loaders.dart shimmer pattern (controller.repeat() + shimmer(color list)).

### Known Limitations
None.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppSkeleton widget exists — PASS
- [x] Shimmer animation works — PASS
- [x] .listItem() correct — PASS
- [x] .card() correct — PASS
- [x] .articleCard() correct — PASS
- [x] .videoGrid() correct — PASS
- [x] .appointmentCard() correct — PASS
- [x] .doctorHorizontal() correct — PASS
- [x] .slider() correct — PASS
- [x] Light mode colors correct — PASS
- [x] Dark mode colors correct — PASS
- [x] flutter analyze passes — PASS

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md §15 alignment: PASS — All 7 presets implemented with correct shapes (48px circle + 2 bars for listItem, 180px slider rect, etc.), shimmer colors from AppColors tokens
- ui-migration-plan.md alignment: PASS — Phase 0 item 0.9 implemented
- Dark mode works — PASS — skeletonBaseDark/skeletonShimmerDark used via brightness check
- No hardcoded colors — PASS — All colors from AppColors tokens

### Rejection Reason
{}
