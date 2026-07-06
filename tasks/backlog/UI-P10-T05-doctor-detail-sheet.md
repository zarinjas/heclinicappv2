# Doctor Detail Bottom Sheet

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T05 |
| Slug | doctor-detail-sheet |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | N/A |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Doctor Detail Bottom Sheet — a reusable `AppBottomSheet` variant that shows doctor profile info (photo, name, specialty, branch, bio) with a "Book Appointment" CTA button. Replaces 24 hardcoded doctor modals in `component/` directory. Triggered by tapping a DoctorCard from Home, Doctor List, or Booking Step 2.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 19 (AppBottomSheet), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.5 (lines 253–254)
- `docs/v2-ux-spec.md` — Doctor Detail Bottom Sheet (lines 654–669)
- `docs/v2-decisions.md` — Doctor Management (§390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `telehealth/` existing reference (line 188)

---

## Scope

### In Scope
- Create `lib/features/doctors/doctor_detail_sheet.dart` — Doctor Detail Bottom Sheet widget
- Doctor photo (100px circle, centered), placeholder if no photo using AppColors
- Doctor name (heading-md, centered)
- Specialty (body-md, text-secondary, centered)
- Branch name (body-sm, text-secondary, centered)
- About section: bio text (body-md)
- "Book Appointment" primary button (full width) — navigates to booking flow
- `AppBottomSheet` wrapper with handle bar and spring animation
- Support dark mode
- Function signature accepting a Doctor model/object

### Out of Scope
- All Doctors List screen (Phase 10.6 — separate task)
- CMS backend CRUD for doctor profiles (already DONE — Process 9)
- Registering route in GoRouter (Phase 12)
- Deleting 24 old hardcoded doctor modals (Phase 13 legacy cleanup)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/doctors/doctor_detail_sheet.dart` — Create Doctor Detail Bottom Sheet

### API Endpoints
- Doctor data passed via constructor (data already fetched by parent screen)

### Data / Schema
- Doctor: id, full_name, specialty, branch_name, bio, photo_url, branch_id, is_visible_in_app

### UI Components
- `AppBottomSheet` wrapper — handle bar + spring animation
- Doctor photo — `CircleAvatar` (100px, `AppColors.surface` bg fallback)
- Name — `AppTextStyles.heading3`
- Specialty + Branch — `AppTextStyles.body2`, `AppColors.textSecondary`
- Bio section — `AppTextStyles.body1`
- `AppButton.primary` — "Book Appointment" full width
- Dark mode support throughout

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Reusable — accepts Doctor model parameter, not hardcoded data
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Widget defined at `lib/features/doctors/doctor_detail_sheet.dart`
- [ ] `AppBottomSheet` wrapper with handle bar and spring animation
- [ ] Doctor photo: 100px `CircleAvatar`, centered, placeholder if no photo URL
- [ ] Doctor name: heading-md, centered
- [ ] Specialty: body-md, text-secondary, centered
- [ ] Branch name: body-sm, text-secondary, centered
- [ ] About section with bio text in body-md
- [ ] "Book Appointment" `AppButton.primary` (full width) visible
- [ ] Accepts Doctor model parameter (not hardcoded data)
- [ ] Dark mode: correct background and text colors
- [ ] All colors use `AppColors` tokens
- [ ] All typography uses `AppTextStyles`
- [ ] All spacing uses `AppSpacing` constants
- [ ] Zero `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled by developer}

### Files Changed
- {To be filled by developer}

### Decisions Made During Implementation
{To be filled by developer}

### Known Limitations
{To be filled by developer}

---

## QA Notes

> Filled in by QA after verification.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] {Criterion} — {PASS / FAIL} — {note}

### Failure Details
{If FAILED: describe what was wrong.}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}
- ui-design-system.md compliance: {YES / NO} — {note}

### Rejection Reason
{If REJECTED: describe specific deviation.}
