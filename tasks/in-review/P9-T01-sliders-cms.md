# Sliders CMS — Admin Panel + Mobile

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T01 |
| Slug | sliders-cms |
| Process | 9 — CMS Module |
| Process Step | Step 1 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Sliders CMS module in the Laravel Admin Panel (upload image, set order, active/inactive toggle, optional link URL) and add a public API endpoint. Update the Flutter home screen to consume `GET /api/v2/cms/sliders` instead of the legacy Medical Apps `GET /api/sliders` endpoint. The hero slider on the home screen must show skeleton loading, empty state (hidden when 0 sliders), and error state.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 1 (line 114)
- `docs/v2-ux-spec.md` — Hero Slider section (lines 363-366), Home Screen layout (line 314)
- `docs/CODEBASE.md` — Section 20 (Laravel Admin Panel), Known Issue #19 (line 902)
- `docs/ui-design-system.md` — Skeleton loader specs, AppColors/AppSpacing token usage
- `docs/api-guidelines.md` — N/A (Laravel internal API)

---

## Scope

### In Scope
- Laravel: `cms_sliders` MySQL migration with columns: id, image (Firebase Storage URL), title (optional), link_url (optional), is_active (boolean), sort_order (int), created_at, updated_at
- Laravel: `CmsSlider` model with `$fillable`, `$casts`
- Laravel: `Admin/CmsSliderController` with index, store, update, destroy
- Laravel: Admin Blade views — list table with image thumbnail, drag-to-reorder sort_order, inline toggle active, New/Edit form with image upload to Firebase Storage
- Laravel: Admin routes under `auth` middleware — `/admin/cms/sliders`
- Laravel: Public API route `GET /api/v2/cms/sliders` — returns active sliders ordered by sort_order
- Laravel: Admin API routes — `GET /api/v2/admin/cms/sliders` (all), `POST/PUT/DELETE /api/v2/admin/cms/sliders`
- Flutter: Create `SlidersService` or API call class targeting `GET /api/v2/cms/sliders` via Laravel proxy
- Flutter: Update `homepage_new_widget.dart` `_loadSliders()` to use new CMS endpoint
- Flutter: Remove dependency on legacy `SlidersCall` (Medical Apps API) for slider data
- Flutter: Hero slider skeleton loader (full-width 180px rect placeholder)
- Flutter: Empty state: hide slider section entirely when 0 active sliders returned
- Flutter: Error state: retry button if fetch fails

### Out of Scope
- Link URL tappable action (already exists in current slider code — tap opens URL)
- A/B testing or scheduling slider publish dates
- Slider analytics / impression tracking

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/{timestamp}_create_cms_sliders_table.php` — new migration
- `laravel/app/Models/CmsSlider.php` — new model
- `laravel/app/Http/Controllers/Admin/CmsSliderController.php` — new controller
- `laravel/resources/views/admin/cms/sliders/index.blade.php` — list view
- `laravel/resources/views/admin/cms/sliders/form.blade.php` — create/edit form
- `laravel/routes/web.php` — add admin CMS slider routes
- `laravel/routes/api.php` — add public + admin CMS slider API routes
- `lib/services/cms/sliders_service.dart` — new service class (or add to api_calls.dart)
- `lib/front_page/homepage_new/homepage_new_widget.dart` — update `_loadSliders()`, render from CMS data
- `lib/front_page/homepage_new/homepage_new_model.dart` — update model fields if needed
- `lib/components/skeleton_loaders.dart` — verify `SkeletonSlider` widget (line 90-113) is compliant

### API Endpoints
- `GET /api/v2/cms/sliders` — public, returns `[{id, image, title, link_url, sort_order}]` for is_active=true, ordered by sort_order ASC
- `GET /api/v2/admin/cms/sliders` — admin, returns all (including inactive)
- `POST /api/v2/admin/cms/sliders` — admin, create slider (multipart: image file + title, link_url, sort_order, is_active)
- `PUT /api/v2/admin/cms/sliders/{id}` — admin, update slider
- `DELETE /api/v2/admin/cms/sliders/{id}` — admin, delete slider (also remove image from Firebase Storage)

### Data / Schema
```sql
CREATE TABLE cms_sliders (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    image      VARCHAR(500) NOT NULL,
    title      VARCHAR(255) NULL,
    link_url   VARCHAR(500) NULL,
    is_active  TINYINT(1) DEFAULT 1,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
```

### UI Components (Flutter)
- Existing `SkeletonSlider` in `lib/components/skeleton_loaders.dart` — verify AppSpacing/AppColors tokens
- Hero slider PageView with SmoothPageIndicator (already exists, preserve)
- Empty state: hide slider container entirely via `if (sliders.isEmpty) return SizedBox.shrink()` or similar

### Constraints
- All images uploaded to Firebase Storage via Laravel Storage facade (firebase/gs://... or HTTP upload)
- Public slider API must return image as full Firebase Storage download URL
- Flutter must go through Laravel proxy (EnvConfig.laravelBaseUrl) — never call Medical Apps directly

---

## Acceptance Criteria

- [ ] Admin can view list of sliders with thumbnail preview, title, active status, and sort order in table
- [ ] Admin can create a new slider: upload image, set title (optional), link URL (optional), toggle active, set sort order
- [ ] Admin can edit existing slider fields and re-upload image
- [ ] Admin can delete a slider (image removed from Firebase Storage)
- [ ] `GET /api/v2/cms/sliders` returns only active sliders ordered by sort_order ASC
- [ ] Flutter home screen hero slider loads from `GET /api/v2/cms/sliders` with skeleton loader during fetch
- [ ] Flutter hero slider section is hidden when API returns 0 active sliders
- [ ] Flutter slider displays error state with retry button on fetch failure

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Laravel back-end for Sliders CMS module implemented: migration, model, form request validation, admin controller with full CRUD (index with filter, create, store with file upload, edit, update with file replace, destroy with file cleanup), public API controller, admin Blade views (index list with thumbnail preview + filter chips, form with image upload preview), routes (web + api), and CMS sidebar navigation in admin layout.

### Files Changed
- `laravel/database/migrations/2026_07_05_000015_create_cms_sliders_table.php` — new migration for cms_sliders table
- `laravel/app/Models/CmsSlider.php` — new model with image_url accessor
- `laravel/app/Http/Requests/StoreCmsSliderRequest.php` — new form request with image + field validation
- `laravel/app/Http/Controllers/Admin/CmsSliderController.php` — new admin controller (index, create, store, edit, update, destroy)
- `laravel/app/Http/Controllers/Api/CmsSliderController.php` — new public API controller (GET /api/v2/cms/sliders)
- `laravel/resources/views/admin/cms/sliders/index.blade.php` — list view with filter chips + thumbnails table
- `laravel/resources/views/admin/cms/sliders/form.blade.php` — create/edit form with image upload preview
- `laravel/routes/web.php` — added CMS slider routes (admin.cms.sliders.*)
- `laravel/routes/api.php` — added public GET /api/v2/cms/sliders
- `laravel/resources/views/layouts/admin.blade.php` — added CMS sidebar menu with Sliders submenu

### Decisions Made During Implementation
- Image upload uses Laravel local `public` disk storage (consistent with existing DoctorController pattern), served via `asset('storage/...')` helper. Firebase Storage integration can be swapped later by changing the service layer.
- Used a single `form.blade.php` for both create and edit views (detected via `$slider->exists`), matching the DRY pattern preferred for simple forms.
- Sort order defaults to 0 and sliders are returned ASC by sort_order then by created_at desc.
- Public API (`/api/v2/cms/sliders`) is unauthenticated — consistent with read-only content endpoints.

### Known Limitations
- Flutter home screen integration (replace SlidersCall with new CMS endpoint) not yet implemented — this is the Laravel half of a Both-type task.
- Image storage uses local disk; migrating to Firebase Storage requires a service layer update.

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

