# First-time Password Change Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T10 |
| Slug | first-change-password-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.10 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Done Date | 2026-07-05 |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing first-time password change screen from `auth_page/` to a new V2 design-compliant screen at `lib/features/auth/first_change_password_screen.dart`. Displayed when a new user logs in for the first time with a temporary password. User must set a new password before proceeding.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.10
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/first_change_password_screen.dart`
- AppAppBar with title "Change Password"
- Info text explaining temporary password must be changed
- Current (temporary) Password input using `AppInput`
- New Password input using `AppInput` with toggle
- Confirm New Password input using `AppInput` with toggle
- Change Password button using `AppButton` primary → calls change password API → navigate to home
- Success: AppDialog success variant → navigate to home
- Form validation (all fields required, new must differ from current, passwords must match)
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for API failure

### Out of Scope
- Login screen (UI-P2-T04)
- Home screen (Phase 3)
- Password change API logic changes (preserve existing)
- Deleting old `auth_page/` version (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/first_change_password_screen.dart` — New first-time password change screen

### API Endpoints
- Existing change password API (preserved from current auth_page)

### Data / Schema
- Change password: currentPassword, newPassword, confirmPassword

### UI Components (Flutter tasks only)
- AppAppBar: sub-page variant
- AppInput: Current Password, New Password (toggle), Confirm (toggle)
- AppButton: Primary variant for Change Password
- AppDialog: Success variant on success
- Loading: Button loading during API call
- Empty: N/A
- Error: AppErrorState for API failures

### Constraints
- Must use `AppInput` for all password fields
- Must use `AppButton` (no `FFButtonWidget`)
- Must use `AppDialog` success variant on success
- Must preserve existing change password API logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] AppAppBar with "Change Password" title
- [ ] Current Password, New Password, Confirm Password using AppInput with toggle
- [ ] Form validation: all required, new must differ from current, must match confirm
- [ ] Change Password button (AppButton) calls API
- [ ] Success: AppDialog success variant → OK navigates to home
- [ ] API failure shows AppErrorState with retry
- [ ] No hardcoded hex colors or font sizes
- [ ] Dark mode renders correctly

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created new `lib/features/auth/first_change_password_screen.dart` — V2 design-compliant first-time password change screen. Uses AppAppBar.sub with "Change Password" title. Three AppInput fields: Current Password, New Password (toggle), Confirm New Password (toggle). AppButton.primary "Change Password" calls FirsttimechangepasswordCall API with Bearer token from FFAppState and new_password param. On success shows AppDialog.success with animated checkmark, sets passwordChanged=true in FFAppState, then navigates to mainPage. On failure shows AppErrorState with retry. Form validates: all fields required, new must differ from current, passwords must match, min 8 chars. Dark mode supported with lock_outline accent icon.

### Files Changed
- `lib/features/auth/first_change_password_screen.dart` — NEW file (216 lines)

### Decisions Made During Implementation
- Used FirsttimechangepasswordCall API (POST /change-password-first) with authorization Bearer token from FFAppState().tokenauth
- new_password sent as form-encoded params per existing API contract
- Sets FFAppState().passwordChanged = true after successful change
- Failure paths: server error message extraction from bodyText

### Known Limitations
- Requires valid auth token in FFAppState for API call to succeed
- Screen assumes user is already logged in with a temporary password
- Route /firstChangePassword needs GoRouter registration or main.dart integration


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] AppAppBar with title — PASS
- [x] Password fields using AppInput with toggle — PASS
- [x] Validation works — PASS
- [x] Change Password button calls API — PASS
- [x] Success dialog shown — PASS
- [x] API failure error state — PASS
- [x] No hardcoded styling — PASS
- [x] Dark mode — PASS

### Failure Details
N/A


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md alignment: YES
- v2-ux-spec.md alignment: YES

### Rejection Reason
N/A
