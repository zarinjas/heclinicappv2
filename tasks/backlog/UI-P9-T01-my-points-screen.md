# My Points Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P9-T01 |
| Slug | my-points-screen |
| Process | Epic: UI Migration — Phase 9 |
| Process Step | Step 9.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the My Points screen — the loyalty point balance and transaction history hub. Accessible from Home (Loyalty Widget tap) or Profile → My Points. Displays a full-width gradient Points Summary Card (balance, tier badge, progress bar, expiry notice), a Redeem Points primary button, and a paginated transaction history list with filter chips (All / Earned / Redeemed / Expired). Replaces placeholder loyalty references with design-system-compliant UI.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 11 (AppChip), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 9.1 (lines 224–239)
- `docs/v2-ux-spec.md` — My Points screen (lines 380–421)
- `docs/v2-decisions.md` — Loyalty Points System (§587–731)
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/loyalty/my_points_screen.dart` with V2 design system
- Points Summary Card (full width): gradient background (primary → accent), current balance (heading-xl, white), tier badge (Standard/Silver/Gold), tier progress bar (LinearProgressIndicator to next tier), expiry notice if points expiring within 30 days (body-sm, warning color)
- Redeem Points primary button (full width), disabled if balance < 100
- Transaction History section header with filter chips: All / Earned / Redeemed / Expired (AppChip filter variant)
- Transaction list (paginated, 20/page) — TransactionItem per row: icon (per type), type label, invoice ref or reason, date, points amount right-aligned (green earn, red redeem/expire)
- `AppSkeleton` shimmer during initial data load
- `AppEmptyState` with "No points activity yet" + subtitle on zero transactions
- `AppErrorState` with retry on fetch failure
- Support dark mode on all states
- `AppAppBar` (sub-page variant) with "My Points" title and back arrow

### Out of Scope
- Redeem Points bottom sheet logic (Phase 9.2 — separate task)
- Redemption code modal (Phase 9.3 — separate task)
- Backend loyalty service (LoyaltyService, MySQL schema — Process 11 Laravel)
- Registering screen in GoRouter (Phase 12 — navigation migration)
- Firestore sync for real-time balance (Process 11 backend)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/loyalty/my_points_screen.dart` — Create new My Points screen

### API Endpoints
- Loyalty data fetched via Laravel proxy (endpoints TBD per Process 11 backend — use placeholder/mock data if backend not yet ready)

### Data / Schema
- `loyalty_accounts`: patient_id, balance (int), lifetime_earned (int), tier (enum: standard/silver/gold)
- `loyalty_transactions`: id, patient_id, invoice_id, type (earn/redeem/expire/adjust), points (int), balance_after (int), reason, created_at
- Tier thresholds: standard (0–4,999 lifetime), silver (5,000–19,999), gold (20,000+)

### UI Components
- `AppAppBar` (sub-page variant) — "My Points" title with back arrow
- Points Summary Card — `Container` with LinearGradient (primary #0F1B3D → accent #00C9A7)
- Tier badge — `AppChip` or `Container` with tier label
- Tier progress bar — `LinearProgressIndicator` with accent color, label showing "X / Y pts to next tier"
- Expiry notice — `Container` with warning background, body-sm text
- `AppButton` (primary variant) — "Redeem Points (min. 100 pts)" — disabled when balance < 100
- `AppChip` (filter variant) — All / Earned / Redeemed / Expired filter row
- `TransactionItem` (from Phase 1 component) — icon + type label + invoice ref + date + points amount
- `AppSkeleton` — shimmer card + list item presets
- `AppEmptyState` — "No points activity yet" with illustration
- `AppErrorState` — error icon + message + "Try Again" button

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required (scaffold `#0A0E1A`, surface `#141C2E`)
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/loyalty/my_points_screen.dart`
- [ ] Points Summary Card with gradient (primary → accent) background displayed
- [ ] Current balance displayed as heading-xl white number + "Patient Appreciation Points" label
- [ ] Tier badge (Standard / Silver / Gold) visible on summary card
- [ ] Tier progress bar (LinearProgressIndicator) showing progress to next tier
- [ ] Expiry notice shown (warning color, body-sm) when points expiring within 30 days
- [ ] "Redeem Points" primary button — disabled when balance < 100, enabled when >= 100
- [ ] Transaction History section header with "See All" displayed
- [ ] Filter chips (All / Earned / Redeemed / Expired) using AppChip filter variant
- [ ] Transaction list — paginated, TransactionItem per row with icon + type + ref + date + points
- [ ] Points amounts right-aligned: green for earn, red for redeem/expire
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppEmptyState` with "No points activity yet" + subtitle on zero transactions
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold `#0A0E1A`, surface `#141C2E`, correct text colors
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
