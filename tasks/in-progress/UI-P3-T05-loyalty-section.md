# Loyalty Points Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T05 |
| Slug | loyalty-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the loyalty points section on the home screen using the `LoyaltyCard` component (Phase 1). This is a new feature — no equivalent exists in the current homepage. Fetch patient loyalty points data from the CMS/API. Display a compact gradient card with current points balance and tier. Hide the section entirely if the patient has no loyalty account yet. Show `AppSkeleton` while loading.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors, Loyalty Gradient), §10 (AppCard), §15 (Skeleton)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 119
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Loyalty card UX
- `docs/CODEBASE.md` — loyalty/points data source

---

## Scope

### In Scope
- Integrate `LoyaltyCard` component into home screen loyalty section
- Fetch loyalty points data from CMS/API (`GET /api/v2/loyalty/points`)
- Display compact gradient card: primary-to-accent gradient, points balance, tier badge
- Show `AppSkeleton` while loading
- Hide entire section if patient has no loyalty account (data returns null or 404)
- Tap card navigates to My Points screen (Phase 9)
- "See All" or chevron tap also navigates to My Points

### Out of Scope
- LoyaltyCard component itself (Phase 1 — UI-P1-T05)
- My Points screen (Phase 9)
- Redeem points flow (Phase 9)
- Home screen shell (UI-P3-T01)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add loyalty section slot
- `lib/core/widgets/loyalty_card.dart` — Use existing Phase 1 component

### API Endpoints
- `GET /api/v2/loyalty/points` — fetch patient loyalty data
- `GET /api/v2/loyalty/transactions` — optional for compact display

### Data / Schema
- Loyalty: `points_balance`, `tier` (Silver/Gold), `tier_progress`, `has_account`

### UI Components
- `LoyaltyCard` — Phase 1 reusable, compact variant
- `AppSkeleton` — shimmer while loading

### Constraints
- All styling must use design tokens
- Dark mode support
- Gradient: `AppColors.primary` to `AppColors.accent`
- Hide section when no loyalty account detected

---

## Acceptance Criteria

- [ ] Loyalty card displays with primary-to-accent gradient, points balance, and tier badge
- [ ] `AppSkeleton` shimmer is shown while loyalty data is loading
- [ ] Loyalty section is hidden when patient has no loyalty account
- [ ] Tapping the card navigates to My Points screen
- [ ] Gold tier shows gold/warning accent; Silver tier shows silver secondary accent
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason

