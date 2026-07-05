# Notification Preferences Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T05 |
| Slug | notification-preferences |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Notification Preferences screen — accessed from Profile Tab's "Notification Preferences" row. A settings screen with toggle rows for each notification channel/type: Push Notifications, Email Notifications, Appointment Reminders, Health Updates, Promotions. Uses `AppCard` sections with `Switch` toggles. Preserves existing Firestore/FCM preference storage logic. Includes loading and error states.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 18 (AppToast), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.5 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Tab — Notification Preferences
- `docs/v2-decisions.md` — Notifications Module (Process 8), 3 channels
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/notification_prefs_screen.dart` with V2 design system
- Toggle rows grouped in `AppCard` sections:
  - Push Notifications (FCM)
  - Email Notifications
  - Appointment Reminders
  - Health Updates
  - Promotions / Marketing
- Each row: icon + label + `Switch` toggle using design system accent color
- Preserve existing preference storage logic (Firestore / SharedPreferences)
- `AppSkeleton` shimmer during initial preference load
- `AppErrorState` with retry on fetch/save failure
- `AppToast` on preference toggle change
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- FCM token registration (Phase 8 in Process 8 — already done)
- Backend preference API (preserve existing logic)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/notification_prefs_screen.dart` — Create new notification preferences screen

### API Endpoints
- Existing Firestore user preferences document (preserve existing query/update logic)
- Existing FCM token management (preserve existing logic)

### Data / Schema
- Firestore user preferences fields: pushEnabled, emailEnabled, appointmentReminders, healthUpdates, promotionsEnabled (boolean)

### UI Components
- `AppAppBar` (sub-page variant) — "Notification Preferences" title, back arrow
- `AppCard` — grouped settings sections
- `Switch` toggles — accent color when active
- Section labels — `heading3` for group titles
- Row layout: leading icon (24px) + label (`heading3`) + trailing `Switch`
- `AppSkeleton` — shimmer during initial preference load
- `AppErrorState` — error icon + retry on failure
- `AppToast` — confirmation on toggle change

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Preserve existing preference storage logic intact
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/profile/notification_prefs_screen.dart`
- [ ] Toggle rows for Push, Email, Appointment Reminders, Health Updates, Promotions
- [ ] Each row: icon + label + `Switch` toggle
- [ ] Toggles grouped in `AppCard` sections with section headings
- [ ] Toggles read current preference state on load
- [ ] Toggle changes persist to existing preference storage
- [ ] `AppSkeleton` shimmer shown during initial preference load
- [ ] `AppErrorState` rendered with retry on failure
- [ ] `AppToast` shown on toggle change (optional)
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

