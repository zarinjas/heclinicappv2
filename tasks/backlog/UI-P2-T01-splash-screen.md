# Splash Screen — UI Migration

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P2-T01 |
| Slug | splash-screen |
| Process | Epic UI — Phase 2 (Auth Screens) |
| Process Step | Step 2.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0 (all) , UI-P1 (all) |
| Blocked Reason | N/A |

---

## Description

Migrate the existing splash screen from `front_page/splash_page/` to a new V2 design-compliant splash screen at `lib/features/auth/splash_screen.dart`. Remove FlutterFlow animation library dependency. Use `flutter_animate` fade-in on the He Clinic logo. Background: primary (#131C3C). No skip button.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-migration-plan.md` — Phase 2 Auth Screens, Step 2.1
- `docs/ui-design-system.md` — §2 AppColors, §3 AppTextStyles, §4 AppSpacing
- `docs/ui-epic.md` — Compliance rules
- `docs/v2-ux-spec.md` — §4 Auth Flow

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Create `lib/features/auth/splash_screen.dart`
- Logo fade-in animation using `flutter_animate` (no FlutterFlow animation lib)
- Primary background color (#131C3C) via `AppColors.primary`
- Auto-navigate to onboarding/welcome after animation completes
- Dark mode support
- Skeleton/loading state N/A (splash is the loading screen itself)

### Out of Scope
- Onboarding screen logic (handled in UI-P2-T02)
- Auth routing logic (handled in Phase 12)
- Deleting old `front_page/splash_page/` (handled in Phase 13)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `lib/features/auth/splash_screen.dart` — New splash screen widget

### API Endpoints
- N/A

### Data / Schema
- N/A

### UI Components (Flutter tasks only)
- Loading: AppSkeleton (not applicable — splash IS loading)
- Empty: N/A
- Error: N/A

### Constraints
- Must use `AppColors.primary` for background (no hardcoded hex)
- Must use `flutter_animate` package (already in pubspec.yaml) for fade-in
- No FlutterFlow animation library imports
- Dark mode: background stays primary, logo visible against it

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Splash screen displays He Clinic logo centered on primary background
- [ ] Logo fades in smoothly (flutter_animate, not FlutterFlow animation lib)
- [ ] Splash auto-navigates after animation completes (no manual skip)
- [ ] No hardcoded hex colors — uses `AppColors.primary`
- [ ] Dark mode does not break logo visibility or animation

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
- [ ] Splash screen displays He Clinic logo centered on primary background — PASS / FAIL
- [ ] Logo fades in smoothly (flutter_animate, not FlutterFlow animation lib) — PASS / FAIL
- [ ] Splash auto-navigates after animation completes — PASS / FAIL
- [ ] No hardcoded hex colors — uses `AppColors.primary` — PASS / FAIL
- [ ] Dark mode does not break logo visibility or animation — PASS / FAIL

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- ui-design-system.md alignment: YES / NO
- v2-ux-spec.md alignment: YES / NO

### Rejection Reason
