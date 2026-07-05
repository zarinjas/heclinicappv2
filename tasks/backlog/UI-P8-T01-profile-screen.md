# Profile Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T01 |
| Slug | profile-screen |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Profile Tab — the 5th bottom nav tab. Consolidates existing profile variants (`ProfileCopy`, `homepage_new/profile`) into a single scrollable screen with avatar, user details display, settings menu (Biometric, Notifications, Change Password), about section (Clinic Info, Privacy, Terms), and logout action. Replaces all legacy `ProfileCopy` and inline profile widgets with full design system compliance.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 11 (AppChip), 12 (AppNavBar), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 18 (AppToast), 20 (AppDialog), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.1 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Tab specification
- `docs/v2-decisions.md` — Patient data model, auth flow
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/profile_screen.dart` with V2 design system
- Avatar (80px circle) with patient photo/initials, full name, email, NRIC display
- "My Details" row with edit arrow → navigates to Edit Profile (Phase 8.2)
- Settings section: Biometric Login toggle, Notification Preferences arrow, Change Password arrow
- About section: He Clinic Info, Privacy Policy, Terms of Service (arrow items)
- "Log Out" destructive button (full width) with `AppDialog` confirmation
- `AppSkeleton` shimmer during initial profile data load
- `AppErrorState` with retry on data fetch failure
- Support dark mode
- Consolidate and remove `ProfileCopy` widget usage; replace with this unified screen
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Edit Profile form (Phase 8.2 — separate task)
- Registering profile screen in bottom nav (Phase 12 — navigation migration)
- Loyalty/My Points screen (Phase 9 — separate phase)
- Backend data model changes (read existing profile data)
- Notification permission management (handled by Phase 8.4/8.5)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/profile_screen.dart` — Create new profile tab screen

### API Endpoints
- Existing profile/user data from FFAppState / auth state / Plato API via Laravel proxy

### Data / Schema
- `FFAppState().userData` or equivalent patient data — name, email, NRIC, phone, photo URL
- Existing auth state for biometric enabled status

### UI Components
- `AppAppBar` (main tab variant) — logo or "Profile" title
- Avatar circle (80px) — `CircleAvatar` with `radiusFull`
- `AppCard` — settings/About sections
- ListTile-style rows with trailing icons (chevron_right, toggle)
- `AppButton` — destructive variant for Log Out
- `AppDialog` — confirmation variant before logout
- `AppSkeleton` — shimmer while loading profile data
- `AppErrorState` — error icon + "Try Again" button
- `AppEmptyState` — (N/A for profile, but defined)
- `AppToast` — success message after logout

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

- [ ] Screen renders at `lib/features/profile/profile_screen.dart`
- [ ] Avatar (80px circle) with patient photo or initials displayed
- [ ] Full name, email, NRIC displayed below avatar
- [ ] "My Details" row with edit/chevron arrow visible
- [ ] Settings section: Biometric Login (toggle), Notification Preferences (arrow), Change Password (arrow)
- [ ] About section: He Clinic Info (arrow), Privacy Policy (arrow), Terms of Service (arrow)
- [ ] "Log Out" destructive button displayed full width
- [ ] `AppDialog` confirmation shown before logout action
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppErrorState` rendered with retry button on fetch failure
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

