# LoyaltyCard Component

## Header
| Field | Value |
|-------|-------|
| Task ID | UI-P1-T05 |
| Slug | loyalty-card |
| Process | Epic UI — Phase 1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |

## Acceptance Criteria
- [x] Gradient background primary→accent, 32px radius — PASS
- [x] Tier badge chip top-left with correct colors — PASS
- [x] Points balance heading1 white centered — PASS
- [x] "Patient Appreciation Points" body2 white 70% — PASS
- [x] Redeem + View History ghost buttons — PASS
- [x] Compact variant hides action buttons — PASS
- [x] Hidden variant returns SizedBox.shrink — PASS
- [x] Skeleton loader — PASS
- [x] Dark mode (gradient unchanged) — PASS
- [x] No hardcoded tokens — PASS
- [x] flutter analyze zero errors — PASS

## Implementation Notes
### Files Changed
- `lib/core/widgets/loyalty_card.dart` — new file
### Decisions
- Points formatted with K suffix for thousands
- Ghost buttons use white borders on gradient bg
- Tier badge reuses AppChip with TierChipVariant
- LoyaltyCardVariant enum: full/compact/hidden

## QA Notes
### Result: PASSED — Build gate: 0 errors. All criteria verified.

## Reviewer Notes
### Decision: APPROVED — §10 Loyalty Card spec matched, dark mode, skeleton, tokens, AppChip for tier.
