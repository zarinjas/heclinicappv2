# Redeem Points Bottom Sheet

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P9-T02 |
| Slug | redeem-points-sheet |
| Process | Epic: UI Migration — Phase 9 |
| Process Step | Step 9.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Redeem Points bottom sheet — triggered from the My Points screen "Redeem Points" button. Allows patients to select a point amount (stepper: min 100, max min(balance, 1000) in 100pt increments), previews the RM discount value in real-time, and confirms the redemption. On success, triggers the Redemption Code modal (Phase 9.3). All styling via design system tokens.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 12 (AppBottomSheet), 20 (AppDialog), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 9.2 (line 229)
- `docs/v2-ux-spec.md` — Redeem Points bottom sheet (lines 425–451)
- `docs/v2-decisions.md` — Loyalty Points System (§587–731, especially Redemption Rate: 100pts = RM5)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/loyalty/redeem_points_sheet.dart` using `AppBottomSheet` wrapper
- Handle bar at top
- Heading: "Redeem Points" (heading-md)
- Subtitle: "Available: {X} pts" (body-md, text-secondary)
- Amount selector: stepper with minus/plus buttons + centered amount display (increments by 100, min 100, max min(balance, 1000))
- Real-time discount preview: "= RM {X.XX} discount" (heading-sm, accent color) + body-sm subtext
- Info note (body-sm, text-secondary): "Show your redemption code to staff at counter. Code valid for this visit only."
- "Confirm Redemption" primary button (full width)
- Loading state via `AppDialog` loading variant during API call
- Error state with retry if redemption fails
- Support dark mode

### Out of Scope
- Backend LoyaltyService::redeemPoints() API call implementation (Process 11 Laravel)
- Redemption Code modal display after success (Phase 9.3 — separate task; this sheet triggers it via callback)
- My Points screen integration (done in Phase 9.1)
- Points balance refresh after redemption (Phase 9.1 handles)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/loyalty/redeem_points_sheet.dart` — Create new Redeem Points bottom sheet widget

### API Endpoints
- Redemption API call via Laravel proxy (endpoint TBD per Process 11 — use placeholder callback if backend not ready)

### Data / Schema
- Redemption rate: 100 points = RM 5.00 discount (0.05 per point)
- Min redemption: 100 points
- Max per transaction: min(balance, 1000) points
- Redemption code format: HEC-{4 alphanumeric}-{4-digit check}

### UI Components
- `AppBottomSheet` — wrapper with handle bar
- `AppButton` (primary variant) — "Confirm Redemption" button
- `AppButton` (ghost variant) — minus/plus stepper buttons
- `AppCard` — points amount display container
- `AppDialog` (loading variant) — during API call
- `AppToast` (error variant) — on redemption failure

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Bottom sheet renders at `lib/features/loyalty/redeem_points_sheet.dart`
- [ ] Uses `AppBottomSheet` wrapper with handle bar
- [ ] "Redeem Points" heading (heading-md) displayed
- [ ] "Available: {X} pts" subtitle (body-md, text-secondary) displayed
- [ ] Stepper: minus button (left), centered points amount, plus button (right)
- [ ] Stepper increments/decrements by 100, clamped to min 100 / max min(balance, 1000)
- [ ] Real-time RM discount preview: "= RM {X.XX} discount" (heading-sm, accent) + subtext
- [ ] Info note displayed: "Show your redemption code to the staff at the counter. Code is valid for this visit only."
- [ ] "Confirm Redemption" primary button (full width) visible
- [ ] Confirm button disabled when amount < 100
- [ ] Loading modal shown during redemption API call
- [ ] Error toast shown on redemption failure
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Dark mode fully supported
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `{}`

### Decisions Made During Implementation
{}

### Known Limitations
{}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {} — PASS / FAIL — {note if fail}

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason
{}
