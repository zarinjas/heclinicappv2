# OtpInputRow Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T10 |
| Slug | otp-input-row |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 10 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `OtpInputRow` reusable component for OTP code entry. Used in Forgot Password Step 2 (OTP verification). Displays 6 individual digit boxes with auto-advance on digit entry and backspace support.

---

## Context

- `docs/ui-design-system.md` — §9 (Input Fields — Special Input Types: OTP), §22 (Form Patterns)
- `docs/ui-migration-plan.md` — Phase 1, §1.10 (OtpInputRow), Phase 2 (Auth — Forgot Password OTP)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/otp_input_row.dart` — new file
- 6 individual OTP boxes: 48×52px each, evenly spaced
- Box style: `radiusMD` (12px) border, surface background
- Border states: rest (`#E5E7EB`), focus (`AppColors.accent`), filled (accent border), error (`AppColors.error`)
- Auto-advance focus to next box on digit entry
- Backspace moves focus to previous box
- Paste support for full OTP code
- `TextInputType.number` keyboard
- Callback `onCompleted(String otp)` when all 6 digits filled
- Callback `onChanged(String currentValue)` for partial input tracking

### Out of Scope
- OTP verification API call (handled by parent screen)
- Timer/countdown display (handled by parent)
- Resend OTP button (handled by parent)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/otp_input_row.dart` — new file

### Design Spec (from ui-design-system.md §9)
- Box size: 48×52px each
- Border radius: `AppRadius.md` (12px)
- 6 boxes total
- Auto-advance on digit entry
- Background: surface color
- Text: heading3 style, centered

### Constraints
- Design tokens only (AppColors, AppRadius, AppSpacing, AppTextStyles)
- Dark mode support
- Keyboard type: number
- Obscuring character display (show digits, not dots)

---

## Acceptance Criteria

- [ ] 6 OTP boxes render as 48×52px each with 12px border radius, evenly spaced
- [ ] Focused box shows accent-colored border; unfilled boxes show #E5E7EB border
- [ ] Entering a digit auto-advances focus to the next box
- [ ] Backspace on empty box moves focus back to previous box and clears it
- [ ] Pasting a 6-digit code fills all boxes correctly
- [ ] `onCompleted` callback fires with full OTP string when all 6 digits are entered
- [ ] `onChanged` callback fires with partial value on each input change
- [ ] Error state renders with error-colored borders on all boxes
- [ ] Dark mode renders boxes with correct surface/dark bg colors
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
