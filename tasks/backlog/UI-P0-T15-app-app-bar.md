# AppAppBar — Main Tab + Sub-page App Bar

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T15 |
| Slug | app-app-bar |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 15 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_app_bar.dart` implementing both app bar variants from the design system §13: Main Tab App Bar (logo + bell icon with badge) and Sub-page App Bar (back arrow + title + optional context action). Replaces the current FlutterFlow-based AppBar implementations.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §13 App Bar (lines 398–419)
- `docs/ui-migration-plan.md` — Phase 0 item 0.15 (line 42)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T15, Compliance Check: §13

---

## Scope

### In Scope
- Create `lib/core/widgets/app_app_bar.dart` with `AppAppBar` widget
- **Main Tab variant** (Home, Appointments, Health, Notifications, Profile):
  - Background: `AppColors.primary` (#131C3C)
  - Leading: He Clinic logo (left-aligned, ~32px height)
  - Trailing: notification bell icon (white) with red dot badge when unread count > 0
  - No title (replaced by logo)
  - Elevation: 0 (flat)
- **Sub-page variant** (any pushed screen):
  - Background: `#F8F9FC` (light bg) or transparent when over hero
  - Leading: back arrow icon, `AppColors.primary` color
  - Title: screen name in `heading3`, `AppColors.primary`
  - Trailing: optional context action (share, edit, search icon)
  - Elevation: 0

### Out of Scope
- Bottom navigation bar (UI-P0-T16)
- Notification badge count logic (fetched from Firestore — screen-level concern)
- Hero banner integration (screen-level concern)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_app_bar.dart` — AppAppBar widget

### Main Tab App Bar Spec
| Property | Value |
|----------|-------|
| Background | `AppColors.primary` |
| Leading | He Clinic logo, 32px height, left-aligned |
| Trailing | Bell icon (white) + red badge |
| Title | hidden |
| Elevation | 0 |

### Sub-page App Bar Spec
| Property | Value |
|----------|-------|
| Background | `#F8F9FC` or transparent |
| Leading | Back arrow, `primary` color |
| Title | Screen name, `heading3`, `primary` |
| Trailing | Optional action icon |
| Elevation | 0 |

### Widget API
```dart
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Main tab variant
  factory AppAppBar.main({VoidCallback? onNotificationTap, int notificationCount});

  // Sub-page variant
  factory AppAppBar.sub({required String title, VoidCallback? onBack, Widget? trailing});

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}
```

### Constraints
- Use `AppColors.primary`, `AppColors.accent`, `AppColors.error` (badge) tokens
- Use `AppTextStyles.heading3` for title
- Notification badge: 18px red circle, white count text, offset (-6, -6) from bell
- He Clinic logo: reference existing logo asset in `assets/` directory
- Back arrow: `Icons.arrow_back_ios` or `Icons.arrow_back`

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_app_bar.dart` exists with `AppAppBar` widget
- [ ] Main tab variant: primary bg, logo left, bell right with badge
- [ ] Notification badge: 18px red circle, white count, positioned (-6, -6)
- [ ] Badge hidden when notificationCount = 0
- [ ] Sub-page variant: light bg, back arrow + title, optional trailing icon
- [ ] Both variants have 0 elevation
- [ ] Implements PreferredSizeWidget with 56px height
- [ ] Back arrow callback works on sub-page variant
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_app_bar.dart`

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
- [ ] AppAppBar widget exists — PENDING
- [ ] Main tab variant correct — PENDING
- [ ] Notification badge correct — PENDING
- [ ] Badge hidden when count 0 — PENDING
- [ ] Sub-page variant correct — PENDING
- [ ] Elevation 0 — PENDING
- [ ] PreferredSizeWidget 56px — PENDING
- [ ] Back arrow callback works — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §13 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
