# Edit Profile Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T02 |
| Slug | edit-profile-screen |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Edit Profile screen — accessed from Profile Tab's "My Details" row. A form screen with Full Name, Phone Number, Date of Birth (date picker), and Address fields using `AppInput`. Profile photo at top with "Change Photo" overlay tap. "Save Changes" primary button sticky at bottom. Unsaved changes confirmation prompt on back navigation. Preserve existing profile update API logic, replace only the UI.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 9 (AppInput), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 18 (AppToast), 20 (AppDialog), 22 (Form Patterns), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.2 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Edit specification
- `docs/v2-decisions.md` — Patient data model
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/edit_profile_screen.dart` with V2 design system
- Form fields: Full Name, Phone Number, Date of Birth (date picker), Address
- Profile photo: circular avatar (100px) with "Change Photo" overlay tap
- "Save Changes" primary button sticky at bottom
- Unsaved changes: `AppDialog` confirmation before back navigation
- `AppSkeleton` shimmer during initial data load
- `AppErrorState` with retry on fetch/save failure
- `AppToast` success message after save
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- Photo upload/crop functionality (preserve existing logic, replace UI only)
- Email or NRIC editing (read-only fields per existing rules)
- Password change (Phase 8.3 — separate task)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/edit_profile_screen.dart` — Create new edit profile screen

### API Endpoints
- Existing profile update endpoint via Laravel proxy (preserve existing API call logic)

### Data / Schema
- `FFAppState().userData` or equivalent patient data
- Fields: fullName, phoneNumber, dateOfBirth, address, photoUrl

### UI Components
- `AppAppBar` (sub-page variant) — "Edit Profile" title, back arrow
- `AppInput` — Full Name, Phone Number, Address fields with validation
- Date picker — open date bottom sheet, display formatted `dd MMM yyyy`
- `CircleAvatar` (100px) with photo/initials + "Change Photo" overlay
- `AppButton` primary — "Save Changes" (sticky bottom)
- `AppDialog` — confirmation before back navigation with unsaved changes
- `AppSkeleton` — shimmer while loading profile data
- `AppErrorState` — error icon + retry on fetch/save failure
- `AppToast` — success message "Profile updated successfully"

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Form validation on blur, not keystroke
- Submit button disabled until all required fields valid
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/profile/edit_profile_screen.dart`
- [ ] Form fields: Full Name, Phone Number, Date of Birth, Address — all using `AppInput`
- [ ] Profile photo circle (100px) with "Change Photo" overlay tap visible
- [ ] Date of Birth uses date picker bottom sheet, displayed as `dd MMM yyyy`
- [ ] "Save Changes" primary button sticky at bottom, disabled until valid
- [ ] Unsaved changes: `AppDialog` confirmation on back navigation attempt
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppErrorState` rendered with retry on failure
- [ ] `AppToast` success shown after successful save
- [ ] Form validates on blur — error border/message for invalid inputs
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold background `#0A0E1A`, surface `#141C2E`, correct text colors
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

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


### Failure Details



---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check


### Rejection Reason

