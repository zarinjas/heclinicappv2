# AppTextStyles — Typography Tokens

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T02 |
| Slug | app-text-styles |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 2 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P0-T01 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/theme/app_text_styles.dart` defining all 8 typography styles from the UI Design System §3. All text in the app must use these styles via `AppTextStyles.heading1`, `AppTextStyles.body1`, etc. Uses Plus Jakarta Sans via `GoogleFonts.plusJakartaSans()`.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §3 Typography (lines 81–118)
- `docs/ui-migration-plan.md` — Phase 0 item 0.2 (line 29)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T02
- `docs/v2-ux-spec.md` — typography usage context

---

## Scope

### In Scope
- Create `lib/core/theme/app_text_styles.dart` with `AppTextStyles` utility class
- Define all 8 styles: `heading1`, `heading2`, `heading3`, `body1`, `body2`, `caption`, `button`, `label`
- Use `GoogleFonts.plusJakartaSans()` for each style (package already in pubspec: `google_fonts: ^6.2.1`)
- Match exact size, weight, and line height from the type scale table in §3
- All styles as `static const TextStyle`

### Out of Scope
- ThemeData TextStyle wiring (UI-P0-T04)
- Any widget implementation
- Font file registration (font is loaded by GoogleFonts package at runtime)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/theme/app_text_styles.dart` — create file with AppTextStyles class

### Type Scale Reference

| Token | Size | Weight | Line Height |
|-------|------|--------|-------------|
| `heading1` | 24px | w700 | 1.2 |
| `heading2` | 20px | w700 | 1.25 |
| `heading3` | 16px | w600 | 1.3 |
| `body1` | 14px | w400 | 1.5 |
| `body2` | 12px | w400 | 1.5 |
| `caption` | 10px | w500 | 1.4 |
| `button` | 15px | w600 | 1.0 |
| `label` | 13px | w500 | 1.0 |

### API Endpoints
N/A

### Constraints
- Import `google_fonts/google_fonts.dart` and `flutter/widgets.dart`
- static const cannot use GoogleFonts (GoogleFonts returns TextStyle through non-const). Use `static TextStyle get` (computed getter) or `static final` pattern that matches Flutter conventions
- Font family fallback: system sans-serif (handled by GoogleFonts)

---

## Acceptance Criteria

- [ ] `lib/core/theme/app_text_styles.dart` exists with `AppTextStyles` class
- [ ] All 8 styles defined: `heading1`, `heading2`, `heading3`, `body1`, `body2`, `caption`, `button`, `label`
- [ ] Each style uses `GoogleFonts.plusJakartaSans()` with correct fontSize, fontWeight, height
- [ ] `heading1`: 24px, w700, height 1.2
- [ ] `heading2`: 20px, w700, height 1.25
- [ ] `heading3`: 16px, w600, height 1.3
- [ ] `body1`: 14px, w400, height 1.5
- [ ] `body2`: 12px, w400, height 1.5
- [ ] `caption`: 10px, w500, height 1.4
- [ ] `button`: 15px, w600, height 1.0
- [ ] `label`: 13px, w500, height 1.0
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/theme/app_text_styles.dart`

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
- [ ] AppTextStyles class exists — PENDING
- [ ] All 8 styles defined — PENDING
- [ ] Uses GoogleFonts.plusJakartaSans() — PENDING
- [ ] heading1 correct — PENDING
- [ ] heading2 correct — PENDING
- [ ] heading3 correct — PENDING
- [ ] body1 correct — PENDING
- [ ] body2 correct — PENDING
- [ ] caption correct — PENDING
- [ ] button correct — PENDING
- [ ] label correct — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §3 alignment: PENDING
- ui-migration-plan.md alignment: PENDING

### Rejection Reason
{}
