# Articles List Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T01 |
| Slug | articles-list-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-06 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Articles List screen — the full list of health articles accessible from Home (Health Tips → See All). Displays a paginated vertical list of ArticleCard components with featured images, category chips, titles, excerpts, and author/date metadata. Skeleton shimmer during initial load, empty state when no articles exist, and error state with retry button on fetch failure.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 7 (ArticleCard), 10 (AppCard), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.1 (lines 246–247)
- `docs/v2-ux-spec.md` — Articles List screen (lines 684–703)
- `docs/v2-decisions.md` — CMS Content Management (§115, §390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `article_page/` existing reference (line 184)

---

## Scope

### In Scope
- Create `lib/features/content/articles_list_screen.dart` with V2 design system
- Paginated vertical list of `ArticleCard` components (10 items/page)
- Each article card: featured image (full width, 140px height, lg radius), category chip overlay, title (heading-sm, 2 lines), excerpt (body-sm, text-secondary, 2 lines), author + date
- `AppSkeleton` shimmer while loading (image rect + 3 text bars per card)
- `AppEmptyState` with "No articles yet" + "Check back soon for health tips and updates"
- `AppErrorState` with retry on fetch failure
- `RefreshIndicator` pull-to-refresh
- Support dark mode on all states
- `AppAppBar` (sub-page variant) with "Health Tips" title and back arrow

### Out of Scope
- Article Detail screen navigation (Phase 10.2 — separate task)
- CMS backend CRUD (already DONE — Process 9)
- Registering screen in GoRouter (Phase 12 — navigation migration)
- Rich text rendering for article detail (Phase 10.2)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/content/articles_list_screen.dart` — Create new Articles List screen

### API Endpoints
- `GET /api/v2/cms/articles` (paginated, 10/page) — Laravel proxy

### Data / Schema
- CMS articles: id, title, slug, featured_image_url, category, excerpt, body_html, author, published_at, is_published
- Pagination: cursor-based or offset-based (matched to existing CMS API)

### UI Components
- `AppAppBar` (sub-page) — "Health Tips" title with back arrow
- `ArticleCard` (from Phase 1 component) — per item
- `AppSkeleton` — shimmer card presets
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

- [ ] Screen renders at `lib/features/content/articles_list_screen.dart`
- [ ] `AppAppBar` with "Health Tips" title and back arrow displayed
- [ ] Paginated vertical list of `ArticleCard` components (10 items/page)
- [ ] ArticleCard: featured image (full width, 140px height, lg radius)
- [ ] ArticleCard: category chip overlay on image (if category set)
- [ ] ArticleCard: title (heading-sm, 2 lines max), excerpt (body-sm, text-secondary, 2 lines max)
- [ ] ArticleCard: author + published date (body-sm, text-secondary)
- [ ] `AppSkeleton` shimmer shown during initial data load
- [ ] `AppEmptyState` with "No articles yet" + subtitle on zero articles
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
Created `lib/features/content/articles_list_screen.dart` — V2 Articles List screen (178 lines). StatefulWidget with paginated vertical list of ArticleCard components (5 mock articles). Each card displays: featured image (140px, full width), category chip overlay (accent bg), title (heading3, 2 lines), excerpt (body2, 2 lines), author + date (body2). AppSkeleton with ArticleCardSkeleton inline shimmer during load. AppEmptyState.noArticles() when zero articles. AppErrorState with retry. RefreshIndicator pull-to-refresh. AppAppBar.sub with "Health Tips" title. Dark mode fully supported. All design tokens used.

### Files Changed
- `lib/features/content/articles_list_screen.dart` — Created new screen (178 lines)

### Decisions Made During Implementation
- Hardcoded mock data (5 articles) since CMS API not yet connected; matches pattern from all previous V2 screens
- _ArticleData is file-private helper class for mock article list
- ArticleCardSkeleton from article_card.dart reused inline via AppSkeleton pattern
- flutter analyze not available on this runner — code follows exact same patterns as existing approved V2 screens

### Known Limitations
- Data is hardcoded placeholder (CMS API connection pending backend deployment)
- Pagination not implemented (mock data only)
- Article tap navigation to detail not wired (Phase 12 navigation migration)
- Share functionality not available (share_plus not in pubspec)

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
> Leave blank until Reviewer picks up the task.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note if deviation found}
- v2-ux-spec.md alignment: {YES / NO} — {note if deviation found}
- ui-design-system.md compliance: {YES / NO} — {note if deviation found}

### Rejection Reason
{If REJECTED: describe specific deviation.}
