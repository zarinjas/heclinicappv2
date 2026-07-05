# AppTheme — Light + Dark ThemeData

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T04 |
| Slug | app-theme |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 4 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | UI-P0-T01, UI-P0-T02, UI-P0-T03 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/theme/app_theme.dart` that wires AppColors, AppTextStyles, AppSpacing, AppRadius, and AppShadows into Flutter `ThemeData` for both light and dark modes. This is the bridge between raw tokens and the Flutter theming system. Every screen must be wrapped with this theme.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §24 Dark Mode (lines 611–628), §2 Color Palette overrides (lines 49–68)
- `docs/ui-migration-plan.md` — Phase 0 item 0.4 (line 31)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T04

---

## Scope

### In Scope
- Create `lib/core/theme/app_theme.dart` with `AppTheme` class
- Provide `static ThemeData get lightTheme` — full light ThemeData
- Provide `static ThemeData get darkTheme` — full dark ThemeData
- Wire `AppColors` into `ColorScheme` for both themes
- Wire `AppTextStyles` into `TextTheme` for both themes
- Set default font family to Plus Jakarta Sans
- Configure `InputDecorationTheme` using AppColors and AppRadius tokens
- Configure `AppBarTheme`, `BottomNavigationBarTheme`, `CardTheme`, `ChipTheme`, `ElevatedButtonTheme`
- Set scaffold background: light = #F8F9FC, dark = #0A0E1A
- Set divider color: light = #E5E7EB, dark = #1F2937
- Apply `ThemeMode.system` support via `MaterialApp`

### Out of Scope
- Individual widget components (AppButton, AppInput, etc.) — those are separate tasks
- Navigation bar widget (UI-P0-T16)
- App bar widget (UI-P0-T15)

---

## Technical Spec

### Files to Create
- `lib/core/theme/app_theme.dart` — ThemeData wiring

### Theme Configuration

**Light Theme:**
- `scaffoldBackgroundColor`: AppColors.scaffoldBg (#F8F9FC)
- `colorScheme`: ColorScheme.light with primary = AppColors.primary, accent/accent = AppColors.accent, error = AppColors.error, surface = AppColors.surface
- `textTheme`: Map heading1..label from AppTextStyles to appropriate TextTheme roles (displayLarge, headlineMedium, titleLarge, bodyLarge, bodyMedium, labelSmall, labelLarge, titleMedium)
- `appBarTheme`: backgroundColor = AppColors.primary, foregroundColor = Colors.white, elevation = 0
- `bottomNavigationBarTheme`: backgroundColor = AppColors.primary, selectedItemColor = AppColors.accent, unselectedItemColor = Colors.white.withOpacity(0.5)
- `cardTheme`: color = AppColors.surface, elevation = 0, shape = RoundedRectangleBorder(borderRadius = AppRadius.radiusLG)
- `inputDecorationTheme`: filled = true, fillColor = AppColors.surface, border radius = AppRadius.radiusMD, border color = AppColors.inputBorder, focusedBorderColor = AppColors.accent, errorBorderColor = AppColors.error
- `dividerColor`: AppColors.divider

**Dark Theme:**
- `scaffoldBackgroundColor`: AppColors.scaffoldBgDark (#0A0E1A)
- `colorScheme`: ColorScheme.dark with surface = AppColors.surfaceDark (#141C2E)
- Text colors: primary = white, secondary = AppColors.textSecondaryDark (#9CA3AF)
- Same structure as light theme but with dark overrides
- `inputDecorationTheme`: fillColor = AppColors.inputBgDark (#1A2236)

### Constraints
- Import only from `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`
- Do NOT import `google_fonts` directly in this file (text styles already handle font)
- Must not break existing screens that use `Theme.of(context)` — only change what `Theme.of(context)` returns

---

## Acceptance Criteria

- [ ] `lib/core/theme/app_theme.dart` exists with `AppTheme` class
- [ ] `AppTheme.lightTheme` returns a complete `ThemeData` for light mode
- [ ] `AppTheme.darkTheme` returns a complete `ThemeData` for dark mode
- [ ] Light scaffold background = #F8F9FC, dark scaffold background = #0A0E1A
- [ ] `ColorScheme` is populated from `AppColors` tokens for both themes
- [ ] `TextTheme` uses `AppTextStyles` tokens for both themes
- [ ] `AppBarTheme`, `CardTheme`, `InputDecorationTheme` configured with design tokens
- [ ] `BottomNavigationBarTheme` has primary background + accent selected color
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/theme/app_theme.dart`

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
- [ ] app_theme.dart exists — PENDING
- [ ] lightTheme returns complete ThemeData — PENDING
- [ ] darkTheme returns complete ThemeData — PENDING
- [ ] Scaffold backgrounds correct — PENDING
- [ ] ColorScheme populated from AppColors — PENDING
- [ ] TextTheme uses AppTextStyles — PENDING
- [ ] AppBarTheme, CardTheme, InputDecorationTheme configured — PENDING
- [ ] BottomNavigationBarTheme correct — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §2 §24 alignment: PENDING
- ui-migration-plan.md alignment: PENDING

### Rejection Reason
{}
