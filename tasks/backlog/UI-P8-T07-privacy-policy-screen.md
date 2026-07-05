# Privacy Policy Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P8-T07 |
| Slug | privacy-policy-screen |
| Process | Epic: UI Migration — Phase 8 |
| Process Step | Step 8.7 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Privacy Policy screen — accessed from Profile Tab's About section. A scrollable rich text content screen displaying the clinic's privacy policy. Replaces the old `info_page/` privacy policy view. Uses `AppAppBar` (sub-page variant), `AppCard` for content container, `AppSkeleton` shimmer while loading content, and `AppErrorState` on fetch failure. Content sourced from existing CMS/API endpoint.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 8.7 (lines 203–221)
- `docs/v2-ux-spec.md` — Profile Tab — Privacy Policy
- `docs/v2-decisions.md` — CMS content
- `docs/design-system-v2.png` — Visual target reference

---

## Scope

### In Scope
- Create `lib/features/profile/privacy_screen.dart` with V2 design system
- Scrollable rich text or HTML content display
- App bar: "Privacy Policy" title, back arrow
- Content loaded from existing CMS content API (or static content fallback)
- `AppSkeleton` shimmer during content load
- `AppErrorState` with retry on fetch failure
- Support dark mode
- Remove all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles

### Out of Scope
- Profile screen shell (Phase 8.1 — separate task)
- Privacy policy content editing (CMS admin — already done)
- Terms of Service (Phase 8.8 — separate task)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/profile/privacy_screen.dart` — Create new privacy policy screen

### API Endpoints
- Existing CMS content endpoint for privacy policy (or static text fallback)

### Data / Schema
- Privacy policy: title (String), body (String/HTML), lastUpdated (DateTime)

### UI Components
- `AppAppBar` (sub-page variant) — "Privacy Policy" title, back arrow
- `AppCard` — content container with padding
- Rich text renderer — HTML content to Flutter widgets (existing `flutter_html` or TextStyle mapping)
- `AppSkeleton` — shimmer text blocks during content load
- `AppErrorState` — error icon + retry on fetch failure

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

- [ ] Screen renders at `lib/features/profile/privacy_screen.dart`
- [ ] "Privacy Policy" title in `AppAppBar` with back arrow
- [ ] Scrollable content area with privacy policy text
- [ ] Content loaded from CMS API or static fallback
- [ ] `AppSkeleton` shimmer shown during content load
- [ ] `AppErrorState` rendered with retry on fetch failure
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

