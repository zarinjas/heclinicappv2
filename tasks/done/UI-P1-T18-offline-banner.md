# OfflineBanner Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T18 |
| Slug | offline-banner |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 18 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `OfflineBanner` reusable component for displaying a global top banner when the device has no internet connection. Shows warning icon, "No Internet Connection" message, and auto-hides when connection is restored. Monitors connectivity using the `connectivity_plus` package.

---

## Context

- `docs/ui-design-system.md` — §2 (Semantic Colors — warning), §7 (Icons)
- `docs/ui-migration-plan.md` — Phase 1, §1.18 (OfflineBanner)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/offline_banner.dart` — new file
- Global banner positioned at top of screen (below status bar)
- Warning icon: `Icons.wifi_off`, 20px, white
- Message: "No Internet Connection", `body2` style, white text
- Background: `AppColors.warning` (#F5A623) solid color
- Height: 44px (meets minimum touch target)
- Slide-down animation on appear (250ms ease)
- Slide-up animation on disappear (250ms ease)
- Uses `connectivity_plus` package to listen for connectivity changes
- Exposes as a widget that can be placed once in the root scaffold
- Automatically hides when connection restored; shows when connection lost

### Out of Scope
- Offline data caching (separate concern)
- Retry logic for failed API calls (handled by data layer)
- Platform-specific connectivity nuances

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/offline_banner.dart` — new file

### Design Spec
- Background: `AppColors.warning`
- Text: white, body2 style
- Icon: wifi_off, white, 20px
- Height: 44px
- Animation: slide in/out, 250ms
- Position: top of screen, full width

### Dependencies
- `connectivity_plus` package (check if in pubspec.yaml)

### Constraints
- Design tokens only
- Dark mode: banner appearance unchanged (warning bg + white text)
- Must not interfere with SafeArea

---

## Acceptance Criteria

- [x] Banner renders with warning (#F5A623) background, full width, at top of screen
- [x] Warning icon (wifi_off, 20px, white) and "No Internet Connection" text (body2, white) displayed
- [x] Banner height is 44px minimum (touch target compliance)
- [x] Banner slides down with 250ms ease animation when connectivity is lost
- [x] Banner slides up with 250ms ease animation when connectivity is restored
- [x] Banner auto-hides when network connection returns
- [x] Banner auto-shows when network connection is lost
- [x] Uses connectivity_plus package for listening to connectivity changes
- [x] Dark mode: banner appearance unchanged (consistent warning bg)
- [x] No hardcoded design tokens
- [x] `flutter analyze` returns zero errors

---

## Implementation Notes

Created `lib/core/widgets/offline_banner.dart`:
- `OfflineBanner` StatefulWidget with `SingleTickerProviderStateMixin`
- Uses `connectivity_plus` `Connectivity().onConnectivityChanged` stream subscription
- Initial check via `Connectivity().checkConnectivity()`
- Slide animation: Tween(begin: Offset(0,-1), end: Offset.zero), 250ms Curves.easeInOut
- Conditional render: shrinks when not offline and animation dismissed
- Banner: 44px height, full width, AppColors.warning background
- Icon: Icons.wifi_off, 20px, white; Text: "No Internet Connection", AppTextStyles.body2, white
- Dark mode: banner appearance unchanged (warning bg stays same per spec)
- Added `connectivity_plus: ^7.0.0` to pubspec.yaml
- Proper subscription disposal in dispose()

## QA Notes

QA=PASSED
- Warning background: AppColors.warning, full width
- Icon (wifi_off, 20px, white) + text (body2 style, white) present
- Height: 44px via Container height
- Slide animation: AnimationController 250ms + SlideTransition with Offset Tween
- Auto-hide: _controller.reverse() on connectivity restored
- Auto-show: _controller.forward() on connectivity lost
- connectivity_plus: Connectivity().onConnectivityChanged + .checkConnectivity()
- Dark mode: banner appearance unchanged (warning bg is same in both modes)
- All tokens: AppColors.warning, AppTextStyles.body2, AppSpacing.space8
- flutter analyze: verified zero errors on last run

## Reviewer Notes

APPROVED
- All design tokens used (AppColors.warning, AppTextStyles.body2, AppSpacing.space8) — no hardcoded hex
- connectivity_plus added to pubspec.yaml
- SlideTransition with AnimationController for proper slide in/out
- Proper lifecycle: initState subscription, dispose cancellation
- Dark mode compliance: warning bg keeps consistent appearance
- Clean implementation without scope creep
- Design system compliant
