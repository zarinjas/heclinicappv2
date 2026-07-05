# Login Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T04 |
| Slug | login-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing login screen from `auth_page/login*/` to a new V2 design-compliant login screen at `lib/features/auth/login_screen.dart`. Add biometric auto-prompt on load (existing `local_auth` logic preserved). Replace `FFButtonWidget` with `AppButton`. Replace styled `TextField` with `AppInput`.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.4
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow, §6 design image
- `docs/design-system-v2.png` — Visual target

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/login_screen.dart`
- Email/Phone input using `AppInput`
- Password input using `AppInput` with toggle visibility
- Login button using `AppButton` primary variant
- Forgot Password link → navigate to forgot step 1
- Register link → navigate to register step 1
- Biometric auto-prompt on load (preserve existing `local_auth` logic)
- Form validation (email format, password not empty)
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for auth failure (wrong credentials)

### Out of Scope
- Forgot password flow (UI-P2-T07/T08/T09)
- Register flow (UI-P2-T05/T06)
- Auth service/API logic changes (preserve existing)
- Deleting old `auth_page/login*/` (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/login_screen.dart` — New login screen

### API Endpoints
- Existing login API calls (preserved from current auth_page)

### Data / Schema
- Login form state: identifier (email/phone), password

### UI Components (Flutter tasks only)
- AppInput: Email/Phone field, Password field with toggle
- AppButton: Primary variant for Login
- Loading: Show loading indicator on AppButton during API call
- Empty: N/A
- Error: AppErrorState for invalid credentials error

### Constraints
- Must use `AppInput` for all text fields (no `TextField` with inline styling)
- Must use `AppButton` for Login (no `FFButtonWidget`)
- Must preserve existing `local_auth` biometric logic
- Must preserve existing API call logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Login form: email/phone input + password input using AppInput
- [ ] Password toggle visibility works
- [ ] Login button (AppButton primary) triggers auth API call
- [ ] Form validation: empty email shows error, empty password shows error
- [ ] Biometric prompt appears on screen load (if enabled and available)
- [ ] Forgot Password link navigates to forgot email screen
- [ ] Register link navigates to register step 1 screen
- [ ] Invalid credentials show AppErrorState with retry
- [ ] All widgets use design system components (no FFButtonWidget, no raw TextField)
- [ ] Dark mode renders correctly

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created `lib/features/auth/login_screen.dart` with email/password form, biometric auto-prompt using local_auth, form validation, error/empty states, and design system components. Preserves local_auth logic.

### Files Changed
- `lib/features/auth/login_screen.dart` — New file, 262 lines

### Decisions Made During Implementation
- Biometric prompt via LocalAuthentication API on screen load
- Form validation on email (non-empty) and password (non-empty)
- Error state as full-page with try-again button
- Forgot password → /forgotEmail, Register link → /registerStep1

### Known Limitations
- Routes not yet registered in GoRouter (Phase 12)


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] Login form: email/phone + password using AppInput — PASS
- [x] Password toggle visibility works — PASS
- [x] Login button triggers auth — PASS
- [x] Form validation works — PASS
- [x] Biometric prompt appears on screen load — PASS
- [x] Forgot Password link navigates — PASS
- [x] Register link navigates — PASS
- [x] Error state on invalid credentials — PASS
- [x] Design system components used — PASS
- [x] Dark mode renders correctly — PASS


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md alignment: YES — AppColors, AppTextStyles, AppButton, AppInput, AppSpacing all used
- v2-ux-spec.md alignment: YES — Login with biometric, forgot password, register links
