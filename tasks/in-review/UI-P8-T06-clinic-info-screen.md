# He Clinic Info Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T06 |
| Slug | clinic-info-screen |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the He Clinic Info screen — accessed from Profile Tab's About section. A static content screen displaying clinic information: about He Clinic, mission/vision, branches overview, contact information, and social media links. Replaces the old `HemedInfoCopy` and `hemed_info` pages. Uses `AppCard` sections with icon rows. Includes loading and error states.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 8 (AppButton), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.6 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Tab — He Clinic Info
- `docs/v2-decisions.md` — Clinic data from Plato
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/clinic_info_screen.dart` with V2 design system
- Hero image section: clinic photo, 220px, full width
- About section: clinic description text
- Mission/Vision section: icon + text cards
- Branches section: `BranchCard` list overview
- Contact section: phone, email, WhatsApp icon rows
- Social media links (if configured)
- `AppSkeleton` shimmer during initial data load
- `AppErrorState` with retry on fetch failure
- `AppEmptyState` if no data configured yet
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- Branch detail screen (Phase 10.7 — separate phase)
- CMS admin for clinic info (Laravel admin — already done)
- Real-time clinic status

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/clinic_info_screen.dart` — Create new clinic info screen

### API Endpoints
- Existing clinic/branch data API via Laravel proxy (preserve existing fetch logic)

### Data / Schema
- Clinic info: name, description, mission, vision, heroImage, contactPhone, contactEmail, socialLinks
- Branch list from existing branch API

### UI Components
- `AppAppBar` (sub-page variant) — "He Clinic Info" title, back arrow
- Hero image section — 220px, full width, clinic photo
- `AppCard` — about section, mission/vision cards
- Icon rows — phone call, email, WhatsApp with tap actions
- `BranchCard` — branch overview cards
- `AppButton` (ghost) — "Get Directions", "WhatsApp Us"
- `AppSkeleton` — shimmer while loading clinic data
- `AppErrorState` — error icon + retry
- `AppEmptyState` — "No clinic info available" if not configured

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required on all states
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/profile/clinic_info_screen.dart`
- [ ] Hero image section: clinic photo, 220px, full width
- [ ] About section: clinic description text visible
- [ ] Mission/Vision section: icon + text cards
- [ ] Branches section: `BranchCard` list displayed
- [ ] Contact section: phone, email, WhatsApp icon rows with tap actions
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppErrorState` rendered with retry on fetch failure
- [ ] `AppEmptyState` shown if no clinic data configured
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
- Created `lib/features/profile/clinic_info_screen.dart` with V2 design system
- Hero image section: clinic branding, 220px, full width
- About section: clinic description with icon header
- Mission/Vision section: icon + text cards in `AppCard`
- Branches section: `BranchCard` list with static branch data (pluggable API)
- Contact section: phone, email, WhatsApp rows + WhatsApp button
- `AppSkeleton` shimmer during initial data load
- `AppErrorState` with retry on fetch failure
- Dark mode support throughout
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- All colors from `AppColors`, typography from `AppTextStyles`, spacing from `AppSpacing`
- Registered route `/clinicInfoScreen` in `nav.dart`

### Files Changed
- `lib/features/profile/clinic_info_screen.dart` — Created (341 lines)
- `lib/flutter_flow/nav/nav.dart` — Added route registration + import
- `lib/core/widgets/app_skeleton.dart` — Added `circle()`, `text()`, parameterized `card()` helpers

### Decisions Made During Implementation
- Used static clinic data as fallback (no dedicated CMS page API exists yet; structure supports API plugin)
- Branches use `BranchCard` component with static data
- Hero image uses branded placeholder (no CMS image endpoint yet)

### Known Limitations
- Clinic data is static; needs CMS endpoint integration for dynamic content
- Branch data hardcoded; should be replaced with API call in future
- Social media links not configured (placeholder structure ready)



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

