# AppColors — Design Tokens

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T01 |
| Slug | app-colors |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 1 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/theme/app_colors.dart` containing all color constants defined in the UI Design System §2. This is the foundational color token file — all UI code in the app must reference these constants. No hardcoded hex colors anywhere in the codebase after this task.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 Color Palette (lines 22–78)
- `docs/ui-migration-plan.md` — Phase 0 item 0.1 (line 28)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T01, Compliance Check column
- `docs/design-system-v2.png` — visual reference for color usage

---

## Scope

### In Scope
- Create `lib/core/theme/app_colors.dart` with a sealed/non-instantiable `AppColors` class
- Define all primary colors: `primary` (#131C3C), `primaryLight` (#1D2B5F), `accent` (#3B8DFF), `accentBlue` (#2868F5)
- Define semantic colors: `success` (#27F5A3), `warning` (#F5A623), `error` (#F54636), `textSecondary` (#8B7380)
- Define surface colors: `background` (#587380), `surface` (#FFFFFF)
- Define light mode overrides: scaffoldBg (#F8F9FC), divider (#E5E7EB), inputBorder (#E5E7EB)
- Define dark mode overrides: scaffoldBgDark (#0A0E1A), surfaceDark (#141C2E), dividerDark (#1F2937), textPrimaryDark (#FFFFFF), textSecondaryDark (#9CA3AF), inputBgDark (#1A2236)
- Define skeleton colors: skeletonBase (#E5E7EB), skeletonShimmer (#F3F4F6), skeletonBaseDark (#1F2937), skeletonShimmerDark (#374151)
- Define loyalty gradient colors: pointsGradientStart (#131C3C), pointsGradientEnd (#3B8DFF)
- Define tier colors: silver (#C0C0C0), gold (#F5A623)
- Define WhatsApp green: `#25D366`
- All values as `static const Color` members

### Out of Scope
- Typography (UI-P0-T02)
- Spacing, radius, shadows (UI-P0-T03)
- ThemeData wiring (UI-P0-T04)
- Any widget implementation

---

## Technical Spec

### Files to Create or Modify
- `lib/core/theme/app_colors.dart` — create file with AppColors class

### API Endpoints
N/A

### Data / Schema
N/A

### UI Components
N/A (foundation token file only)

### Constraints
- Import `dart:ui` for the `Color` class
- All color values must be `static const`
- Class must not be instantiable (use private constructor or equivalent)
- No reference to BuildContext; these are raw tokens

---

## Acceptance Criteria

- [ ] `lib/core/theme/app_colors.dart` exists with a non-instantiable `AppColors` class
- [ ] All primary colors defined: `primary`, `primaryLight`, `accent`, `accentBlue` match hex values from §2
- [ ] All semantic colors defined: `success`, `warning`, `error`, `textSecondary` match hex values from §2
- [ ] All surface colors defined: `background`, `surface` match hex values from §2
- [ ] Light mode overrides present: `scaffoldBg` = #F8F9FC, `divider` = #E5E7EB, `inputBorder` = #E5E7EB
- [ ] Dark mode overrides present: `scaffoldBgDark`, `surfaceDark`, `dividerDark`, `textPrimaryDark`, `textSecondaryDark`, `inputBgDark`
- [ ] Skeleton colors defined for both light and dark mode
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/core/theme/app_colors.dart` with all color tokens from ui-design-system.md §2. Includes primary, semantic, surface, light/dark overrides, skeleton, loyalty, chip, and toast colors.

### Files Changed
- `lib/core/theme/app_colors.dart` — created with AppColors class (all constants)

### Decisions Made During Implementation
- Added chip-specific colors (chipConfirmedBg, chipConfirmedText, chipPendingBg, etc.) and toast bar colors from §11 and §18 for use by AppChip and AppToast components
- Added inputBorderFocus and inputBorderError for AppInput use
- Used private constructor pattern for non-instantiability

### Known Limitations
None

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] AppColors class exists and is non-instantiable — PASS — private constructor `AppColors._()` prevents instantiation
- [x] Primary colors match spec hex values — PASS — primary(0xFF131C3C), primaryLight(0xFF1D2B5F), accent(0xFF3B8DFF), accentBlue(0xFF2868F5)
- [x] Semantic colors match spec hex values — PASS — success, warning, error, textSecondary all match
- [x] Surface colors match spec hex values — PASS — background(0xFF587380), surface(0xFFFFFFFF)
- [x] Light mode overrides present and correct — PASS — scaffoldBg(#F8F9FC), divider(#E5E7EB), inputBorder(#E5E7EB)
- [x] Dark mode overrides present and correct — PASS — all 6 dark mode tokens defined
- [x] Skeleton colors defined for both modes — PASS — 2 light + 2 dark tokens
- [x] flutter analyze passes — PASS — zero errors

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- ui-design-system.md §2 alignment: YES — all 9 primary/semantic/surface tokens, all light/dark overrides, chip colors, skeleton colors present and match hex spec
- ui-migration-plan.md alignment: YES — item 0.1 complete
- Design system compliance: YES — token file is source of truth, all values match spec, no hardcoded values outside tokens

### Rejection Reason
N/A
