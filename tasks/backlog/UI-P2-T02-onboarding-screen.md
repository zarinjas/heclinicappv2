# Onboarding Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T02 |
| Slug | onboarding-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all), UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing onboarding screen from `on_boarding_new/` to a new V2 design-compliant onboarding screen at `lib/features/auth/onboarding_screen.dart`. 3 slides using `PageView` with dot indicator, Skip + Next + Get Started buttons. Replace all hardcoded colors with design tokens.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.2
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §4 AppSpacing, §8 AppButton
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow
- `docs/design-system-v2.png` — Visual target

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/onboarding_screen.dart`
- 3 onboarding slides with `PageView`
- Dot indicator (active/inactive)
- Skip button (top right), Next button, Get Started button (last slide)
- All colors, typography, spacing from design tokens
- Dark mode support
- Skeleton: N/A (static slides, no data loading)
- Empty: N/A
- Error: N/A

### Out of Scope
- Splash screen (UI-P2-T01)
- Welcome screen (UI-P2-T03)
- Deleting old `on_boarding_new/` (Phase 13)
- Slide content CMS integration (CMS data, handled in Process 9)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/onboarding_screen.dart` — New onboarding screen

### API Endpoints
- N/A

### Data / Schema
- Slide content: static data for now (3 slides with title, subtitle, illustration)

### UI Components (Flutter tasks only)
- Loading: N/A
- Empty: N/A  
- Error: N/A
- AppButton: Primary variant for Next/Get Started, Ghost variant for Skip

### Constraints
- Must use `AppButton` for all buttons (no `FFButtonWidget`)
- Must use `AppColors` for all colors (no `Color(0xFF...)`)
- Must use `AppTextStyles` for all text (no hardcoded `fontSize`)
- Must use `AppSpacing` for padding/margin
- Slides use `PageView` with `SmoothPageIndicator` or custom dot indicator

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] 3 onboarding slides swipeable via `PageView`
- [ ] Dot indicator reflects current slide with active/inactive styling using design tokens
- [ ] Skip button visible on slides 1-2, navigates to welcome/login
- [ ] Next button on slides 1-2, advances to next slide
- [ ] Get Started button on slide 3, navigates to welcome/login
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All text uses `AppTextStyles` (no hardcoded fontSize)
- [ ] Dark mode renders correctly
- [ ] Buttons use `AppButton` (not `FFButtonWidget`)

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
- [ ] 3 onboarding slides swipeable via PageView — PASS / FAIL
- [ ] Dot indicator reflects current slide — PASS / FAIL
- [ ] Skip button works correctly — PASS / FAIL
- [ ] Next button advances to next slide — PASS / FAIL
- [ ] Get Started button navigates correctly — PASS / FAIL
- [ ] All colors from AppColors tokens — PASS / FAIL
- [ ] All text from AppTextStyles — PASS / FAIL
- [ ] Dark mode renders correctly — PASS / FAIL
- [ ] Buttons use AppButton — PASS / FAIL

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- ui-design-system.md alignment: YES / NO
- v2-ux-spec.md alignment: YES / NO

### Rejection Reason
