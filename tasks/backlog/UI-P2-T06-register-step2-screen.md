# Register Step 2 Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T06 |
| Slug | register-step2-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing register step 2 from `auth_page/register*/` to a new V2 design-compliant screen at `lib/features/auth/register_step2_screen.dart`. 2-step flow with `StepIndicator` component showing step 2 active. Password creation with confirm password. Replace all form widgets with `AppInput`.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.6
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow
- Phase 1 component: `StepIndicator` at `lib/core/widgets/step_indicator.dart`

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/register_step2_screen.dart`
- `StepIndicator` at top showing step 2 of 2 active
- Password input using `AppInput` with strength indicator
- Confirm password input using `AppInput`
- Terms & Privacy Policy checkbox with links
- Register button using `AppButton` primary → submit registration
- Back button to step 1
- Form validation (password match, min length, terms accepted)
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for registration API failures

### Out of Scope
- Register step 1 (UI-P2-T05)
- Registration API logic changes (preserve existing)
- Deleting old `auth_page/register*/` (Phase 13)
- Password strength algorithm changes

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/register_step2_screen.dart` — New register step 2 screen

### API Endpoints
- Existing register API (preserved from current auth_page)

### Data / Schema
- Register step 2: password, confirmPassword, termsAccepted

### UI Components (Flutter tasks only)
- StepIndicator: 2 steps, step 2 active
- AppInput: Password (with toggle), Confirm Password (with toggle)
- AppButton: Primary variant for Register
- Loading: Button loading state during API call
- Empty: N/A
- Error: AppErrorState for API failures

### Constraints
- Must use `StepIndicator` component (from Phase 1)
- Must use `AppInput` for all form fields
- Must use `AppButton` for Register (no `FFButtonWidget`)
- Must preserve existing registration API call logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] StepIndicator shows step 2 of 2 active at top of screen
- [ ] Password and Confirm Password fields use AppInput with toggle visibility
- [ ] Password validation: min 8 chars, must match confirm password
- [ ] Terms & Privacy checkbox required before register button enabled
- [ ] Register button (AppButton primary) triggers registration API call
- [ ] Back button returns to step 1 preserving entered data
- [ ] API error displays AppErrorState with retry
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
- [ ] StepIndicator step 2 active — PASS / FAIL
- [ ] Password fields use AppInput with toggle — PASS / FAIL
- [ ] Password validation works — PASS / FAIL
- [ ] Terms checkbox required — PASS / FAIL
- [ ] Register button triggers API — PASS / FAIL
- [ ] Back button preserves data — PASS / FAIL
- [ ] API error with AppErrorState — PASS / FAIL
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
