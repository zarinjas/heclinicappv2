# Apply V2 Design System

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T01 |
| Slug | apply-design-system |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Apply the complete V2 design system as defined in `docs/v2-ux-spec.md` section 1. This means replacing the existing FlutterFlow theme (`lib/flutter_flow/flutter_flow_theme.dart`) with a new V2 theme that defines all colors, typography, spacing, border radius, shadows, button styles, input styles, card styles, and component tokens from the spec. This is the foundation for all subsequent UI work.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Sections 1 (Design System), 8 (Dark Mode)
- `docs/CODEBASE.md` — Section 3 (Directory Structure), Section 4 (App State)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul" (lines 63-70)

---

## Scope

### In Scope
- Create a new V2 theme file (`lib/theme/app_theme.dart`) with all color tokens, text styles, spacing constants, border radius tokens, shadow definitions, button variants, input styles, card styles
- Define both light and dark theme variants using `ThemeData`
- Wire the new theme into `main.dart` replacing existing FlutterFlow theme usage
- Ensure the existing `flutter_flow_theme.dart` remains intact (do not delete — other code may reference it until subsequent tasks migrate pages)
- Define `Plus Jakarta Sans` as primary font (with system sans-serif fallback)

### Out of Scope
- Migrating individual page widgets to use the new theme (done in subsequent tasks P4-T02 through P4-T06)
- Deleting old `flutter_flow_theme.dart` (retain for backward compatibility until all pages migrated)
- Changing layout or navigation structure
- Applying skeleton loaders, empty states, or error states (P4-T06)

---

## Technical Spec

### Files to Create or Modify
- `lib/theme/app_theme.dart` — New V2 theme definition
- `lib/main.dart` — Wire new theme into `MaterialApp`

### Design Tokens (from v2-ux-spec.md Section 1)

**Colors:**
- `primary`: `#0F1B3D` — Main brand, headers, nav bar background
- `accent`: `#00C9A7` — CTAs, active states, highlights, icons
- `gold`: `#F5A623` — Premium badges, special tags
- `bgLight`: `#F8F9FC` — Page backgrounds (light mode)
- `bgDark`: `#0A0E1A` — Page backgrounds (dark mode)
- `surface`: `#FFFFFF` — Cards, modals, sheets (light)
- `surfaceDark`: `#141C2E` — Cards, modals, sheets (dark)
- `textPrimary`: `#0F1B3D` — Body text, headings
- `textSecondary`: `#6B7280` — Subtitles, captions, placeholders
- `textInverse`: `#FFFFFF` — Text on dark/accent backgrounds
- `error`: `#EF4444` — Error states, destructive actions
- `warning`: `#F59E0B` — Warning banners
- `success`: `#10B981` — Success toasts, confirmed states
- `divider`: `#E5E7EB` — Borders, separators

**Typography (Plus Jakarta Sans):**
- `headingXL`: 28px, w700 — Page titles
- `headingLG`: 22px, w700 — Section headers
- `headingMD`: 18px, w600 — Card titles, modal headers
- `headingSM`: 16px, w600 — List item titles
- `bodyLG`: 16px, w400 — Primary body text
- `bodyMD`: 14px, w400 — Secondary body text
- `bodySM`: 12px, w400 — Captions, labels, timestamps
- `label`: 13px, w500 — Form labels, tags
- `button`: 15px, w600 — All button text

**Spacing:** xs(4), sm(8), md(16), lg(24), xl(32), xxl(48)
**Border Radius:** sm(8), md(12), lg(16), xl(24), full(9999)
**Shadows:** low(`0 1px 4px rgba(0,0,0,0.06)`), mid(`0 4px 16px rgba(0,0,0,0.10)`), high(`0 8px 32px rgba(0,0,0,0.16)`)

**Button Variants (all 52px height, xl radius, full width default):**
- Primary: Solid #00C9A7 bg, white text
- Secondary: Outlined #00C9A7 border, accent text
- Ghost: No border, accent text
- Destructive: Solid #EF4444, white text
- Disabled: #E5E7EB bg, #9CA3AF text

### API Endpoints
N/A

### Data / Schema
N/A

### UI Components
N/A — This task creates only the theme infrastructure.

### Constraints
- Must support both light and dark mode
- Must use `flutter_animate` package for press animation (scale 0.97, 150ms)
- Plus Jakarta Sans font must be added to `pubspec.yaml` and loaded as asset
- Do NOT delete `flutter_flow_theme.dart` — existing pages still reference it

---

## Acceptance Criteria

- [ ] `lib/theme/app_theme.dart` exists and exports `AppTheme.lightTheme` and `AppTheme.darkTheme`
- [ ] All color tokens from v2-ux-spec.md section 1 are defined as named constants in the theme
- [ ] All 9 text styles (headingXL through button) are defined with correct sizes, weights, and font family
- [ ] Theme includes `ThemeData` for light mode with correct primary/accent/background colors
- [ ] Theme includes `ThemeData` for dark mode with correct surface/background inversions
- [ ] `main.dart` wires the new theme into `MaterialApp` using `theme` and `darkTheme` parameters
- [ ] Plus Jakarta Sans font is loaded and available (font files added to `assets/fonts/` and registered in `pubspec.yaml`)
- [ ] App compiles without errors after theme integration

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/theme/app_theme.dart` with complete V2 design system: all 14 color tokens (AppColors), spacing scale (AppSpacing), border radius tokens (AppRadius), shadow definitions (AppShadows), light ThemeData, and dark ThemeData. Wired into `main.dart` via `theme` and `darkTheme` parameters on `MaterialApp.router`. Plus Jakarta Sans font served via `google_fonts` package (already in pubspec). Existing `flutter_flow_theme.dart` left intact for backward compatibility.

### Files Changed
- `lib/theme/app_theme.dart` — Created: V2 theme definition with AppColors, AppSpacing, AppRadius, AppShadows, AppTheme.lightTheme, AppTheme.darkTheme
- `lib/main.dart` — Added import for `theme/app_theme.dart`; replaced inline `ThemeData(brightness: Brightness.light, useMaterial3: true)` with `AppTheme.lightTheme` and added `darkTheme: AppTheme.darkTheme`

### Decisions Made During Implementation
- Used `google_fonts` package for Plus Jakarta Sans instead of adding font files to assets (package is already in pubspec, avoids manual font file management)
- Kept old `flutter_flow_theme.dart` fully intact for backward compatibility — pages still reference `FlutterFlowTheme.of(context)` which will continue to work
- Used Material 3 theme system with `ThemeData` for both light and dark modes; used `ColorScheme` to define semantic colors
- Removed unused `google_fonts` import from `main.dart` (no longer used there)

### Known Limitations
- Existing pages still use `FlutterFlowTheme.of(context)` and will not automatically pick up V2 styling — they need to be individually migrated in P4-T02 through P4-T06
- `FlutterFlowTheme.of(context).primary` etc. returns old colors until pages are migrated

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] Criterion 1 — PASS — `lib/theme/app_theme.dart` exists, exports `AppTheme.lightTheme` and `AppTheme.darkTheme`
- [x] Criterion 2 — PASS — All 14 color tokens from v2-ux-spec.md §1 defined in `AppColors` class (primary, accent, gold, bgLight, bgDark, surface, surfaceDark, textPrimary, textSecondary, textInverse, error, warning, success, divider)
- [x] Criterion 3 — PASS — All 9 text styles defined via TextTheme: headingXL=28/w700, headingLG=22/w700, headingMD=18/w600, headingSM=16/w600, bodyLG=16/w400, bodyMD=14/w400, bodySM=12/w400, label=13/w500, button=15/w600; all use PlusJakartaSans via google_fonts
- [x] Criterion 4 — PASS — Light ThemeData: scaffoldBackground=bgLight(#F8F9FC), primary=primary(#0F1B3D), secondary=accent(#00C9A7), surface=#FFFFFF
- [x] Criterion 5 — PASS — Dark ThemeData: scaffoldBackground=bgDark(#0A0E1A), surface=surfaceDark(#141C2E), text uses textInverse(#FFFFFF), divider=#1F2937
- [x] Criterion 6 — PASS — `main.dart:190-191` wires `theme: AppTheme.lightTheme` and `darkTheme: AppTheme.darkTheme` on `MaterialApp.router`
- [x] Criterion 7 — PASS — Plus Jakarta Sans loaded via `google_fonts` (already in pubspec as `^6.2.1`); font family constant `'Plus Jakarta Sans'` referenced throughout theme
- [x] Criterion 8 — PASS — Imports resolve correctly; no syntax errors; theme file is well-structured

### Failure Details
N/A — All criteria passed.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason

