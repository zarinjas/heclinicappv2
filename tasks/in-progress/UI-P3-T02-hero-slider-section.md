# Hero Slider Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T02 |
| Slug | hero-slider-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell for integration) |
| Blocked Reason | N/A |

---

## Description

Implement the hero slider section on the home screen, replacing inline slider code in `front_page/homepage_new/`. Dynamic sliders are fetched from the CMS API (`GET /api/v2/config/sliders`). Use the `HeroSlider` component (Phase 1). Show skeleton shimmer while loading. Hide the entire section if 0 sliders are active. Remove all FlutterFlow animation/library dependencies.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §15 (Skeleton)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 116
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Home screen slider UX
- `docs/CODEBASE.md` — existing slider/homepage code

---

## Scope

### In Scope
- Integrate `HeroSlider` component into home screen slider section
- Fetch sliders from CMS API: `GET /api/v2/config/sliders`
- Render slides dynamically with auto-scroll + dot indicator
- Show `AppSkeleton` shimmer placeholder while loading
- Hide entire hero section when slider list is empty
- Preserve existing API call logic for fetching slider data
- Remove FlutterFlow animation dependencies (use `flutter_animate` fade-in)

### Out of Scope
- CMS slider management (admin panel — Process 9)
- Home screen shell structure (UI-P3-T01)
- Other home sections (UI-P3-T03 through T08)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add hero slider section slot
- `lib/core/widgets/hero_slider.dart` — Use/verify existing Phase 1 component

### API Endpoints
- `GET /api/v2/config/sliders` — fetch active sliders (via Laravel proxy)

### Data / Schema
- Slider object: `id`, `image_url`, `link_url`, `sort_order`, `is_active`
- `FFAppState().sliders` or equivalent

### UI Components
- `HeroSlider` — Phase 1 reusable component
- `AppSkeleton` — shimmer placeholder
- `AppEmptyState` — not applicable (hide section when empty)

### Constraints
- All styling must use design tokens
- Dark mode support
- No hardcoded images or test data

---

## Acceptance Criteria

- [ ] Hero slider fetches and displays dynamic sliders from CMS API
- [ ] `AppSkeleton` shimmer is shown while sliders are loading
- [ ] Auto-scroll cycles through slides with dot indicator
- [ ] Entire hero slider section is hidden when slider list is empty (0 active sliders)
- [ ] No FlutterFlow animation library dependencies remain
- [ ] Tap on a slide navigates to `link_url` if present
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason

