# TransactionItem Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T13 |
| Slug | transaction-item |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 13 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `TransactionItem` reusable component for the loyalty points transaction history list on the My Points screen. Displays transaction description, date, and point change amount (+/-) with color coding.

---

## Context

- `docs/ui-design-system.md` — §3 (Typography), §2 (Semantic Colors)
- `docs/ui-migration-plan.md` — Phase 1, §1.13 (TransactionItem), Phase 9 (Loyalty — Transaction history)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/transaction_item.dart` — new file
- Leading: transaction type icon or initial circle
- Title: transaction description, `body1` style
- Subtitle: formatted date, `body2`, `textSecondary`
- Trailing: point amount with +/- sign
  - Earned: green (`AppColors.success`) with "+" prefix
  - Redeemed: red (`AppColors.error`) with "-" prefix
  - Expired: grey (`AppColors.textSecondary`) with "-" prefix
- Tap callback (if transaction has detail view)

### Out of Scope
- Transaction data fetching (data passed via constructor)
- Filter chip logic (handled by parent)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/transaction_item.dart` — new file

### Design Spec
- Description: body1, primary color
- Date: body2, textSecondary
- Point amount: heading3 weight, color-coded (success=green, error=red, textSecondary=grey)
- Layout: Row with leading icon area + text column + trailing amount

### Constraints
- Design tokens only
- Dark mode support

---

## Acceptance Criteria

- [ ] Transaction description renders in body1 style
- [ ] Formatted date renders in body2/textSecondary as subtitle
- [ ] Earned transactions show point amount in green (success color) with "+" prefix
- [ ] Redeemed transactions show point amount in red (error color) with "-" prefix
- [ ] Expired transactions show point amount in grey (textSecondary) with "-" prefix
- [ ] Tap callback fires if provided
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
