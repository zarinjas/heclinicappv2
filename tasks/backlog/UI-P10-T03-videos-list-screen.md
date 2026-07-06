# Videos List Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T03 |
| Slug | videos-list-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | N/A |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Videos List screen — the full list of health videos accessible from Home (Videos → See All). Displays a 2-column paginated grid of VideoCard components with TikTok thumbnails, play icon overlays, titles, and author handles. Tap opens TikTok deep link via url_launcher. Skeleton shimmer during initial load, empty state when no videos exist, and error state with retry button on fetch failure.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 7 (VideoCard), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.3 (lines 249–250)
- `docs/v2-ux-spec.md` — Videos List screen (lines 706–724)
- `docs/v2-decisions.md` — CMS Content Management (§115, §390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `content_media/` existing reference (line 185)

---

## Scope

### In Scope
- Create `lib/features/content/videos_list_screen.dart` with V2 design system
- 2-column `GridView` of `VideoCard` components, paginated (10 items/page)
- Each video card: thumbnail image (16:9 ratio, lg radius), play icon overlay (36px, white, semi-transparent bg), title (body-sm, 2 lines max), TikTok author handle (body-sm, text-secondary)
- Tap card → `url_launcher` opens `tiktok_url` in TikTok app or browser
- `AppSkeleton` shimmer while loading (thumbnail rect + 2 text bars per card, 2×2 grid)
- `AppEmptyState` with "No videos yet" + "Check back soon for our latest videos"
- `AppErrorState` with retry on fetch failure
- `RefreshIndicator` pull-to-refresh
- Support dark mode on all states
- `AppAppBar` (sub-page variant) with "Videos" title and back arrow

### Out of Scope
- CMS backend CRUD (already DONE — Process 9)
- Registering screen in GoRouter (Phase 12 — navigation migration)
- In-app video player (TikTok links open externally per spec)
- Upload functionality (admin panel only — Process 9)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/content/videos_list_screen.dart` — Create new Videos List screen

### API Endpoints
- `GET /api/v2/cms/videos` (paginated, 10/page) — Laravel proxy

### Data / Schema
- CMS videos: id, title, tiktok_url, thumbnail_url, author_handle, is_published, published_at

### UI Components
- `AppAppBar` (sub-page) — "Videos" title with back arrow
- `GridView` 2-column with `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)`
- `VideoCard` (from Phase 1 component) — thumbnail + play icon + title + author
- `AppSkeleton` — shimmer grid presets (2×2)
- `AppEmptyState` — illustration + message
- `AppErrorState` — error + retry button
- `RefreshIndicator`

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Border radius from `AppRadius`, shadows from `AppShadows`
- Dark mode required (scaffold `#0A0E1A`, surface `#141C2E`)
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/content/videos_list_screen.dart`
- [ ] `AppAppBar` with "Videos" title and back arrow displayed
- [ ] 2-column `GridView` of `VideoCard` components, paginated (10/page)
- [ ] VideoCard: thumbnail image (16:9 ratio, lg radius)
- [ ] VideoCard: play icon overlay (36px, white, semi-transparent bg circle)
- [ ] VideoCard: title (body-sm, 2 lines max) below thumbnail
- [ ] VideoCard: TikTok author handle (body-sm, text-secondary) below title
- [ ] Tap card → `url_launcher` opens TikTok URL in external app/browser
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppEmptyState` with "No videos yet" + subtitle on zero videos
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] `RefreshIndicator` pull-to-refresh working
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants (no magic numbers)
- [ ] Border radius uses `AppRadius`, shadows use `AppShadows`
- [ ] Dark mode: scaffold `#0A0E1A`, surface `#141C2E`, correct text colors
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

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
> Leave blank until QA picks up the task.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] {Criterion 1} — {PASS / FAIL} — {note if fail}

### Failure Details
{If FAILED: describe what was wrong and what needs to be fixed.}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note if deviation found}
- v2-ux-spec.md alignment: {YES / NO} — {note if deviation found}
- ui-design-system.md compliance: {YES / NO} — {note if deviation found}

### Rejection Reason
{If REJECTED: describe specific deviation.}
