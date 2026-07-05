# Articles CMS — Admin Panel + Mobile

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T03 |
| Slug | articles-cms |
| Process | 9 — CMS Module |
| Process Step | Step 3 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Articles CMS module. In the Laravel Admin Panel: TipTap rich text editor for composing articles with featured image, category, publish/draft status, and sort order. Serve articles via public API (`GET /api/v2/cms/articles`). In Flutter: replace the legacy WordPress API (`GET /wp-json/wp/v2/posts`) and Firestore `articles` collection usage on the home screen and articles list/detail pages with the new Laravel CMS endpoint. All article rendering must include skeleton loader, empty state, and error state.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 3 (line 116), CMS Module — Articles section (lines 462-513, full schema + endpoints)
- `docs/v2-ux-spec.md` — Admin CMS Articles (lines 888-913), Health Tips section (lines 329-331), Articles List screen (lines 686-702), Article Detail (lines 727-734)
- `docs/CODEBASE.md` — WordPress API section (Section 12), Firestore `articles` collection, article page paths
- `docs/ui-design-system.md` — Article card component spec, skeleton loader patterns
- `docs/api-guidelines.md` — N/A

---

## Scope

### In Scope
- Laravel: `cms_articles` MySQL migration exactly per schema in v2-decisions.md lines 478-495
- Laravel: `CmsArticle` model with `$fillable`, `$casts`, `slug` auto-generation from title
- Laravel: `Admin/CmsArticleController` with index, store, update, destroy
- Laravel: Admin Blade views — list table (thumbnail, title, category, status chip, published date, sort order, actions), filter chips (All/Published/Draft), search by title, drag-to-reorder sort_order
- Laravel: Create/Edit form with TipTap rich text editor (see v2-ux-spec.md lines 900-913), featured image upload, slug auto-generation, status toggle, published_at datetime picker
- Laravel: Admin routes under `auth` middleware — `/admin/cms/articles`
- Laravel: Public API endpoints per v2-decisions.md lines 499-501: `GET /api/v2/cms/articles` (paginated 10/page, published only), `GET /api/v2/cms/articles/{slug}` (single article)
- Laravel: Admin API endpoints per v2-decisions.md lines 503-506
- Flutter: Create Articles CMS service class calling Laravel proxy
- Flutter: Update `homepage_new_widget.dart` Health Tips section to use CMS articles API (`?limit=3`)
- Flutter: Update `all_article_page_new_widget.dart` to use CMS articles API (paginated, 10/page) instead of Firestore `queryArticlesRecord()`
- Flutter: Update `article_detail_page_widget.dart` to receive CMS article data (title, body HTML rendered via flutter_html or similar, featured_image, published_at, author_name)
- Flutter: Skeleton loader on all article list screens
- Flutter: Empty state: illustration + "No articles yet" + "Check back soon for health tips and updates"
- Flutter: Error state: error icon + Try Again button on all screens
- Flutter: Remove Firestore `ArticlesRecord` usage and WordPress `GetArticlesCall` dependency if fully replaced

### Out of Scope
- Article comments or social sharing (existing share button preserved if present)
- Multi-language article support
- Article scheduling (future publish date)

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/{timestamp}_create_cms_articles_table.php` — new
- `laravel/app/Models/CmsArticle.php` — new
- `laravel/app/Http/Controllers/Admin/CmsArticleController.php` — new
- `laravel/app/Http/Controllers/Api/CmsArticleController.php` — new (public API)
- `laravel/resources/views/admin/cms/articles/index.blade.php` — list view
- `laravel/resources/views/admin/cms/articles/form.blade.php` — create/edit form
- `laravel/routes/web.php` — add admin CMS articles routes
- `laravel/routes/api.php` — add public + admin CMS articles API routes
- `lib/front_page/homepage_new/homepage_new_widget.dart` — update articles section
- `lib/article_page/all_article_page_new/all_article_page_new_widget.dart` — replace Firestore streaming
- `lib/article_page/all_article_page_new/all_article_page_new_model.dart` — update model
- `lib/article_page/article_detail_page/article_detail_page_widget.dart` — accept CMS article data
- `lib/article_page/article_detail_page/article_detail_page_model.dart` — update model
- `lib/backend/api_requests/api_calls.dart` — deprecate GetArticlesCall or add cms variant

### API Endpoints
- `GET /api/v2/cms/articles` — public, published only, paginated (10/page), supports `?limit=3` for homepage
- `GET /api/v2/cms/articles/{slug}` — public, single article detail
- `GET /api/v2/admin/cms/articles` — admin, all articles including drafts
- `POST /api/v2/admin/cms/articles` — admin, create article
- `PUT /api/v2/admin/cms/articles/{id}` — admin, update article
- `DELETE /api/v2/admin/cms/articles/{id}` — admin, delete article

### Data / Schema
Per `docs/v2-decisions.md` lines 478-495:
```sql
CREATE TABLE cms_articles (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL UNIQUE,
    body            LONGTEXT NOT NULL,
    excerpt         TEXT NULL,
    featured_image  VARCHAR(255) NULL,
    category        VARCHAR(100) NULL,
    author_name     VARCHAR(100) NULL,
    status          ENUM('draft','published') DEFAULT 'draft',
    sort_order      INT DEFAULT 0,
    published_at    TIMESTAMP NULL,
    created_by      INT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_published_at (published_at)
);
```

### UI Components (Flutter)
- Homepage Health Tips: renders up to 3 article cards from CMS, skeleton while loading
- Articles List: vertical list, paginated 10/page, skeleton + empty + error states
- Article Detail: featured image (240px), title (heading-lg), published date + author, rich text body rendered via flutter_html package
- Design tokens: use AppColors, AppTextStyles, AppSpacing throughout

### Constraints
- TipTap HTML output stored in `body` LONGTEXT — Flutter must render HTML safely (no webview, use flutter_html or flutter_widget_from_html)
- Slug auto-generated from title, must be unique, admin can override
- Featured image uploaded to Firebase Storage via Laravel
- All Flutter calls route through Laravel proxy (EnvConfig.laravelBaseUrl)

---

## Acceptance Criteria

- [ ] Admin can view articles list table with thumbnail, title, category, status chip, published date, sort order
- [ ] Admin can filter articles by All / Published / Draft
- [ ] Admin can search articles by title
- [ ] Admin can create new article: title, auto-generated slug, TipTap rich text body, featured image upload, category, author name, excerpt, status toggle, published_at, sort order
- [ ] Admin can edit existing article (all fields updatable)
- [ ] Admin can delete article with confirmation modal
- [ ] `GET /api/v2/cms/articles` returns paginated published articles only (10/page)
- [ ] `GET /api/v2/cms/articles/{slug}` returns single article with full body HTML
- [ ] Flutter home screen Health Tips section renders up to 3 CMS articles (with `?limit=3`)
- [ ] Flutter Articles List screen shows paginated articles from CMS API with skeleton, empty, and error states
- [ ] Flutter Article Detail screen renders featured image, title, author, date, and HTML body correctly
- [ ] Firebase Firestore `articles` collection usage and WordPress `GetArticlesCall` are no longer used for article data in Flutter

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results


### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check


### Rejection Reason

