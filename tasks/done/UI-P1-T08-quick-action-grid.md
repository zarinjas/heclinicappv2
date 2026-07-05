# QuickActionGrid Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T08 |
| Slug | quick-action-grid |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 8 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `QuickActionGrid` reusable component for the Home screen 2×2 quick actions section. Displays 4 quick action cards (Book Appointment, Find Branch, etc.) in a grid with icons, labels, and tap navigation.

---

## Context

- `docs/ui-design-system.md` — §7 (Icons — Quick action card icons)
- `docs/ui-migration-plan.md` — Phase 1, §1.8 (QuickActionGrid), Phase 3 (Home — Quick Actions section)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Home screen quick actions

---

## Scope

### In Scope
- `lib/core/widgets/quick_action_grid.dart` — new file
- 2×2 `GridView` of quick action cards
- Each card: 28px filled Material icon in accent color, label in `body2` style
- Cards styled with `AppCard` base (surface bg, `shadowLow`, `radiusLG`)
- Configurable actions list (icon, label, onTap) passed as constructor param
- Skeleton loader: 4 shimmer card rects in 2×2 grid

### Out of Scope
- Action routing logic (onTap callbacks defined by parent screen)
- Dynamic action configuration (static set defined by parent)
- CMS-driven action management

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/quick_action_grid.dart` — new file

### Design Spec
- Cards: `AppRadius.lg`, `AppShadows.low`, surface background
- Icons: 28px, filled, `AppColors.accent`
- Labels: `AppTextStyles.body2`, `AppColors.primary`
- Grid: 2 columns, equal spacing using `AppSpacing`

### Constraints
- Design tokens only
- Dark mode support
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Grid renders as 2×2 layout with equal-sized cards
- [ ] Each card displays a 28px filled Material icon in accent color centered above label
- [ ] Labels render in body2 style
- [ ] Cards use surface background, shadowLow, radiusLG from design tokens
- [ ] Each card fires its individual onTap callback on press
- [ ] Skeleton loader renders 4 shimmer card rects in 2×2 grid layout
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors

---

## Implementation Notes

Created `lib/core/widgets/quick_action_grid.dart`:
- `QuickAction` data class with `icon` (IconData), `label` (String), and `onTap` callback
- `QuickActionGrid`: `GridView.builder` 2×2 layout (SliverGridDelegateWithFixedCrossAxisCount, crossAxisSpacing/mainSpacing 12px, aspectRatio 1.4), uses `AppCard` per tile with centered 28px accent icon + body2 label
- Returns `SizedBox.shrink()` when actions list empty
- `QuickActionGridSkeleton`: 4 shimmer tiles in 2×2 grid, each rendering with surface background, border, shadow, and animated shimmer sweep using flutter_animate
- All tokens: AppColors, AppTextStyles, AppSpacing, AppRadius, AppShadows
- Dark mode: AppCard handles surface adaptively; skeleton uses theme-aware colors
- `flutter analyze` passed with zero errors

---

## QA Notes

| # | Criterion | Result | Notes |
|---|-----------|--------|-------|
| 1 | 2×2 grid with equal-sized cards | PASS | SliverGridDelegateWithFixedCrossAxisCount(2), crossAxisSpacing 12px |
| 2 | 28px filled icon in accent color centered above label | PASS | Icon 28px, AppColors.accent, Column mainAxisAlignment center |
| 3 | Labels in body2 style | PASS | AppTextStyles.body2 |
| 4 | Cards use surface/shadowLow/radiusLG | PASS | AppCard provides all three |
| 5 | Each card fires onTap | PASS | AppCard(onTap: action.onTap) per tile |
| 6 | Skeleton 4 shimmer tiles in 2×2 grid | PASS | QuickActionGridSkeleton: 4 tiles with shimmer animation |
| 7 | Dark mode | PASS | AppCard dark-adaptive, skeleton uses theme-aware colors |
| 8 | No hardcoded tokens | PASS | All AppColors/AppTextStyles/AppSpacing/AppRadius/AppShadows |
| 9 | flutter analyze zero errors | PASS | Confirmed zero output |

**QA Result: PASSED** — All 9 criteria verified.
