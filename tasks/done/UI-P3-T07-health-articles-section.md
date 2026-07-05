# Health Articles Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T07 |
| Slug | health-articles-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.7 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the health articles section on the home screen using the `ArticleCard` component (Phase 1). Fetch published articles from CMS API (`GET /api/v2/config/articles`), limited to top 4 for the home screen. Display as a vertical list (or horizontal scroll) of `ArticleCard` components. Show `AppSkeleton` while loading. Hide section if 0 published articles. "See All" navigates to Articles List screen (Phase 10). Replace all hardcoded article content from the old codebase.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §10 (AppCard), §15 (Skeleton), §16 (EmptyState)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 121
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Article card UX
- `docs/CODEBASE.md` — existing article_page/ code

---

## Scope

### In Scope
- Integrate `ArticleCard` list into home screen articles section
- Fetch published articles from `GET /api/v2/config/articles` (filter status = published, limit 4)
- Display as vertical `ListView` of `ArticleCard` components
- Show `AppSkeleton` shimmer (4 card placeholders) while loading
- Hide entire section if 0 published articles
- "See All" navigates to Articles List screen (Phase 10)
- Tap article opens Article Detail screen
- Remove references to hardcoded article data from old code

### Out of Scope
- ArticleCard component itself (Phase 1 — UI-P1-T03)
- Articles List screen (Phase 10)
- Article Detail screen (Phase 10)
- Articles CMS management (Process 9)
- Home screen shell (UI-P3-T01)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add articles section slot
- `lib/core/widgets/article_card.dart` — Use existing Phase 1 component

### API Endpoints
- `GET /api/v2/config/articles` — fetch published articles (via Laravel proxy)

### Data / Schema
- Article: `id`, `title`, `summary`, `featured_image`, `category`, `published_at`, `status`

### UI Components
- `ArticleCard` — Phase 1 reusable
- `AppSkeleton` — shimmer article card placeholders
- `SectionHeader` — "Health Articles" + "See All"

### Constraints
- All styling must use design tokens
- Dark mode support
- No hardcoded article data in codebase
- Max 4 articles shown on home

---

## Acceptance Criteria

- [ ] Articles section displays up to 4 published articles as `ArticleCard` list
- [ ] `AppSkeleton` shimmer (4 card placeholders) is displayed while loading
- [ ] Section is hidden when 0 published articles exist
- [ ] "See All" tap navigates to Articles List screen
- [ ] Tapping an article opens Article Detail screen with full content
- [ ] No hardcoded article data remains in Flutter code
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
- Changed empty state from `AppEmptyState` widget to `SizedBox.shrink()` to hide section when 0 published articles exist
- Section already had skeleton loading, error state, ArticleCard list, See All, and tap-to-detail navigation

### Files Changed
- `lib/features/home/home_screen.dart` — Replaced AppEmptyState with SizedBox.shrink() in _buildArticlesSection()

### Decisions Made During Implementation
- Task already had full implementation from Phase 3 batch 1 (T01-T05); only missing empty-state hide behavior
- Kept all existing ArticleCard usage, API calls, navigation intact

### Known Limitations
(None)

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] Articles section displays up to 4 published articles as `ArticleCard` list
- [x] `AppSkeleton` shimmer (4 card placeholders) is displayed while loading
- [x] Section is hidden when 0 published articles exist — SizedBox.shrink() guard
- [x] "See All" tap navigates to Articles List screen — AllArticlePageNewWidget.routeName
- [x] Tapping an article opens Article Detail screen with full content — route with slug param
- [x] No hardcoded article data remains in Flutter code — fetched from API
- [x] `flutter analyze` passes with zero errors

### Failure Details
(None)

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- Design system compliance: ArticleCard uses design tokens internally ✓
- No hardcoded colors/sizes/spacing ✓
- ArticleCard (Phase 1) used ✓
- SectionHeader, AppErrorState used ✓
- Dark mode: ArticleCard supports internally ✓
- Skeleton + error states implemented; empty state hides section ✓
- flutter analyze: zero errors ✓
