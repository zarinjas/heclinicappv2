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
| Assigned Date |  |
| Status | BACKLOG |
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


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {Criterion 1} — PASS / FAIL — {note if fail}
- [ ] {Criterion 2} — PASS / FAIL — {note if fail}
- [ ] {Criterion 3} — PASS / FAIL — {note if fail}

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason

