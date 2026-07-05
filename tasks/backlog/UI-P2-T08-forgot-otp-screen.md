# Forgot Password — OTP Screen (Step 2) — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T08 |
| Slug | forgot-otp-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.8 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing forgot password OTP step from `auth_page/forgot*/` to a new V2 design-compliant screen at `lib/features/auth/forgot_otp_screen.dart`. OTP step uses the new `OtpInputRow` component (Phase 1). Countdown timer for resend preserved. Replace all FlutterFlow widgets with design system components.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.8
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow
- Phase 1 component: `OtpInputRow` at `lib/core/widgets/otp_input_row.dart`

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/forgot_otp_screen.dart`
- AppAppBar with back button
- Title: "Enter OTP" with message showing email where OTP was sent
- `OtpInputRow` component for 6-digit OTP entry
- Countdown timer (e.g. 60s) with "Resend OTP" button
- Verify OTP button using `AppButton` primary → calls verify OTP API → navigate to step 3
- Auto-advance when 6 digits entered
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for wrong OTP or expired OTP

### Out of Scope
- Forgot password steps 1 and 3 (UI-P2-T07, UI-P2-T09)
- OTP verify API logic changes (preserve existing)
- Deleting old `auth_page/forgot*/` (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/forgot_otp_screen.dart` — New OTP entry screen

### API Endpoints
- Existing verify OTP API (preserved from current auth_page)
- Existing resend OTP API (preserved)

### Data / Schema
- OTP: 6-digit code
- Countdown state: remaining seconds, resend enabled flag

### UI Components (Flutter tasks only)
- AppAppBar: sub-page variant with back button
- OtpInputRow: 6-digit OTP input (Phase 1 component)
- AppButton: Primary variant for Verify OTP, Ghost variant for Resend
- Loading: Button loading state during API call
- Empty: N/A
- Error: AppErrorState for wrong/expired OTP

### Constraints
- Must use `OtpInputRow` component (from Phase 1)
- Must use `AppButton` for buttons (no `FFButtonWidget`)
- Must preserve existing OTP verify/resend API logic
- Countdown timer must prevent resend before expiry
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] AppAppBar with back button and "Enter OTP" title
- [ ] Message shows email where OTP was sent
- [ ] OtpInputRow component accepts 6-digit input
- [ ] Auto-advance to verify when all 6 digits entered
- [ ] Verify OTP button (AppButton) validates and calls verify API
- [ ] Countdown timer displays and disables Resend until expiry
- [ ] Resend OTP calls resend API and restarts countdown
- [ ] Wrong OTP shows AppErrorState with retry
- [ ] Expired OTP shows appropriate error message
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
- [ ] Email shown in message — PASS / FAIL
- [ ] OtpInputRow accepts 6 digits — PASS / FAIL
- [ ] Auto-advance on 6 digits — PASS / FAIL
- [ ] Verify button works — PASS / FAIL
- [ ] Countdown timer works — PASS / FAIL
- [ ] Resend OTP restarts timer — PASS / FAIL
- [ ] Wrong OTP error state — PASS / FAIL
- [ ] Expired OTP error message — PASS / FAIL
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
