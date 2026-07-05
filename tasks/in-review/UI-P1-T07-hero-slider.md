# HeroSlider Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T07 |
| Slug | hero-slider |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 7 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `HeroSlider` reusable component for the Home screen banner carousel. Auto-scrolls through CMS-managed slider images with dot indicators. Hides entirely when no sliders are available.

---

## Context

- `docs/ui-design-system.md` — §14 (Hero Banner / Slider)
- `docs/ui-migration-plan.md` — Phase 1, §1.7 (HeroSlider), Phase 3 (Home — Hero Slider section)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/hero_slider.dart` — new file
- `PageView` with auto-scroll every 4 seconds using `Timer`
- Height: 180px, border radius: `AppRadius.lg` (16px)
- Full-bleed image with optional text overlay
- Dot indicator: centered below, 6px dots, active dot in accent color, inactive in grey
- Smooth page scroll animation
- Tap callback on each slide (deep link support)
- Skeleton loader: shimmer rect 180px height while loading
- Hidden entirely (SizedBox.shrink) when slider list is empty
- Image loading with `ClipRRect` for rounded corners

### Out of Scope
- CMS slider data fetching (data passed via constructor)
- Image caching strategy (uses standard `Image.network`)
- Text overlay content rendering (passed via widget params)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/hero_slider.dart` — new file

### Design Spec (from ui-design-system.md §14)
- Height: 180px
- Border radius: `AppRadius.lg` (16px)
- Dot indicator: 6px dots, `AppColors.accent` active, `AppColors.textSecondary` with opacity inactive
- Auto-scroll: 4s interval, smooth page transition
- Skeleton: shimmer rect 180px height

### Constraints
- Use `AppColors`, `AppSpacing`, `AppRadius`
- Dark mode support
- Empty state (hide when no sliders)
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] PageView displays slider images at 180px height with 16px rounded corners
- [ ] Auto-scroll advances to next slide every 4 seconds with smooth animation
- [ ] Dot indicators render below the slider; active dot uses accent color, inactive dots use grey
- [ ] Tap on a slide fires callback with slide index/data
- [ ] Component returns SizedBox.shrink when slider list is empty
- [ ] Skeleton loader renders 180px shimmer rect while images load
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors

---

## Implementation Notes

Created `lib/core/widgets/hero_slider.dart`:
- `HeroSlide` data class with `imageUrl`, `onTap` callback, optional `textOverlay`
- `HeroSlider` StatefulWidget: `PageView.builder` with `ClipRRect` (AppRadius.radiusLG, 16px), 180px fixed height
- Auto-scroll: `Timer.periodic` every 4s, `animateToPage` with 350ms easeInOut; resets on manual page change
- Dot indicators: centered row, 6px height, active=accent/animated 18px wide pill, inactive=grey with 40% opacity, only shown when slides > 1
- Empty: returns `SizedBox.shrink()` when `slides.isEmpty`
- Image loading: `Image.network` with `fit: BoxFit.cover`, loading placeholder surface color, error with broken_image icon
- Optional text overlay: gradient bottom overlay with white text
- `HeroSliderSkeleton`: 180px shimmer rect using flutter_animate, dark-mode-aware colors
- All tokens: AppColors, AppRadius, AppSpacing. No hardcoded hex values
- `flutter analyze` passed with zero errors

---

## QA Notes
