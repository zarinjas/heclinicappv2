# AppSpacing + AppRadius + AppShadows — Dimensional Tokens

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T03 |
| Slug | app-spacing-radius-shadows |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 3 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Create three token files for all dimensional constants defined in the UI Design System: `app_spacing.dart` (§4), `app_radius.dart` (§5), and `app_shadows.dart` (§6). These are the spatial foundation tokens — no screen or widget may use hardcoded pixel values.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §4 Spacing Scale (lines 122–139), §5 Border Radius (lines 142–153), §6 Shadows (lines 157–164)
- `docs/ui-migration-plan.md` — Phase 0 item 0.3 (line 30)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T03

---

## Scope

### In Scope
- Create `lib/core/theme/app_spacing.dart` with `AppSpacing` class containing all 9 spacing constants (§4)
- Create `lib/core/theme/app_radius.dart` with `AppRadius` class containing all 7 radius constants (§5)
- Create `lib/core/theme/app_shadows.dart` with `AppShadows` class containing all 4 shadow constants (§6)
- All spacing values as `static const double`
- All radius values as `static const double`
- All shadows as `static const BoxShadow` or `static const List<BoxShadow>`

### Out of Scope
- ThemeData wiring (UI-P0-T04)
- Any widget implementation

---

## Technical Spec

### Files to Create
- `lib/core/theme/app_spacing.dart` — spacing scale constants
- `lib/core/theme/app_radius.dart` — border radius constants
- `lib/core/theme/app_shadows.dart` — box shadow constants

### Spacing Scale (§4)
| Token | Value | Usage |
|-------|-------|-------|
| `space2` | 2.0 | Micro gaps |
| `space4` | 4.0 | xs — icon-to-label gap |
| `space8` | 8.0 | sm — tight rows |
| `space12` | 12.0 | Between form field and label |
| `space16` | 16.0 | md — standard screen padding |
| `space20` | 20.0 | Section inner padding |
| `space24` | 24.0 | lg — section spacing |
| `space32` | 32.0 | xl — large section breaks |
| `space48` | 48.0 | 2xl — hero sections |

### Border Radius (§5)
| Token | Value |
|-------|-------|
| `radiusXS` | 4.0 |
| `radiusSM` | 8.0 |
| `radiusMD` | 12.0 |
| `radiusLG` | 16.0 |
| `radiusXL` | 24.0 |
| `radius2XL` | 32.0 |
| `radiusFull` | 9999.0 |

### Shadows (§6)
| Token | CSS Equivalent |
|-------|---------------|
| `shadowLow` | 0 1px 4px rgba(0,0,0,0.06) |
| `shadowMid` | 0 4px 16px rgba(0,0,0,0.10) |
| `shadowHigh` | 0 8px 32px rgba(0,0,0,0.16) |
| `shadowNav` | 0 -2px 12px rgba(0,0,0,0.08) |

### Constraints
- Import `dart:ui` for `Color`, `Offset`
- BoxShadow requires: `color`, `offset`, `blurRadius`, `spreadRadius`
- `shadowNav` has a negative y offset (0, -2)

---

## Acceptance Criteria

- [ ] `lib/core/theme/app_spacing.dart` exists with all 9 spacing constants as `static const double`
- [ ] `lib/core/theme/app_radius.dart` exists with all 7 radius constants as `static const double`
- [ ] `lib/core/theme/app_shadows.dart` exists with all 4 shadow constants
- [ ] `space16` = 16.0 (standard screen padding), `space24` = 24.0
- [ ] `radiusLG` = 16.0 (cards), `radiusXL` = 24.0 (buttons)
- [ ] `shadowLow` matches spec: offset(0,1), blur 4, opacity 0.06
- [ ] `shadowNav` has correct negative y offset
- [ ] `flutter analyze` passes with zero errors on all three files

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radius.dart`
- `lib/core/theme/app_shadows.dart`

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
- [ ] app_spacing.dart exists with 9 constants — PENDING
- [ ] app_radius.dart exists with 7 constants — PENDING
- [ ] app_shadows.dart exists with 4 shadows — PENDING
- [ ] space16 and space24 correct — PENDING
- [ ] radiusLG and radiusXL correct — PENDING
- [ ] shadowLow matches spec — PENDING
- [ ] shadowNav has negative y offset — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §4 §5 §6 alignment: PENDING
- ui-migration-plan.md alignment: PENDING

### Rejection Reason
{}
