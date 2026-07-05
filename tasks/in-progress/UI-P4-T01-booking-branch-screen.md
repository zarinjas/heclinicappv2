# Booking Branch Selection Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P4-T01 |
| Slug | booking-branch-screen |
| Process | Epic: UI Migration — Phase 4 |
| Process Step | Step 4.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Redesign the Booking Branch Selection screen (Step 1 of the booking flow) to use the V2 design system. Replace the existing FlutterFlow-styled branch selection page with a clean, token-driven UI using `BranchCard` and `StepIndicator` components. Display branches from the API and show a skeleton loader while fetching.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 13 (AppAppBar), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 4, Step 4.1, Booking Flow Migration Notes (lines 134–142)
- `docs/v2-ux-spec.md` — Booking Flow screen specifications
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Redesign `lib/features/booking/booking_branch_screen.dart` with V2 design system
- Use `StepIndicator` component showing Step 1 of 4
- Use `BranchCard` component (vertical list) for each branch, accent border on selected
- Skeleton loader (`AppSkeleton`) while fetching branch list from API
- `AppEmptyState` if no branches returned
- `AppErrorState` with retry on API failure
- `AppButton` (Primary) for "Continue" — disabled until a branch is selected
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles
- Support dark mode

### Out of Scope
- Branch API endpoint logic (keep existing business logic)
- Navigation to other booking steps (keep existing GoRouter logic)
- Branch profile detail screen (handled in Phase 10)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/booking/booking_branch_screen.dart` — Redesign with V2 components
- `lib/features/booking/` — Create directory if not exists

### API Endpoints
- `GET /api/v2/config/branches` — Branch list (existing proxy endpoint)

### Data / Schema
- Branch model: id, name, address, facility_id, wa_number (existing model preserved)

### UI Components
- `StepIndicator` (Phase 1) — Step 1 of 4 highlighted
- `BranchCard` (Phase 1) — List variant with accent border on selection
- `AppSkeleton` (Phase 0) — List skeleton preset while loading
- `AppEmptyState` (Phase 0) — "No branches available" with location illustration
- `AppErrorState` (Phase 0) — Error icon + "Try Again" retry
- `AppButton` (Phase 0) — Primary variant, disabled state when no selection
- `AppAppBar` (Phase 0) — Sub-page variant with back button + "Select Branch" title

### Constraints
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- No hardcoded hex values, font sizes, or padding
- Skeleton + empty + error states mandatory

---

## Acceptance Criteria

- [ ] Screen shows `StepIndicator` with Step 1 of 4 highlighted at top
- [ ] Branch list loads from API and renders as `BranchCard` vertical list
- [ ] Selected branch shows accent border (AppColors.accent) on its `BranchCard`
- [ ] Skeleton loader displays while API call is in flight
- [ ] Empty state displays when API returns zero branches
- [ ] Error state with "Try Again" button displays on API failure
- [ ] "Continue" button disabled until a branch is selected, enabled with primary color after selection
- [ ] Dark mode: all colors, cards, and text render correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation. Leave blank until implementation is complete.

---

## QA Notes

> Filled in by QA after verification. Leave blank until QA picks up the task.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes. Leave blank until Reviewer picks up the task.
