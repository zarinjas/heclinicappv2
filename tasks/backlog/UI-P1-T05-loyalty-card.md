# LoyaltyCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T05 |
| Slug | loyalty-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `LoyaltyCard` reusable component for displaying patient loyalty/points balance. Two variants: compact (Home screen widget) and full-width (My Points screen). Features gradient background, tier badge, points balance, and action buttons.

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Loyalty Points Card), §2 (Loyalty/Points Gradient), §11 (Tier Badges)
- `docs/ui-migration-plan.md` — Phase 1, §1.5 (LoyaltyCard), Phase 3 (Home — Loyalty Points), Phase 9 (Loyalty Points Screens)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/loyalty_card.dart` — new file
- Background: linear gradient `AppColors.primary` (#131C3C) → `AppColors.accent` (#3B8DFF), `AppRadius.2xl` corners
- Tier badge chip in top-left (Standard/Silver/Gold per §11 tier colors)
- Points balance: `heading1` white bold, centered
- Sub-label: "Patient Appreciation Points", `body2`, white 70% opacity
- Bottom row: "Redeem Points" + "View History" ghost buttons (white outlined)
- Compact variant: reduced height for Home screen usage, hides action buttons
- Full variant: full card with actions, used on My Points screen
- Skeleton loader variant: shimmer rect matching gradient shape
- Conditional rendering: hidden when patient has no loyalty account

### Out of Scope
- Loyalty points API data fetching
- Redemption flow (handled by separate bottom sheet)
- Transaction history list (separate screen)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/loyalty_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Background: `LinearGradient(colors: [AppColors.primary, AppColors.accent])`
- Border radius: `AppRadius.2xl` (32px)
- Points balance: heading1, white, centered
- Sub-label: body2, white with 70% opacity
- Ghost buttons: white border, white text, transparent background
- Tier badge: `AppChip` tier variant (Standard=#F3F4F6, Silver=#F0F0F0, Gold=#FFF7ED)

### Constraints
- Gradient uses only AppColors tokens
- Dark mode: gradient colors unchanged; card surface adapts
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Background renders as linear gradient from primary (#131C3C) to accent (#3B8DFF) with 32px rounded corners
- [ ] Tier badge chip displays in top-left with correct tier colors (Standard grey, Silver light grey, Gold amber)
- [ ] Points balance displayed in heading1 style, white color, centered
- [ ] Sub-label "Patient Appreciation Points" in body2, white 70% opacity, centered below balance
- [ ] Bottom row shows "Redeem Points" + "View History" as white-outlined ghost buttons
- [ ] Compact variant renders reduced height without action buttons
- [ ] Card is hidden (returns SizedBox.shrink) when loyalty account is null/inactive
- [ ] Skeleton loader renders shimmer rect matching card dimensions
- [ ] Dark mode: gradient colors unchanged, card adapts to dark surface
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
