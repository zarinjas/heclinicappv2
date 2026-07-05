# Service Packages CMS — Admin Panel + Mobile

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T02 |
| Slug | service-packages-cms |
| Process | 9 — CMS Module |
| Process Step | Step 2 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the Service Packages CMS in Laravel Admin Panel (upload image, name, description) to replace the 4 hardcoded static images in the Flutter app. Currently `lib/service_package/service_package/service_package_widget.dart` renders 4 local asset images with no API calls — the `ServicesPackagesCall` API class exists but is unused. Create/Edit/Delete packages from Admin Panel, serve via public API, and update Flutter to render dynamic package cards with skeleton, empty, and error states.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 2 (line 115)
- `docs/v2-ux-spec.md` — Quick Actions "Packages" card (line 318)
- `docs/CODEBASE.md` — Known Issue #19 (line 902), service packages file paths
- `docs/ui-design-system.md` — AppCard component specs, skeleton loader patterns
- `docs/api-guidelines.md` — N/A

---

## Scope

### In Scope
- Laravel: `cms_service_packages` MySQL migration: id, name, description (TEXT), image (Firebase Storage URL), is_active (boolean), sort_order (int), created_at, updated_at
- Laravel: `CmsServicePackage` model
- Laravel: `Admin/CmsServicePackageController` with index, store, update, destroy
- Laravel: Admin Blade views — list table with image thumbnail, name, status toggle, sort order, actions
- Laravel: Admin routes under `auth` middleware — `/admin/cms/service-packages`
- Laravel: Public API `GET /api/v2/cms/service-packages` — active packages ordered by sort_order
- Laravel: Admin API routes — full CRUD
- Flutter: Create service class or add to existing `api_calls.dart` targeting `GET /api/v2/cms/service-packages`
- Flutter: Replace hardcoded `assets/images/PHOTO-*.jpg` references in `service_package_widget.dart` with dynamic list from API
- Flutter: Each card renders image (CachedNetworkImage), name, description
- Flutter: Skeleton loader (image rect + text bars) while loading
- Flutter: Empty state: illustration + "No packages available yet"
- Flutter: Error state: error icon + Try Again button
- Flutter: Remove legacy `ServicesPackagesCall` if no longer needed

### Out of Scope
- Pricing or validity period on packages
- Booking integration from package card
- Package detail sub-page

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/{timestamp}_create_cms_service_packages_table.php` — new
- `laravel/app/Models/CmsServicePackage.php` — new
- `laravel/app/Http/Controllers/Admin/CmsServicePackageController.php` — new
- `laravel/resources/views/admin/cms/service-packages/index.blade.php` — list view
- `laravel/resources/views/admin/cms/service-packages/form.blade.php` — create/edit form
- `laravel/routes/web.php` — add admin CMS service-packages routes
- `laravel/routes/api.php` — add public + admin API routes
- `lib/service_package/service_package/service_package_widget.dart` — replace hardcoded images with dynamic API rendering
- `lib/service_package/service_package/service_package_model.dart` — add state for API response
- `lib/backend/api_requests/api_calls.dart` — add `CmsServicePackagesCall` or update

### API Endpoints
- `GET /api/v2/cms/service-packages` — public, returns `[{id, name, description, image}]` for is_active=true, ordered by sort_order ASC
- `GET /api/v2/admin/cms/service-packages` — admin, all packages
- `POST /api/v2/admin/cms/service-packages` — admin, create (multipart: image + name, description, is_active, sort_order)
- `PUT /api/v2/admin/cms/service-packages/{id}` — admin, update
- `DELETE /api/v2/admin/cms/service-packages/{id}` — admin, delete (remove image from Firebase Storage)

### Data / Schema
```sql
CREATE TABLE cms_service_packages (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    description TEXT NULL,
    image       VARCHAR(500) NOT NULL,
    is_active   TINYINT(1) DEFAULT 1,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
```

### UI Components (Flutter)
- `service_package_widget.dart` — currently renders 4 hardcoded `Image.asset()` in a Column/ListView. Replace with dynamic ListView.builder from API data using CachedNetworkImage
- Use AppCard wrapper for each package card
- Skeleton: `SkeletonLoader` patterns matching final card layout (rect for image + 2 text bars)
- Empty: centered column with illustration asset + "No packages available yet"
- Error: centered column with error icon + "Something went wrong" + Try Again button

### Constraints
- Images uploaded to Firebase Storage via Laravel, served as download URLs in API response
- Flutter must call Laravel proxy (EnvConfig.laravelBaseUrl) — no direct Firebase Storage calls

---

## Acceptance Criteria

- [ ] Admin can view list of service packages with thumbnail, name, active status, and sort order
- [ ] Admin can create a new service package: upload image, enter name, enter description, toggle active, set sort order
- [ ] Admin can edit existing package (change image, name, description, status, order)
- [ ] Admin can delete a package (image removed from Firebase Storage)
- [ ] `GET /api/v2/cms/service-packages` returns only active packages ordered by sort_order ASC
- [ ] Flutter service packages screen renders dynamic list from CMS API (no hardcoded local images)
- [ ] Flutter shows skeleton loader while loading, empty state when no active packages, error state with retry on failure

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

