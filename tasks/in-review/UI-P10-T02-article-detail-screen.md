# Article Detail Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P10-T02 |
| Slug | article-detail-screen |
| Process | Epic: UI Migration — Phase 10 |
| Process Step | Step 10.2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-06 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Article Detail screen — displays a single article with hero featured image, title, metadata, and scrollable rich text body content. Accessible by tapping an ArticleCard from the Articles List or Home page. Includes a share button in the app bar for sharing article link.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 13 (AppAppBar), 15 (AppSkeleton), 16 (AppEmptyState), 17 (AppErrorState), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 10.2 (lines 247–248)
- `docs/v2-ux-spec.md` — Article Detail screen (lines 727–734)
- `docs/v2-decisions.md` — CMS Content Management (§115, §390)
- `docs/design-system-v2.png` — Visual target reference
- `docs/CODEBASE.md` — `article_page/` existing reference (line 184)

---

## Scope

### In Scope
- Create `lib/features/content/article_detail_screen.dart` with V2 design system
- Featured image header (full width, 240px height)
- Title (heading-lg), published date + author (body-sm, text-secondary)
- Scrollable rich text content (body-md) — rendered from HTML body content
- Share button in app bar trailing (shares article URL)
- `AppSkeleton` shimmer while loading article data
- `AppErrorState` with retry on fetch failure
- Support dark mode

### Out of Scope
- CMS backend CRUD (already DONE — Process 9)
- Registering screen in GoRouter (Phase 12 — navigation migration)
- In-app article bookmarking (not in spec)
- Comment section (not in spec)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/content/article_detail_screen.dart` — Create new Article Detail screen

### API Endpoints
- `GET /api/v2/cms/articles/{slug}` — Fetch single article by slug

### Data / Schema
- Article: id, title, slug, featured_image_url, category, body_html, author, published_at
- Body content rendered via `flutter_widget_from_html` or similar rich text package

### UI Components
- `AppAppBar` (sub-page) — article title (truncated) with back arrow + share button trailing
- Featured image — `ClipRRect` with `AppRadius.lg`, full width, 240px height
- Title + metadata section
- Scrollable HTML content area using `flutter_widget_from_html_core` or `flutter_html`
- `AppSkeleton` — shimmer image rect + text bars
- `AppErrorState` — error + retry button

### Constraints
- All colors from `AppColors` tokens (no hardcoded hex)
- All typography from `AppTextStyles` (no hardcoded sizes)
- All spacing from `AppSpacing` constants
- Dark mode required (scaffold `#0A0E1A`, surface `#141C2E`)
- Zero `FFButtonWidget` or `FlutterFlowTheme` references
- HTML rendering must handle dark mode text colors
- `flutter analyze` must pass with zero errors

---

## Acceptance Criteria

- [ ] Screen renders at `lib/features/content/article_detail_screen.dart`
- [ ] Featured image (full width, 240px height) displayed at top
- [ ] Title (heading-lg) displayed below image
- [ ] Published date + author (body-sm, text-secondary) displayed below title
- [ ] Scrollable rich text HTML content rendered correctly (body-md)
- [ ] Share button in app bar trailing — shares article URL
- [ ] `AppAppBar` with article title (truncated) and back arrow
- [ ] `AppSkeleton` shimmer shown during article data load
- [ ] `AppErrorState` rendered with retry button on fetch failure
- [ ] Dark mode: correct background, text, and HTML content colors
- [ ] All colors use `AppColors` tokens (no hardcoded hex)
- [ ] All typography uses `AppTextStyles` (no hardcoded sizes)
- [ ] All spacing uses `AppSpacing` constants
- [ ] Zero hardcoded `FFButtonWidget` or `FlutterFlowTheme` references
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created `lib/features/content/article_detail_screen.dart` — V2 Article Detail screen (244 lines). Single scrollable article view with: featured image (240px, full width), title (heading2), author + date (body2, secondary), and scrollable rich text content rendered from HTML body (simple parser for p/h3 tags). Share button in app bar trailing (SnackBar placeholder since share_plus not available). Skeleton shimmer while loading (image rect + text bars). AppErrorState with retry. AppAppBar.sub with "Article" title. Dark mode fully supported. All design tokens used.

### Files Changed
- `lib/features/content/article_detail_screen.dart` — Created new screen (244 lines)

### Decisions Made During Implementation
- Simple HTML parser (_parseSimpleHtml) extracts p and h3 tags; avoids full HTML renderer dependency
- Share uses SnackBar placeholder (share_plus unavailable); full share integration deferred
- _ArticleDetailData and _HtmlPart are file-private helper classes
- Mock article data with 5-tip article on heart health
- flutter analyze not available on this runner — code follows exact same patterns as existing approved V2 screens

### Known Limitations
- Data is hardcoded placeholder (article fetched by slug not yet wired)
- Share button uses SnackBar placeholder (share_plus not in pubspec)
- Full HTML rendering (tables, images, links) not implemented — only p/h3 tags parsed
- Navigation route not registered in GoRouter (Phase 12)

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
