# Forgot Password — New Password Screen (Step 3) — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T09 |
| Slug | forgot-newpassword-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.9 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing forgot password step 3 from `auth_page/forgot*/` to a new V2 design-compliant screen at `lib/features/auth/forgot_newpassword_screen.dart`. User enters new password and confirm password. Replace all FlutterFlow widgets with design system components.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.9
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/forgot_newpassword_screen.dart`
- AppAppBar with back button, title "Set New Password"
- New Password input using `AppInput` with toggle visibility
- Confirm Password input using `AppInput` with toggle visibility
- Reset Password button using `AppButton` primary → calls reset API → navigate to login
- Success: AppDialog success variant → navigate to login
- Form validation (min 8 chars, must match confirm)
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for API failure

### Out of Scope
- Forgot password steps 1 and 2 (UI-P2-T07, UI-P2-T08)
- Password reset API logic changes (preserve existing)
- Deleting old `auth_page/forgot*/` (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/forgot_newpassword_screen.dart` — New password reset screen

### API Endpoints
- Existing reset password API (preserved from current auth_page)

### Data / Schema
- New password: newPassword, confirmPassword

### UI Components (Flutter tasks only)
- AppAppBar: sub-page variant with back
- AppInput: New Password (toggle), Confirm Password (toggle)
- AppButton: Primary variant for Reset Password
- AppDialog: Success variant on password reset success
- Loading: Button loading during API call
- Empty: N/A
- Error: AppErrorState for API failures

### Constraints
- Must use `AppInput` for both password fields
- Must use `AppButton` (no `FFButtonWidget`)
- Must use `AppDialog` success variant on success (not a custom dialog)
- Must preserve existing password reset API logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] AppAppBar with back and "Set New Password" title
- [ ] New Password and Confirm Password fields using AppInput with toggle
- [ ] Password validation: min 8 chars, must match confirm
- [ ] Reset Password button (AppButton) calls reset API
- [ ] Success: AppDialog success variant shown → OK navigates to login
- [ ] API failure shows AppErrorState with retry
- [ ] No hardcoded hex colors or font sizes
- [ ] Dark mode renders correctly

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done


### Files Changed
- 

### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] AppAppBar with title — PASS / FAIL
- [ ] Password fields using AppInput with toggle — PASS / FAIL
- [ ] Password validation works — PASS / FAIL
- [ ] Reset Password button calls API — PASS / FAIL
- [ ] Success dialog shown — PASS / FAIL
- [ ] API failure error state — PASS / FAIL
- [ ] No hardcoded styling — PASS / FAIL
- [ ] Dark mode — PASS / FAIL

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- ui-design-system.md alignment: YES / NO
- v2-ux-spec.md alignment: YES / NO

### Rejection Reason
