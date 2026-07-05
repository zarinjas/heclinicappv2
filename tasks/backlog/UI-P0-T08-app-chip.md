# AppChip — Status + Filter Chips

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T08 |
| Slug | app-chip |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 8 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_chip.dart` implementing two chip types from the design system §11: Status chips (Confirmed, Pending, Cancelled, Completed) for appointment/task status display, and Filter chips (default/active toggle) for tab and list filtering.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §11 Chips / Tags / Badges (lines 332–369)
- `docs/ui-migration-plan.md` — Phase 0 item 0.8 (line 35)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T08, Compliance Check: §11

---

## Scope

### In Scope
- Create `lib/core/widgets/app_chip.dart` with `AppChip` widget
- **Status chips** — 4 status variants:
  - Confirmed: `#ECFDF5` bg, `#10B981` text
  - Pending: `#FFF7ED` bg, `#F59E0B` text
  - Cancelled: `#FEF2F2` bg, `#EF4444` text
  - Completed: `#EFF6FF` bg, `#3B82F6` text
- Status chip dimensions: height 24px, radius 8px (`AppRadius.radiusSM`), padding 4px 10px
- Status chip typography: `AppTextStyles.label`
- **Filter chips** — selected/unselected toggle:
  - Default: `#F3F4F6` bg, `#6B7280` text
  - Active (selected): accent bg (`AppColors.accent`), white text
- Filter chip dimensions: height 32px, radius 8px, padding 8px 14px
- Filter chip typography: `AppTextStyles.label`
- **Tier badges** (loyalty):
  - Standard: `#F3F4F6` bg, `#6B7280` text
  - Silver: `#F0F0F0` bg, `#9CA3AF` text
  - Gold: `#FFF7ED` bg, `#F5A623` text

### Out of Scope
- Notification red dot badge (defined in §11, handled inline in nav bar UI-P0-T16)
- Any business logic (these are purely presentational)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_chip.dart` — AppChip widget

### Widget API
```dart
enum AppChipType { status, filter, tier }

enum StatusChipVariant { confirmed, pending, cancelled, completed }
enum TierChipVariant { standard, silver, gold }

class AppChip extends StatelessWidget {
  final String label;
  final AppChipType type;
  final StatusChipVariant? statusVariant;
  final TierChipVariant? tierVariant;
  final bool isSelected;  // for filter type
  final VoidCallback? onTap;
}
```

### Constraints
- All colors from design system tokens (AppColors) or exact hex from §11 for chip-specific colors
- Status chip colors are fixed per variant — use mappings
- Filter chip toggles between default/active on tap
- Use `AppRadius.radiusSM` (8px) for border radius
- Use `AppTextStyles.label` for typography

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_chip.dart` exists with `AppChip` widget
- [ ] All 4 status chip variants render with correct bg and text colors
- [ ] Status chips: 24px height, 8px radius, padding 4×10
- [ ] Filter chips: default state has grey bg + grey text
- [ ] Filter chips: active/selected state has accent bg + white text
- [ ] Filter chips: 32px height, 8px radius, padding 8×14
- [ ] Filter chips toggle state on tap
- [ ] All 3 tier badge variants render with correct colors
- [ ] All text uses `AppTextStyles.label`
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_chip.dart`

### Decisions Made During Implementation
{}

### Known Limitations
{}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PENDING

### Criteria Results
- [ ] AppChip widget exists — PENDING
- [ ] 4 status variants correct — PENDING
- [ ] Status chip dimensions correct — PENDING
- [ ] Filter chip default state correct — PENDING
- [ ] Filter chip active state correct — PENDING
- [ ] Filter chip dimensions correct — PENDING
- [ ] Filter chip toggles on tap — PENDING
- [ ] 3 tier badge variants correct — PENDING
- [ ] Uses AppTextStyles.label — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §11 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- No hardcoded colors/sizes — PENDING

### Rejection Reason
{}
