# Notifications Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P7-T01 |
| Slug | notifications-screen |
| Process | Epic: UI Migration — Phase 7 |
| Process Step | Step 7.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | N/A (single task in phase) |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Notifications Tab — the 4th bottom nav tab. Displays a list of `NotificationItem` cards from Firestore `historynotif` collection. Features include: unread indicator (blue dot + tinted background), mark all read button in app bar, swipe-to-dismiss on individual items, and deep link navigation on tap. Replaces the old `front_page/` notif section with full design system compliance.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 11 (AppChip), 12 (AppNavBar), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 18 (AppToast), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 7 (lines 184–198)
- `docs/v2-ux-spec.md` — Notifications Tab specifications
- `docs/v2-decisions.md` — Notifications Module (Process 8)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/notifications/notifications_screen.dart` with V2 design system
- Notification list using `NotificationItem` component per row
- Unread items: subtle tinted background (`AppColors.surfacePrimary` or similar) + blue dot indicator
- "Mark All Read" button in `AppAppBar` trailing slot
- Swipe-to-dismiss gesture on individual notification rows (with `Dismissible` widget)
- Tap notification → mark as read + navigate to deep link if `data.deeplink` present
- `AppSkeleton` shimmer during initial Firestore load
- `AppEmptyState`: "You're all caught up" with bell illustration
- `AppErrorState` with retry for Firestore failures
- `AppAppBar` (sub-page variant) — "Notifications" title
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Navigation wiring to bottom nav (Phase 12 task)
- Push notification permission management (separate Phase 8 task)
- Notification Preferences screen (Phase 8.5)
- Firestore data model changes (keep existing `historynotif` structure)
- Real-time push handling (handled by Firebase Messaging service)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/notifications/notifications_screen.dart` — Create new notifications tab screen

### API Endpoints
- Firestore: `historynotif` collection (existing), ordered by `createdAt` descending

### Data / Schema
- Existing Firestore `historynotif` document model
- Fields: `title`, `body`, `image`, `deeplink`, `isRead`, `createdAt`, `notificationType`

### UI Components
- `NotificationItem` — from Phase 1 component library
- `AppAppBar` (sub-page variant) — "Notifications" title + "Mark All Read" trailing
- `AppSkeleton` — shimmer while loading from Firestore
- `AppEmptyState` — bell illustration + "You're all caught up!" subtitle
- `AppErrorState` — error icon + "Try Again" button
- `AppButton` (ghost/destructive) — swipe dismiss confirmations if needed

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states (scaffold `#0A0E1A`, surface `#141C2E`)
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/notifications/notifications_screen.dart`
- [ ] Notification list with `NotificationItem` rows from Firestore `historynotif`
- [ ] Unread items show blue dot indicator + tinted background
- [ ] "Mark All Read" button visible in app bar, functional (batches `historynotif` writes)
- [ ] Swipe-to-dismiss removes item from list with animation
- [ ] Tap notification → mark as `isRead: true` → navigate to deeplink if present
- [ ] `AppSkeleton` shows shimmer during initial Firestore load
- [ ] `AppEmptyState`: "You're all caught up" with bell illustration when list empty
- [ ] `AppErrorState` renders with retry button on Firestore failure
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold background `#0A0E1A`, surface `#141C2E`, correct text colors
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations



---

## QA Notes

> Filled in by QA after verification.

### Result: 

### Criteria Results


### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: 

### Alignment Check


### Rejection Reason

