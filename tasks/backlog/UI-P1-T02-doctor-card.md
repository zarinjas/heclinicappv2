# DoctorCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T02 |
| Slug | doctor-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `DoctorCard` reusable component for displaying doctor profiles. Used on Home screen (horizontal scroll), Doctor list screen, and Booking Step 2 (doctor selection). Two variants: horizontal card (compact for scrollable lists) and vertical card (full for selection grids/lists).

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Doctor Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.2 (DoctorCard), Phase 3 (Home — Our Doctors), Phase 4 (Booking — Select Doctor)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Doctor card layouts

---

## Scope

### In Scope
- `lib/core/widgets/doctor_card.dart` — new file
- Horizontal variant: 80px circle avatar, name (`heading3`, centered), specialty (`body2`, `textSecondary`, centered), star rating row (if available), "Available Today" chip in success color
- Vertical variant: larger layout for selection screens, photo + name + specialty + bio excerpt + "Book" button
- Photo from CMS URL, fallback to placeholder avatar
- `is_visible_in_app` filtering handled by parent — component receives data
- Skeleton loader for horizontal variant (circle + 2 bars)
- Tap callback for navigation

### Out of Scope
- Doctor data fetching (data passed as constructor param)
- Doctor Detail bottom sheet (separate component, UI-P0-T10)
- Rating API logic (rating data passed in)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/doctor_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Horizontal variant: 80px circle avatar, name heading3 centered, specialty body2 textSecondary centered
- Star icon + rating text, caption style (if available)
- "Available Today" chip in success color
- Vertical variant: full card with photo, name, specialty, bio excerpt, actions

### Constraints
- Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`
- Dark mode support required
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Horizontal variant renders 80px circle avatar, centered name (heading3), centered specialty (body2/textSecondary)
- [ ] Star rating row with star icon and rating text (caption) renders when rating data present; hidden when absent
- [ ] "Available Today" chip renders with success color when doctor is available
- [ ] Vertical variant shows larger photo, name, specialty, bio excerpt, and action button
- [ ] Photo loads from URL; placeholder avatar shown when photo is null/loading
- [ ] Skeleton loader displays shimmer with circle + 2 text bars matching dimensions
- [ ] Tap callback fires correctly
- [ ] Dark mode renders with correct surface colors
- [ ] No hardcoded tokens — all design tokens from shared constants
- [ ] `flutter analyze` returns zero errors
