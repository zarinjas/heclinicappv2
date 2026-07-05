# AppNavBar — 5-Tab Bottom Navigation Bar

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T16 |
| Slug | app-nav-bar |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 16 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_nav_bar.dart` — the 5-tab bottom navigation bar implementing the design system §12 spec. Replaces the current FlutterFlow 4-tab `NavBarPage` in `main.dart`. Tabs: Home, Appointments, Health, Notifications, Profile.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §12 Bottom Navigation Bar (lines 373–396)
- `docs/ui-migration-plan.md` — Phase 0 item 0.16 (line 43), Phase 12 (Navigation Migration, lines 282–302)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T16, Compliance Check: §12
- `docs/v2-ux-spec.md` — screen-level navigation context

---

## Scope

### In Scope
- Create `lib/core/widgets/app_nav_bar.dart` with `AppNavBar` widget
- 5 tabs: Home, Appointments, Health, Notifications, Profile
- Background: `AppColors.primary` (#131C3C)
- Height: 64px + bottom safe area inset
- Active icon + label: `AppColors.accent` (#3B8DFF)
- Inactive icon + label: `rgba(255,255,255,0.5)` (white at 50% opacity)
- Label style: `AppTextStyles.caption` (10px)
- Shadow: `AppShadows.shadowNav`
- Notification badge on Notifications tab when unread count > 0
- Icon mapping (Material Icons):
  - Home: `home_outlined` / `home` (filled when active)
  - Appointments: `calendar_today_outlined` / `calendar_today`
  - Health: `favorite_outlined` / `favorite`
  - Notifications: `notifications_outlined` / `notifications`
  - Profile: `person_outlined` / `person`
- Accept `int currentIndex` and `ValueChanged<int> onTap`

### Out of Scope
- Screen routing logic (handled at app level with IndexedStack)
- Deep link handling (Phase 12, Navigation Migration)
- Actual screen content behind each tab

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_nav_bar.dart` — AppNavBar widget

### Nav Bar Spec
| Property | Value |
|----------|-------|
| Tabs | 5: Home, Appointments, Health, Notifications, Profile |
| Background | `AppColors.primary` |
| Height | 64px + bottom safe area |
| Active color | `AppColors.accent` |
| Inactive color | `rgba(255,255,255,0.5)` |
| Label | `AppTextStyles.caption` |
| Shadow | `AppShadows.shadowNav` |

### Icon Mapping
| Tab | Inactive Icon | Active Icon |
|-----|--------------|-------------|
| Home | home_outlined | home |
| Appointments | calendar_today_outlined | calendar_today |
| Health | favorite_outlined | favorite |
| Notifications | notifications_outlined | notifications |
| Profile | person_outlined | person |

### Widget API
```dart
class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int notificationCount;
}
```

### Constraints
- Use `BottomNavigationBar` with `type: BottomNavigationBarType.fixed`
- Use `AppColors.primary` for background
- Use `AppColors.accent` for selected items
- Use `AppTextStyles.caption` for labels
- Use `AppShadows.shadowNav` for elevation
- Notification badge: red dot when `notificationCount > 0`, positioned on Notifications icon (index 3)
- Must respect bottom safe area (use `SafeArea` or `MediaQuery.padding`)

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_nav_bar.dart` exists with `AppNavBar` widget
- [ ] 5 tabs rendered: Home, Appointments, Health, Notifications, Profile
- [ ] Background color is `AppColors.primary` (#131C3C)
- [ ] Active tab: icon + label in accent blue (#3B8DFF)
- [ ] Inactive tabs: icon + label at 50% white opacity
- [ ] Label uses `AppTextStyles.caption` (10px)
- [ ] Height is 64px + bottom safe area inset
- [ ] `shadowNav` applied as elevation/shadow
- [ ] Notification badge appears on Notifications tab when count > 0
- [ ] Badge hidden when count = 0
- [ ] `onTap` callback fires with correct tab index
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `AppNavBar` StatelessWidget in `lib/core/widgets/app_nav_bar.dart`. Implements 5-tab bottom navigation (Home, Appointments, Health, Notifications, Profile) with AppColors.primary background, AppColors.accent active color, 50% white inactive, AppTextStyles.caption labels, AppShadows.shadowNav elevation, and notification badge on index 3 when notificationCount > 0. Uses SafeArea-aware height (64px + bottom padding). No hardcoded hex colors or styles.

### Files Changed
- `lib/core/widgets/app_nav_bar.dart`

### Decisions Made During Implementation
- Used Container with BoxDecoration for shadowNav instead of wrapping BottomNavigationBar directly, since BottomNavigationBar's elevation doesn't accept custom BoxShadow lists.
- Used a private _NavTab class for clean icon mapping.
- Badge widget uses AppColors.error for the notification dot.

### Known Limitations
{}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppNavBar widget exists — PASS
- [x] 5 tabs present — PASS
- [x] Primary background — PASS
- [x] Active tab accent color — PASS
- [x] Inactive tabs 50% white — PASS
- [x] Caption label style — PASS
- [x] 64px + safe area height — PASS
- [x] shadowNav applied — PASS
- [x] Notification badge shows when count > 0 — PASS
- [x] Badge hidden when count 0 — PASS
- [x] onTap fires correctly — PASS
- [x] flutter analyze passes — PASS

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §12 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
