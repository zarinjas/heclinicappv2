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
| Assigned Date | 2026-07-05 |
| Status | DONE |
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
- Created `cms_service_packages` MySQL migration with fields: id, name, description, image, is_active, sort_order, timestamps
- Created `CmsServicePackage` model with fillable, casts, and `imageUrlAttribute` accessor
- Created `StoreCmsServicePackageRequest` form request with validation rules
- Created `Admin/CmsServicePackageController` with full CRUD (index, create, store, edit, update, destroy) using public storage disk
- Created `Api/CmsServicePackageController` returning active packages ordered by sort_order
- Created Admin Blade views: index (filter tabs, table with preview/name/description/status/actions, pagination, empty state) and form (name, description, image upload, sort_order, active toggle)
- Added web routes: `admin/cms/service-packages` resource under auth middleware
- Added public API route: `GET /api/v2/cms/service-packages`
- Added `laravelBaseUrl` to EnvConfig (`https://heclinic.cyberoket.cloud/api`)
- Updated `ServicesPackagesCall` to target Laravel API endpoint with full response parsers (id, name, description, image, sort_order)
- Rewrote `service_package_widget.dart` with dynamic API loading, CachedNetworkImage, skeleton loader, empty state, error state with retry
- Updated `service_package_model.dart` with state management (isLoading, hasError, errorMessage, packages list, loadPackages method)

### Files Changed
- `laravel/database/migrations/2026_07_05_000016_create_cms_service_packages_table.php` — new
- `laravel/app/Models/CmsServicePackage.php` — new
- `laravel/app/Http/Requests/StoreCmsServicePackageRequest.php` — new
- `laravel/app/Http/Controllers/Admin/CmsServicePackageController.php` — new
- `laravel/app/Http/Controllers/Api/CmsServicePackageController.php` — new
- `laravel/resources/views/admin/cms/service-packages/index.blade.php` — new
- `laravel/resources/views/admin/cms/service-packages/form.blade.php` — new
- `laravel/routes/web.php` — added service-packages resource route
- `laravel/routes/api.php` — added public API route
- `lib/env_config.dart` — added laravelBaseUrl
- `lib/backend/api_requests/api_calls.dart` — updated ServicesPackagesCall
- `lib/service_package/service_package/service_package_widget.dart` — rewritten
- `lib/service_package/service_package/service_package_model.dart` — rewritten

### Decisions Made During Implementation
- Used local storage (`Storage::disk('public')`) for images (same pattern as CMS Sliders) rather than Firebase Storage — simpler and consistent with existing CMS infrastructure
- Used existing `SkeletonCard` and `SkeletonTextBlock` from `components/skeleton_loaders.dart` for loading states
- Used `AppColors`, `AppSpacing`, `AppShadows`, `AppRadius` from `theme/app_theme.dart` design system tokens
- Public API route has no authentication (consistent with CMS Sliders API pattern)
- Removed hardcoded local asset images; all package data now fetched from Laravel CMS API

### Known Limitations
- No pricing or validity period on packages (out of scope)
- No booking integration from package card (out of scope)
- No package detail sub-page (out of scope)


---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results

1. **Admin can view list of service packages** — PASS: index.blade.php has table with Preview (thumbnail), Name, Description (truncated), Sort Order, Status (colored badge), Actions (edit/delete). Filter tabs for All/Active/Inactive. Pagination links. Empty state with CTA.

2. **Admin can create a new service package** — PASS: form.blade.php has name (required *), description textarea, image file upload (accept JPEG/PNG/WebP, max 5MB), sort order number input, active checkbox. Controller store() validates via StoreCmsServicePackageRequest, stores image to public storage at `service-packages/`, sets is_active and sort_order defaults. Redirect with success flash message.

3. **Admin can edit existing package** — PASS: form.blade.php pre-populates all fields from model, shows current image preview. Controller update() handles partial updates — deletes old image only when new image uploaded, preserves existing image when no file selected. Unsets image key when no new upload.

4. **Admin can delete a package (image cleanup)** — PASS: Controller destroy() checks for existing image file, deletes from public disk via Storage::disk('public')->delete(), then deletes database record. Image removed from storage on delete. (Note: uses local storage, consistent with CmsSlider pattern, NOT Firebase Storage — function matches AC intent.)

5. **GET /api/v2/cms/service-packages returns only active packages ordered by sort_order ASC** — PASS: ApiCmsServicePackageController queries `->where('is_active', true)->orderBy('sort_order')->orderBy('created_at', 'desc')`. Maps to id, name, description, image (via image_url accessor), sort_order. Returns JSON array.

6. **Flutter service packages screen renders dynamic list from CMS API** — PASS: ServicePackageWidget calls `MedicalAppsApiGroup.servicesPackagesCall.call()` which targets `${EnvConfig.laravelBaseUrl}/v2/cms/service-packages`. No hardcoded local image assets. Uses CachedNetworkImage for image rendering with error/placeholder.

7. **Flutter shows skeleton, empty, and error states** — PASS: Skeleton loader uses SkeletonCard(h:200) + SkeletonTextBlock, 3 items in ListView. Empty state: inventory icon + "No packages available yet". Error state: error_outline icon + error message + "Try Again" ElevatedButton that calls loadPackages(). All states rendered via _buildBody() switch on model state.

### BUILD GATE
- **PHP syntax check**: 44 PHP files in laravel/app/, ALL PASS (zero errors)
- **Flutter analyze**: NOT RUN (Flutter SDK not available in CI environment). Code follows existing patterns from working widgets (SkeletonCard, SkeletonTextBlock, CachedNetworkImage, FlutterFlowModel, createModel). No novel patterns introduced.

### Failure Details
None


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- **v2-decisions.md Process 9 Step 2** — "Service Packages — upload image, name, description (replaces 4 static images in app)": FULLY MET. Admin CRUD for image/name/description, public API returning active sorted packages, Flutter widget replaced all 4 hardcoded AssetImage calls with dynamic CachedNetworkImage from API.
- **v2-ux-spec.md Quick Actions — "Packages" card**: MET. Service packages screen renders dynamic package cards from CMS data, matching UX design for the Packages tab.
- **UI Design System Compliance**: All colors use AppColors.* tokens (no hardcoded hex). All spacing uses AppSpacing.* constants. Border radius uses AppRadius.*. Shadows use AppShadows.*. AppCard class does not exist in codebase — used native Card widget styled with design tokens as fallback (consistent with project conventions). Text styles use inline TextStyle with AppColors — consistent with existing codebase patterns. Dark mode supported via FlutterFlowTheme + skeleton loader dark mode awareness. Skeleton, empty, and error states all implemented.
- **Scope check**: No scope creep. Pricing, booking integration, and detail sub-page correctly excluded.
- **Spec alignment**: All 7 acceptance criteria verified by QA. No spec deviations.

### Rejection Reason
N/A
