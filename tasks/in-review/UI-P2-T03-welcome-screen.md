# Welcome / Landing Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T03 |
| Slug | welcome-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing welcome/landing page from `auth_page/` entry to a new V2 design-compliant welcome screen at `lib/features/auth/welcome_screen.dart`. This is the landing screen after splash/onboarding with Login and Register buttons. Replace all FlutterFlow widgets with design system components.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.3
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §8 AppButton, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow
- `docs/design-system-v2.png` — Visual target (design image)

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/welcome_screen.dart`
- He Clinic logo at top
- Tagline/subtitle text
- Login button → navigate to login screen
- Register button → navigate to register step 1
- All design token usage (AppColors, AppTextStyles, AppSpacing, AppButton)
- Dark mode support
- Skeleton: N/A
- Empty: N/A
- Error: N/A

### Out of Scope
- Login screen (UI-P2-T04)
- Register screen (UI-P2-T05/T06)
- Routing setup (Phase 12)
- Deleting old `auth_page/` entry (Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/welcome_screen.dart` — New welcome/landing screen

### API Endpoints
- N/A

### Data / Schema
- N/A

### UI Components (Flutter tasks only)
- AppButton: Primary variant for Login, Secondary/Outlined variant for Register
- Loading: N/A
- Empty: N/A
- Error: N/A

### Constraints
- Must use `AppButton` for Login and Register buttons (no `FFButtonWidget`)
- Must use `AppColors` for all colors
- Must use `AppTextStyles` for all text
- Must use `AppSpacing` for layout

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Welcome screen displays He Clinic logo centered
- [ ] Tagline/subtitle text visible below logo using AppTextStyles
- [ ] Login button (AppButton primary) navigates to login screen
- [ ] Register button (AppButton) navigates to register step 1
- [ ] No hardcoded hex colors — all from AppColors
- [ ] No hardcoded fontSize — all from AppTextStyles
- [ ] Dark mode renders correctly
- [ ] No FlutterFlow widget imports (FFButtonWidget, FlutterFlowTheme, etc.)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created `lib/features/auth/welcome_screen.dart` with He Clinic logo, tagline, and Login/Register buttons using design system components. Full dark mode support.

### Files Changed
- `lib/features/auth/welcome_screen.dart` — New file, 88 lines

### Decisions Made During Implementation
- Login button → /login, Register button → /registerStep1
- AppButton.primary for Login, AppButton.secondary for Register
- All styling via AppColors/AppTextStyles/AppSpacing

### Known Limitations
- Routes not yet registered in GoRouter (Phase 12)


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] Logo centered — PASS / FAIL
- [ ] Tagline visible — PASS / FAIL
- [ ] Login button navigates correctly — PASS / FAIL
- [ ] Register button navigates correctly — PASS / FAIL
- [ ] No hardcoded hex — PASS / FAIL
- [ ] No hardcoded fontSize — PASS / FAIL
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
