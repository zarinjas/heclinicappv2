# Forgot Password — Email Screen (Step 1) — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T07 |
| Slug | forgot-email-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.7 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing forgot password step 1 from `auth_page/forgot*/` to a new V2 design-compliant screen at `lib/features/auth/forgot_email_screen.dart`. User enters email/phone to receive OTP. Replace all FlutterFlow widgets with design system components.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.7
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/forgot_email_screen.dart`
- AppBar with back button (using AppAppBar sub-page variant)
- Title: "Forgot Password" with subtitle explaining OTP will be sent
- Email/Phone input using `AppInput`
- Send OTP button using `AppButton` primary → calls send OTP API → navigate to step 2
- Form validation (valid email or phone)
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for API failure (user not found, network error)

### Out of Scope
- Forgot password steps 2 and 3 (UI-P2-T08, UI-P2-T09)
- OTP send API logic changes (preserve existing)
- Deleting old `auth_page/forgot*/` (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/forgot_email_screen.dart` — New forgot password step 1 screen

### API Endpoints
- Existing forgot password / send OTP API (preserved from current auth_page)

### Data / Schema
- Forgot step 1: email or phone identifier

### UI Components (Flutter tasks only)
- AppAppBar: sub-page variant with back button
- AppInput: Email/Phone field
- AppButton: Primary variant for Send OTP
- Loading: Button loading state during API call
- Empty: N/A
- Error: AppErrorState for send OTP failures

### Constraints
- Must use `AppInput` for text field
- Must use `AppButton` for Send OTP (no `FFButtonWidget`)
- Must preserve existing OTP send API logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] AppAppBar with back button and "Forgot Password" title
- [ ] Email/Phone input using AppInput
- [ ] Send OTP button (AppButton primary) validates input and calls API
- [ ] Valid identifier → navigate to OTP screen (step 2)
- [ ] Invalid/empty input shows inline validation error
- [ ] API failure shows AppErrorState with retry
- [ ] No hardcoded hex colors or font sizes
- [ ] Dark mode renders correctly

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created new `lib/features/auth/forgot_email_screen.dart` — V2 design-compliant forgot password step 1 screen. Uses AppAppBar.sub with "Forgot Password" title and back navigation to login. Email/Phone AppInput with validation. AppButton.primary "Send OTP" calls existing ForgotchangeCall API with telephone param. On success navigates to /forgotOtp. On failure shows AppErrorState with retry. Dark mode fully supported.

### Files Changed
- `lib/features/auth/forgot_email_screen.dart` — NEW file (189 lines)

### Decisions Made During Implementation
- Used existing `MedicalAppsApiGroup.forgotchangeCall` API (POST /changePasswordforgot with telephone param) to preserve existing API logic
- Input accepts both email and phone (keyboardType: emailAddress) and passes value as-is to the API
- On success navigates to /forgotOtp (step 2 OTP screen) instead of showing old-style dialog
- AppAppBar.sub provides consistent back button + title pattern matching auth screens

### Known Limitations
- API only accepts telephone parameter; email input may not work with backend
- Route /forgotOtp needs to exist for navigation to succeed after API call


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] AppAppBar with back and title — PASS / FAIL
- [ ] Email/Phone input using AppInput — PASS / FAIL
- [ ] Send OTP validates and calls API — PASS / FAIL
- [ ] Navigates to OTP screen on success — PASS / FAIL
- [ ] Empty input shows error — PASS / FAIL
- [ ] API failure shows AppErrorState — PASS / FAIL
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
