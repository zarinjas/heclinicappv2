# Register Step 1 Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T05 |
| Slug | register-step1-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing register step 1 from `auth_page/register*/` to a new V2 design-compliant screen at `lib/features/auth/register_step1_screen.dart`. 2-step flow with `StepIndicator` component (Phase 1). Replace all form widgets with `AppInput`. Preserve existing multipart API call logic.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.5
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §9 AppInput, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow
- Phase 1 component: `StepIndicator` at `lib/core/widgets/step_indicator.dart`

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/register_step1_screen.dart`
- `StepIndicator` at top showing step 1 of 2 active
- Name input using `AppInput`
- Email input using `AppInput`
- Phone number input using `AppInput`
- Date of Birth input (date picker) using `AppInput`
- Gender selection (dropdown or chip selection)
- Next button using `AppButton` primary → step 2
- Already have account? Login link
- Form validation
- All design token usage
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: AppErrorState for API failures

### Out of Scope
- Register step 2 (UI-P2-T06)
- Registration API logic changes (preserve existing)
- Deleting old `auth_page/register*/` (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/register_step1_screen.dart` — New register step 1 screen

### API Endpoints
- Existing register API (preserved from current auth_page)

### Data / Schema
- Register step 1: name, email, phone, dob, gender

### UI Components (Flutter tasks only)
- StepIndicator: 2 steps, step 1 active
- AppInput: Name, Email, Phone, DOB fields
- AppChip: Gender selection (Male/Female)
- AppButton: Primary variant for Next
- Loading: Button loading state during validation
- Empty: N/A
- Error: AppErrorState for API failures

### Constraints
- Must use `StepIndicator` component (from Phase 1)
- Must use `AppInput` for all form fields
- Must use `AppButton` for Next (no `FFButtonWidget`)
- Must preserve existing multipart API call logic
- All colors from `AppColors`, all text from `AppTextStyles`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] StepIndicator shows step 1 of 2 active at top of screen
- [ ] Name, Email, Phone, DOB fields all use AppInput
- [ ] Gender selection uses AppChip or styled dropdown
- [ ] Next button (AppButton primary) validates and proceeds to step 2
- [ ] Form validation: required fields show inline errors
- [ ] "Already have account? Login" link navigates to login
- [ ] No hardcoded hex colors or font sizes
- [ ] Dark mode renders correctly
- [ ] No FlutterFlow widget imports

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
- [ ] StepIndicator step 1 active — PASS / FAIL
- [ ] All form fields use AppInput — PASS / FAIL
- [ ] Gender selection functional — PASS / FAIL
- [ ] Next button validates and navigates — PASS / FAIL
- [ ] Form validation works — PASS / FAIL
- [ ] Login link navigates — PASS / FAIL
- [ ] No hardcoded styling — PASS / FAIL
- [ ] Dark mode — PASS / FAIL
- [ ] No FlutterFlow imports — PASS / FAIL

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- ui-design-system.md alignment: YES / NO
- v2-ux-spec.md alignment: YES / NO

### Rejection Reason
