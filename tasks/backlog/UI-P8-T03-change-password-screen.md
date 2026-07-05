# Change Password Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T03 |
| Slug | change-password-screen |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Change Password screen — accessed from Profile Tab's Settings section. A form screen with Current Password, New Password, and Confirm Password fields using `AppInput` with show/hide toggles. "Change Password" primary button sticky at bottom. Validation: min 8 chars, confirm must match new password. On success: `AppToast` + `AppDialog` success modal, then navigate back. Preserve existing password change API logic, replace only the UI.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 9 (AppInput), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 18 (AppToast), 20 (AppDialog), 22 (Form Patterns), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.3 (lines 203–221)
- `docs/v2-ux-spec.md` — Forgot Password specification (similar flow)
- `docs/v2-decisions.md` — Auth flow
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/change_password_screen.dart` with V2 design system
- Form fields: Current Password, New Password, Confirm Password — all `AppInput` with show/hide toggle
- "Change Password" primary button sticky at bottom, disabled until all fields valid
- Validation: min 8 characters, confirm must match new password
- On success: `AppToast` "Password changed successfully" + navigate back
- `AppSkeleton` shimmer during initial load
- `AppErrorState` with retry on API failure
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- Auth screen redesign (Phase 2 — already done)
- Biometric setup (Phase 8.4 — separate task)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/change_password_screen.dart` — Create new change password screen

### API Endpoints
- Existing password change API endpoint (preserve existing API call logic)

### Data / Schema
- Input: currentPassword, newPassword, confirmPassword (String)

### UI Components
- `AppAppBar` (sub-page variant) — "Change Password" title, back arrow
- `AppInput` (password variant) — Current Password, New Password, Confirm Password with show/hide eye toggle
- `AppButton` primary — "Change Password" (disabled until valid, loading state during API call)
- `AppSkeleton` — shimmer during initial load
- `AppErrorState` — error icon + retry on API failure
- `AppToast` — success message "Password changed successfully"
- `AppDialog` — success modal optionally

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Form validation on blur, not keystroke
- Submit button disabled until all required fields valid
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/profile/change_password_screen.dart`
- [ ] Form fields: Current Password, New Password, Confirm Password — all `AppInput` with show/hide toggle
- [ ] "Change Password" primary button sticky at bottom, disabled until all valid
- [ ] New Password validates min 8 characters
- [ ] Confirm Password validates must match New Password
- [ ] Validation errors shown on field blur with error border + message
- [ ] Loading state on button during API call (spinner replaces label)
- [ ] `AppSkeleton` shimmer shown during initial load
- [ ] `AppErrorState` rendered with retry on API failure
- [ ] `AppToast` success shown after successful change
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

