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
| Status | BACKLOG |
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

- [ ] Banner renders with warning (#F5A623) background, full width, at top of screen
- [ ] Warning icon (wifi_off, 20px, white) and "No Internet Connection" text (body2, white) displayed
- [ ] Banner height is 44px minimum (touch target compliance)
- [ ] Banner slides down with 250ms ease animation when connectivity is lost
- [ ] Banner slides up with 250ms ease animation when connectivity is restored
- [ ] Banner auto-hides when network connection returns
- [ ] Banner auto-shows when network connection is lost
- [ ] Uses connectivity_plus package for listening to connectivity changes
- [ ] Dark mode: banner appearance unchanged (consistent warning bg)
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
