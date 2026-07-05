# SectionHeader Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T11 |
| Slug | section-header |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 11 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `SectionHeader` reusable component for section titles across the Home screen. Displays "Section Title" on the left and an optional "See All" text button on the right. Used by every content section on Home (Doctors, Articles, Videos, etc.).

---

## Context

- `docs/ui-design-system.md` — §3 (Typography — heading2), §8 (Buttons — Ghost variant)
- `docs/ui-migration-plan.md` — Phase 1, §1.11 (SectionHeader), Phase 3 (Home Screen Migration Notes)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/section_header.dart` — new file
- Row layout: title on left, optional "See All" on right
- Title: `heading2` style, `AppColors.primary` color
- "See All": ghost-style text button, `AppColors.accent` color, `label` style
- "See All" visible only when `onSeeAll` callback is provided
- Padding: uses `AppSpacing` screen horizontal padding (16px)

### Out of Scope
- Navigation logic for "See All" (handled by parent via callback)
- Section content rendering (this is just the header)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/section_header.dart` — new file

### Design Spec
- Title: heading2, primary color
- See All: label style, accent color, no border/background (ghost)
- Padding: 16px horizontal (`AppSpacing.md`)
- Row: `MainAxisAlignment.spaceBetween`

### Constraints
- Design tokens only
- Dark mode: title switches to white, See All stays accent

---

---
## Implementation Notes

- Created `lib/core/widgets/section_header.dart`
- StatelessWidget with `title` (required) and `onSeeAll` (optional) parameters
- Title uses `AppTextStyles.heading2` with `AppColors.primary` (light) / `AppColors.textPrimaryDark` (dark)
- "See All" uses `AppTextStyles.label` with `AppColors.accent`, displayed only when `onSeeAll` is non-null
- Horizontal padding: `AppSpacing.space16` via `EdgeInsets.symmetric`
- `flutter analyze`: zero errors

---
## Acceptance Criteria

- [x] Title renders in heading2 style with primary color, left-aligned
- [x] "See All" renders on right side when `onSeeAll` callback is provided
- [x] "See All" uses ghost button styling (accent color, no background/border)
- [x] "See All" is hidden entirely when `onSeeAll` is null
- [x] Horizontal padding uses 16px (AppSpacing.space16) on both sides
- [x] Tapping "See All" fires the callback
- [x] Dark mode: title text switches to white; See All remains accent
- [x] No hardcoded design tokens
- [x] `flutter analyze` returns zero errors

---
## QA Notes

**Build Gate:** `flutter analyze` — PASSED (zero errors)

| # | Criterion | Result |
|---|-----------|--------|
| 1 | Title heading2 + primary color, left-aligned | PASS |
| 2 | "See All" on right when onSeeAll provided | PASS |
| 3 | Ghost style (accent, no bg/border) | PASS |
| 4 | "See All" hidden when onSeeAll null | PASS |
| 5 | 16px horizontal padding (AppSpacing.space16) | PASS |
| 6 | "See All" tap fires callback | PASS |
| 7 | Dark mode: white title, accent See All | PASS |
| 8 | No hardcoded tokens | PASS |
| 9 | flutter analyze zero errors | PASS |

**QA Verdict: PASSED**

---
## Reviewer Notes

- ui-design-system.md compliance: All tokens from AppColors/AppSpacing/AppTextStyles. No hardcoded values.
- Dark mode: Supported (title→white, See All→accent)
- AppButton/AppInput/AppCard usage: N/A (simple text row header)
- Skeleton/empty/error states: N/A (section header, not a content/list screen)
- v2-decisions.md alignment: PASS
- v2-ux-spec.md alignment: PASS (matches section header + "See All" pattern)

**Reviewer Decision: APPROVED**
