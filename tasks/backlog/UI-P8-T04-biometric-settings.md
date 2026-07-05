# Biometric Settings Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T04 |
| Slug | biometric-settings |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Biometric Settings screen — accessed from Profile Tab's "Biometric Login" row. A settings screen with biometric enable/disable toggle, biometric type indicator (fingerprint/face), and explanatory text. Preserve existing `local_auth` logic from old biometric page — replace only the UI with design system components. Include loading, error, and empty states.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.4 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Tab — Biometric Login toggle
- `docs/v2-decisions.md` — Auth flow, biometric
- `docs/design-system-v2.png` — Visual target reference
- `CODEBASE.md` — Existing `local_auth` implementation

---

## Scope

### In Scope
- Create `lib/features/profile/biometric_screen.dart` with V2 design system
- Biometric enable/disable `Switch` toggle using design system colors
- Biometric type indicator: icon + label showing fingerprint or face
- Explanatory text describing biometric login behavior
- Preserve existing `local_auth` logic (availability check, enrol, toggle)
- `AppSkeleton` shimmer during initial biometric availability check
- `AppErrorState` if biometric hardware unavailable
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- Biometric enrollment during login flow (Phase 2 — already done)
- Backend biometric storage (existing logic preserved)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/biometric_screen.dart` — Create new biometric settings screen

### API Endpoints
- Local device: `local_auth` package — `isDeviceSupported()`, `canCheckBiometrics`, `getAvailableBiometrics()`
- Existing FFAppState or SharedPreferences toggle for biometric enabled status

### Data / Schema
- Biometric enabled: boolean (SharedPreferences or FFAppState)
- Biometric types: `BiometricType.fingerprint`, `BiometricType.face`

### UI Components
- `AppAppBar` (sub-page variant) — "Biometric Login" title, back arrow
- `AppCard` — settings card containing toggle row
- `Switch` — accent-colored toggle for enable/disable
- Icon + label row — fingerprint/face icon with type name
- Explanatory text — `body1`, `textSecondary`
- `AppSkeleton` — shimmer during biometric availability check
- `AppErrorState` — "Biometric not available" with explanation
- `AppToast` — confirm enable/disable action

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- Preserve existing `local_auth` business logic intact
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/profile/biometric_screen.dart`
- [ ] Biometric enable/disable `Switch` toggle functional
- [ ] Biometric type indicator: icon + label (fingerprint or face) displayed
- [ ] Explanatory text describing biometric login behavior visible
- [ ] Toggle reads/writes existing biometric preference storage
- [ ] `AppSkeleton` shimmer shown during initial biometric check
- [ ] `AppErrorState` rendered if biometric hardware unavailable
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold background `#0A0E1A`, surface `#141C2E`, correct text colors
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] Existing `local_auth` logic preserved
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

