# Home Screen (Shell)

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T01 |
| Slug | home-screen |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A (Phase 0, Phase 1 DONE) |
| Blocked Reason | N/A |

---

## Description

Rebuild the Home Screen shell (`lib/features/home/home_screen.dart`) from the existing `front_page/homepage_new/` implementation. Replace all FlutterFlow styling with the V2 design system. The home screen is the central hub — it hosts the greeting header, hero slider section, quick actions, upcoming appointment, loyalty card, doctors section, articles section, and videos section. Business logic, API calls, and state management are preserved. Only UI is replaced.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §3 (Typography), §4 (Spacing), §5 (Radius), §6 (Shadows), §13 (AppBar)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Home screen UX
- `docs/CODEBASE.md` — existing homepage structure

---

## Scope

### In Scope
- Create `lib/features/home/home_screen.dart` with full home screen scaffold
- Implement greeting header: "Good morning/evening, {Name}" using `AppTextStyles.heading1` + `AppColors.primary`
- Set up `RefreshIndicator` + `CustomScrollView` with `SliverList` sections
- Wire all section slots: hero slider, quick actions, upcoming appointment, loyalty, doctors, articles, videos
- Apply `AppColors.background` (`#F8F9FC` light / `#0A0E1A` dark) as scaffold background
- Import and layout all Phase 1 reusable components (HeroSlider, QuickActionGrid, AppointmentCard, LoyaltyCard, DoctorCard, ArticleCard, VideoCard, SectionHeader)
- Apply `SafeArea` and top padding at greeting section
- Greeting text color: `AppColors.primary` on light, `AppColors.surface` on dark
- Preserve user data loading: `FFAppState().userData` for patient name

### Out of Scope
- Hero slider internal logic (UI-P3-T02)
- Quick actions internal logic (UI-P3-T03)
- Appointment card display logic (UI-P3-T04)
- Loyalty section logic (UI-P3-T05)
- Doctors section logic (UI-P3-T06)
- Articles section logic (UI-P3-T07)
- Videos section logic (UI-P3-T08)
- Bottom navigation (already handled by AppNavBar, Phase 0)
- Notification icon bell logic (keep existing)
- Deep link handling

---

## Technical Spec

### Files to Create or Modify
- `lib/features/home/home_screen.dart` — Create new home screen shell
- `lib/main.dart` — Update route to use new home screen (if nav routing changed)

### API Endpoints
- N/A (shell only — sections handle their own data fetching)

### Data / Schema
- `FFAppState().userData` — patient name for greeting
- `AppColors`, `AppTextStyles`, `AppSpacing` — all design tokens

### UI Components
- `AppAppBar` (or custom greeting header)
- `SectionHeader` — for each section title + "See All" tap
- `HeroSlider` — slot for UI-P3-T02
- `QuickActionGrid` — slot for UI-P3-T03
- `AppointmentCard` — slot for UI-P3-T04
- `LoyaltyCard` — slot for UI-P3-T05
- `DoctorCard` — slot for UI-P3-T06
- `ArticleCard` — slot for UI-P3-T07
- `VideoCard` — slot for UI-P3-T08

### Constraints
- All styling must use design tokens (no hardcoded hex colors, font sizes, spacing)
- Dark mode must work (test `ThemeMode.dark`)
- Business logic from existing homepage must be preserved

---

## Acceptance Criteria

- [ ] Home screen renders with greeting "Good morning/evening, {Name}" in correct typography and color
- [ ] Scaffold background is `#F8F9FC` in light mode and `#0A0E1A` in dark mode
- [ ] All 8 section slots are present in correct order: greeting → hero slider → quick actions → upcoming appointment → loyalty → doctors → articles → videos
- [ ] Each section uses `SectionHeader` component with title and "See All" tap
- [ ] Greeting text uses `AppTextStyles.heading1` (no hardcoded TextStyle)
- [ ] `RefreshIndicator` on the scroll view triggers a refresh
- [ ] No `FlutterFlowTheme.of(context)` or `FFButtonWidget` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/features/home/home_screen.dart` - a complete rebuild of the home screen shell using V2 design system. Replaced `HomepageNewWidget` with `HomeScreen` in `lib/main.dart` NavBarPage. The new home screen preserves all business logic from the existing implementation: profile loading, slider fetching, upcoming appointment, articles, and videos. All FlutterFlow styling replaced with `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows` tokens. All section slots wired: greeting header, hero slider (using `HeroSlider` + `HeroSliderSkeleton`), quick actions (using `QuickActionGrid`), loyalty points (using `LoyaltyCard` compact variant), upcoming appointment (using `AppointmentCard`), doctors (using `DoctorListWidget`), articles (using `ArticleCard`), and videos (using `VideoCard`). Dark mode supported throughout via `Theme.of(context).brightness` checks. `AppAppBar.main` used for the app bar with notification badge. `RefreshIndicator` wraps the `SingleChildScrollView`. `AppEmptyState` and `AppErrorState` used for empty/error cases in each section._

### Files Changed
- `lib/features/home/home_screen.dart` — Created (new V2 home screen shell with all 8 section slots)
- `lib/main.dart` — Updated NavBarPage home tab from `HomepageNewWidget()` to `HomeScreen()`
- `lib/index.dart` — Added export for `HomeScreen`

### Decisions Made During Implementation
- Used `LoyaltyCard` compact variant with static data (1250 points, Gold tier) as placeholder since loyalty API endpoint is not yet defined. UI-P3-T05 will replace with dynamic data.
- `AppAppBar.main` used for top bar; building separate top bar header would be redundant with this already-built component.
- `DoctorListWidget` (existing shared component) used for doctors section instead of creating custom inline doctor listing — preserves existing data fetching logic.
- Sections that show data depending on specific API response fields use safe indexing (`length > i`) to prevent index out of bounds.

### Known Limitations
- Loyalty section shows static placeholder data (1250 pts Gold). Will be replaced by UI-P3-T05 when loyalty API is available.
- The `_profileResponse` stored as `dynamic` type — Dart cannot statically verify API call response fields, but this matches the existing pattern used across the codebase.
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

