# Videos CMS — Admin Panel + Mobile

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T04 |
| Slug | videos-cms |
| Process | 9 — CMS Module |
| Process Step | Step 4 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Videos CMS module. Admin pastes a TikTok URL into the panel, Laravel calls TikTok's oEmbed API to auto-fetch title + thumbnail, caches the thumbnail to Firebase Storage, and saves the entry. Serve videos via public API (`GET /api/v2/cms/videos`). In Flutter: replace Firestore `videos` collection usage on the home screen and videos list page with the new CMS endpoint. All video rendering must include skeleton loader, empty state, and error state.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 4 (line 117), CMS Module — Videos section (lines 516-584, full schema, oEmbed flow, endpoints)
- `docs/v2-ux-spec.md` — Admin CMS Videos (lines 917-943), Videos section (lines 333-341), Videos List screen (lines 706-723)
- `docs/CODEBASE.md` — Firestore `videos` collection, content media page paths
- `docs/ui-design-system.md` — Video card component spec, skeleton loader patterns, play icon overlay specs
- `docs/api-guidelines.md` — N/A

---

## Scope

### In Scope
- Laravel: `cms_videos` MySQL migration exactly per schema in v2-decisions.md lines 553-566
- Laravel: `CmsVideo` model
- Laravel: TikTok oEmbed integration — `GET https://www.tiktok.com/oembed?url={url}` to fetch title, thumbnail_url, author_name
- Laravel: `Admin/CmsVideoController` with index, fetchInfo, store, update, destroy
- Laravel: Admin Blade views — list table (thumbnail, title, TikTok author, status chip, published date, sort order, actions), filter chips (All/Published/Draft), drag-to-reorder sort_order
- Laravel: Create/Edit form per v2-ux-spec.md lines 928-942: TikTok URL input + Fetch Info button, thumbnail preview (16:9, lg radius), title (pre-filled from oEmbed, editable), author (read-only), status toggle, published_at, sort order
- Laravel: On save: download thumbnail from TikTok oEmbed thumbnail_url, upload to Firebase Storage, store Firebase URL in thumbnail_url column
- Laravel: Admin routes under `auth` middleware — `/admin/cms/videos`
- Laravel: Public API `GET /api/v2/cms/videos` — published only, paginated (10/page), supports `?limit=6` for homepage
- Laravel: Admin API routes per v2-decisions.md lines 573-577
- Flutter: Create Videos CMS service class calling Laravel proxy
- Flutter: Update `homepage_new_widget.dart` Videos section to use CMS videos API (`?limit=4` for home grid)
- Flutter: Update `all_content_media_widget.dart` to use CMS videos API (paginated, 10/page) instead of Firestore `queryVideosRecord()`
- Flutter: Each video card: CachedNetworkImage thumbnail (16:9, lg radius), play icon overlay (centered, 36px, white semi-transparent bg circle), title (body-sm, 2 lines max), TikTok author (body-sm, text-secondary)
- Flutter: Tap card -> `url_launcher` opens TikTok URL
- Flutter: Skeleton loader (thumbnail rect + 2 text bars per card), empty state, error state
- Flutter: Remove Firestore `VideosRecord` usage if fully replaced

### Out of Scope
- YouTube or other video platform support (TikTok only for now)
- In-app video playback (external TikTok app/browser only)
- Video analytics

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/{timestamp}_create_cms_videos_table.php` — new
- `laravel/app/Models/CmsVideo.php` — new
- `laravel/app/Http/Controllers/Admin/CmsVideoController.php` — new (includes fetchInfo action)
- `laravel/app/Services/TiktokOembedService.php` — new service class for oEmbed API calls
- `laravel/resources/views/admin/cms/videos/index.blade.php` — list view
- `laravel/resources/views/admin/cms/videos/form.blade.php` — create/edit form with Fetch Info button
- `laravel/routes/web.php` — add admin CMS videos routes
- `laravel/routes/api.php` — add public + admin CMS videos API routes
- `lib/front_page/homepage_new/homepage_new_widget.dart` — update videos section (lines ~896-1007)
- `lib/content_media/all_content_media/all_content_media_widget.dart` — replace Firestore streaming
- `lib/content_media/all_content_media/all_content_media_model.dart` — update model
- `lib/backend/schema/videos_record.dart` — may be deprecated

### API Endpoints
- `GET /api/v2/cms/videos` — public, published only, paginated (10/page), supports `?limit=4` for homepage grid
- `GET /api/v2/admin/cms/videos` — admin, all videos including drafts
- `POST /api/v2/admin/cms/videos/fetch-info` — admin, accepts `{tiktok_url}`, returns `{title, thumbnail_url, author_name}` from oEmbed
- `POST /api/v2/admin/cms/videos` — admin, create video entry (title, tiktok_url, thumbnail_url is auto-cached from oEmbed)
- `PUT /api/v2/admin/cms/videos/{id}` — admin, update video entry
- `DELETE /api/v2/admin/cms/videos/{id}` — admin, delete video (remove thumbnail from Firebase Storage)

### Data / Schema
Per `docs/v2-decisions.md` lines 553-566:
```sql
CREATE TABLE cms_videos (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    tiktok_url      VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500) NOT NULL,
    tiktok_author   VARCHAR(100) NULL,
    status          ENUM('draft','published') DEFAULT 'draft',
    sort_order      INT DEFAULT 0,
    published_at    TIMESTAMP NULL,
    created_by      INT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status)
);
```

### UI Components (Flutter)
- Home Videos section: 2-column grid, max 4 shown, hidden entirely if 0 published videos, skeleton while loading
- Videos List: 2-column grid, paginated 10/page
- Video card: thumbnail (CachedNetworkImage, 16:9, lg radius), play icon overlay (centered, 36px, white circle with 50% black bg), title (body-sm, 2 lines max), TikTok author
- Empty state: illustration + "No videos yet" + "Check back soon for our latest videos"
- Error state: error icon + Try Again button
- Design token compliance: AppColors, AppTextStyles, AppSpacing, AppRadius, AppShadows

### Constraints
- TikTok oEmbed endpoint is public (no auth needed) — `GET https://www.tiktok.com/oembed?url={encoded_url}`
- oEmbed thumbnail URLs can expire — must download and cache to Firebase Storage on save
- Flutter must route all calls through Laravel proxy (EnvConfig.laravelBaseUrl)
- Thumbnail caching: download via Laravel HTTP client, upload to Firebase Storage, store public URL

---

## Acceptance Criteria

- [ ] Admin can view videos list table with thumbnail, title, TikTok author, status chip, published date, sort order
- [ ] Admin can filter videos by All / Published / Draft
- [ ] Admin can paste TikTok URL and click "Fetch Info" — title + thumbnail preview auto-populated from oEmbed
- [ ] Admin sees inline error if TikTok URL is invalid or oEmbed fetch fails
- [ ] Admin can create video: TikTok URL, title (pre-filled, editable), status toggle, published_at, sort order — thumbnail auto-cached to Firebase Storage on save
- [ ] Admin can edit video title, status, sort order
- [ ] Admin can delete video with confirmation (thumbnail removed from Firebase Storage)
- [ ] `GET /api/v2/cms/videos` returns paginated published videos only (10/page), thumbnail_url points to Firebase Storage
- [ ] Flutter home screen Videos section shows up to 4 video thumbnail cards from CMS API, hidden when 0 videos
- [ ] Flutter Videos List screen shows paginated 2-column grid from CMS API with skeleton, empty, and error states
- [ ] Flutter tapping a video card opens TikTok URL via url_launcher (TikTok app or browser)
- [ ] Firebase Firestore `videos` collection usage is no longer used for video data in Flutter

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

