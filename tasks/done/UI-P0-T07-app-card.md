# AppCard — Base Card Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T07 |
| Slug | app-card |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 7 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_card.dart` — the base card wrapper used by all feature card components (AppointmentCard, DoctorCard, ArticleCard, etc.) and throughout the app. Provides consistent surface styling per the design system §10.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §10 Cards (lines 257–268)
- `docs/ui-migration-plan.md` — Phase 0 item 0.7 (line 34)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T07, Compliance Check: §10

---

## Scope

### In Scope
- Create `lib/core/widgets/app_card.dart` with `AppCard` widget
- Background: `AppColors.surface` (#FFFFFF)
- Border radius: 16px (`AppRadius.radiusLG`)
- Default padding: 16px (`AppSpacing.space16`)
- Shadow: `AppShadows.shadowLow`
- Border (light mode): 1px solid `#E5E7EB`
- Support `EdgeInsetsGeometry? padding` override
- Support `Widget child` as content
- Support `VoidCallback? onTap` for tappable cards
- Apply press animation via `flutter_animate` on tap

### Out of Scope
- AppointmentCard (UI-P1-T01)
- DoctorCard (UI-P1-T02)
- ArticleCard (UI-P1-T03)
- LoyaltyCard (UI-P1-T05)
- HealthRecordCard (UI-P1-T06)
- Any domain-specific card variant

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_card.dart` — AppCard base widget

### Card Spec
| Property | Value |
|----------|-------|
| Background | `AppColors.surface` |
| Border radius | `AppRadius.radiusLG` (16px) |
| Padding | `AppSpacing.space16` (16px) |
| Shadow | `AppShadows.shadowLow` |
| Border (light) | 1px solid `AppColors.divider` |
| Dark mode | Surface becomes `AppColors.surfaceDark` (#141C2E) |

### Widget API
```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;
}
```

### Constraints
- Use `AppColors` tokens for all colors
- Use `AppRadius` for border radius
- Use `AppShadows` for shadow
- Use `AppSpacing` for default padding
- Dark mode: `Theme.of(context).brightness == Brightness.dark` → switch surface color

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_card.dart` exists with `AppCard` widget
- [ ] Renders with white surface background in light mode
- [ ] Renders with dark surface (#141C2E) in dark mode
- [ ] 16px border radius applied
- [ ] `shadowLow` elevation applied
- [ ] 1px border in `AppColors.divider` color in light mode
- [ ] Default padding is 16px on all sides
- [ ] `onTap` triggers with press animation via flutter_animate
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/core/widgets/app_card.dart` with `AppCard` StatelessWidget. Implements white surface (light) / dark surface (dark) background, 16px border radius, shadowLow, 1px border dark-aware, 16px default padding, onTap with press animation via flutter_animate-powered AnimationController. No hardcoded hex values.

### Files Changed
- `lib/core/widgets/app_card.dart` (created)

### Decisions Made During Implementation
Dark mode switches surface to AppColors.surfaceDark and border to AppColors.dividerDark. Press animation uses same GestureDetector + AnimationController pattern as AppButton for consistency. flutter_animate used via `150.ms` duration extension.

### Known Limitations
None.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppCard widget exists — PASS
- [x] Light mode surface color correct — PASS
- [x] Dark mode surface color correct — PASS
- [x] Border radius 16px — PASS
- [x] shadowLow applied — PASS
- [x] Border in divider color — PASS
- [x] Default padding 16px — PASS
- [x] onTap press animation works — PASS
- [x] flutter analyze passes — PASS

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md §10 alignment: PASS — All base card properties match spec (white surface, 16px radius, shadowLow, 1px border)
- ui-migration-plan.md alignment: PASS — Phase 0 item 0.7 implemented
- Dark mode works — PASS — surfaceDark + dividerDark used
- No hardcoded colors/sizes — PASS — All tokens from AppColors, AppSpacing, AppRadius, AppShadows

### Rejection Reason
{}
