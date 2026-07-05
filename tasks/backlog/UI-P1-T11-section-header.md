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
| Status | BACKLOG |
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

## Acceptance Criteria

- [ ] Title renders in heading2 style with primary color, left-aligned
- [ ] "See All" renders on right side when `onSeeAll` callback is provided
- [ ] "See All" uses ghost button styling (accent color, no background/border)
- [ ] "See All" is hidden entirely when `onSeeAll` is null
- [ ] Horizontal padding uses 16px (AppSpacing.md) on both sides
- [ ] Tapping "See All" fires the callback
- [ ] Dark mode: title text switches to white; See All remains accent
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
