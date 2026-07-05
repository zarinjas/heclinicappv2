# P2-T04 — Doctor Management CRUD

## Task ID
P2-T04

## Title
Doctor Management Module — CRUD with Visibility Toggle and Plato Facility Link

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T04 |
| Slug | doctor-management-crud |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 4 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P2-T03 |
| Blocked Reason | N/A |

---

## Description

Build the Doctor Management module in the Laravel Admin Panel. Provide full CRUD for doctors with photo upload, bio, specialty, visibility toggle (`is_visible_in_app`, default OFF), and Plato facility link. The `is_visible_in_app` toggle controls which doctors appear in the mobile app booking flow. Per v2-decisions.md Process 2 Step 4.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 4: "Doctor Management module — CRUD + photo upload + bio + visibility toggle (is_visible_in_app, default OFF) + Plato facility link"
- `docs/v2-decisions.md` — Process 5, Step 3: Doctor selection screen filters by is_visible_in_app (this is the CRITICAL dependency blocking P5-T03)
- `docs/v2-ux-spec.md` — "SCREEN: Booking Flow — Step 2: Select Doctor" (line 506)
- `laravel/app/Models/Doctor.php` — created in P2-T02
- `laravel/app/Models/Branch.php` — created in P2-T02

---

## Scope

### In Scope
- Create `DoctorController` with CRUD methods (index, create, store, edit, update, destroy)
- Blade views: index (table with name, specialty, branch, visibility status, actions), create/edit form (photo upload, bio textarea, visibility toggle, branch dropdown, Plato facility ID)
- Validation: name required, branch_id required, plato_facility_id unique, photo max 2MB image file
- Photo upload handling (store in `storage/app/public/doctors/`, serve via `php artisan storage:link`)
- `is_visible_in_app` toggle (checkbox/slide toggle, default OFF — critical for P5-T03)
- `is_active` toggle for soft disable
- Branch dropdown (populated from branches table)
- Plato facility ID input (maps doctor to Plato facility record)
- Bio textarea with character limit
- Specialty text input
- Admin sidebar navigation link
- Seed 2-3 sample doctors for testing

### Out of Scope
- Calendar setup and Plato calendar color ID mapping (P2-T06)
- Doctor profile in mobile app CMS (Process 9 Step 5)
- Staff account linking (user_id FK — can be set in future if needed)
- Patient assignment per doctor

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/DoctorController.php` — CRUD controller with photo upload
- `laravel/app/Http/Requests/StoreDoctorRequest.php` — form request validation
- `laravel/app/Http/Requests/UpdateDoctorRequest.php` — form request validation
- `laravel/resources/views/admin/doctors/index.blade.php` — list view with visibility badges
- `laravel/resources/views/admin/doctors/create.blade.php` — create form
- `laravel/resources/views/admin/doctors/edit.blade.php` — edit form
- `laravel/resources/views/admin/doctors/show.blade.php` — detail view
- `laravel/resources/views/layouts/admin.blade.php` — add Doctors to sidebar nav
- `laravel/routes/web.php` — add doctor resource route
- `laravel/database/seeders/DoctorSeeder.php` — sample data
- `laravel/config/filesystems.php` — ensure public disk is configured
- `laravel/storage/app/public/doctors/` — create directory (via migration or seeder)

### API Endpoints
- N/A (web-based admin panel CRUD)
- Future consideration: API endpoint `GET /api/v2/admin/doctors?branch_id=X&is_visible_in_app=true` for mobile app to consume directly from Admin Panel

### Data / Schema
- `doctors` table (created in P2-T02): name, specialty, bio, photo, branch_id, plato_facility_id, is_visible_in_app, is_active

### UI Components (Admin Panel — Blade)
- Index table: search by name/specialty, sortable columns, pagination (10 per page), filter by branch (dropdown), filter by visibility (toggle/checkbox)
- Visibility badge: Visible (green eye icon) / Hidden (grey eye-off icon)
- Active badge: Active (green) / Inactive (red)
- Form: text input for name, text input for specialty, select dropdown for branch, text input for Plato facility ID, textarea for bio (max 500 chars), file input for photo with preview, checkbox for is_visible_in_app, checkbox for is_active
- Photo preview on edit page (show current image)
- Delete confirmation with cascade warning (linked calendars will be removed)

### Constraints
- `is_visible_in_app` MUST default to `false` (OFF) — this is explicitly stated in v2-decisions.md
- Doctor must be linked to a branch (branch_id FK required)
- Plato facility ID links doctor to Plato facility (different from branch.plato_facility_id)
- Photo upload: max 2MB, allowed formats: jpg, jpeg, png, webp
- All routes under `/admin/` prefix with auth middleware

---

## Acceptance Criteria

- [ ] Doctor index page loads showing all doctors in a paginated table (name, specialty, branch, visibility, status, actions)
- [ ] Create doctor form stores a new doctor with all fields including photo upload and `is_visible_in_app = false` by default
- [ ] Edit doctor form pre-fills all fields and updates correctly on save including photo replacement
- [ ] Visibility toggle correctly sets `is_visible_in_app` — default OFF for new doctors, togglable in edit
- [ ] Photo upload works — file saved to `storage/app/public/doctors/`, accessible via public URL
- [ ] Delete doctor removes the record and cascades to plato_calendars
- [ ] Branch dropdown shows all active branches from the branches table
- [ ] Plato facility ID field accepts and stores the facility reference
- [ ] Doctor link appears in admin sidebar navigation
- [ ] Flash success/error messages appear after all CRUD operations

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created full Doctor Management CRUD module in Laravel Admin Panel. Implemented DoctorController with index (searchable, filterable by branch and visibility), create, store (with photo upload to storage/app/public/doctors/), show, edit, update (with photo replacement), and destroy (with photo cleanup and cascade delete). Created Blade views: index (table with name/avatar, specialty, branch, visibility badge with eye icon, active badge, actions), create/edit forms (photo upload, branch dropdown, specialty, bio with 500 char counter, Plato facility ID, is_visible_in_app toggle default OFF, is_active toggle), show page. Added doctors resource route to web.php, added Doctors sidebar nav link (replaced "Soon" placeholder), created DoctorSeeder with 3 sample doctors, registered in DatabaseSeeder.

### Files Changed
- `laravel/app/Http/Controllers/Admin/DoctorController.php` (new)
- `laravel/app/Http/Requests/StoreDoctorRequest.php` (new)
- `laravel/app/Http/Requests/UpdateDoctorRequest.php` (new)
- `laravel/resources/views/admin/doctors/index.blade.php` (new)
- `laravel/resources/views/admin/doctors/create.blade.php` (new)
- `laravel/resources/views/admin/doctors/edit.blade.php` (new)
- `laravel/resources/views/admin/doctors/show.blade.php` (new)
- `laravel/routes/web.php` (modified — added doctors resource route)
- `laravel/resources/views/layouts/admin.blade.php` (modified — replaced Doctors "Soon" placeholder with active nav link)
- `laravel/database/seeders/DoctorSeeder.php` (new)
- `laravel/database/seeders/DatabaseSeeder.php` (modified — added DoctorSeeder)

### Decisions Made During Implementation
- Used Storage facade for public disk photo uploads (requires `php artisan storage:link`)
- Photo upload limited to 2MB, jpg/jpeg/png/webp formats
- is_visible_in_app defaults to 0 (OFF/false) via checkbox hidden input pattern, matching BranchController convention
- Cascade delete on plato_calendars handled by FK constraint in migration (cascadeOnDelete)
- Branch dropdown filtered to active branches only
- Index page includes branch filter dropdown, visibility filter checkbox, and text search

### Known Limitations
- Requires `php artisan storage:link` to serve uploaded photos
- No image cropping/resizing — photos uploaded as-is
- PlatoFacility model not yet created; plato_facility_id is just a string reference
- No Plato API sync for doctor-facility validation

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] Index page loads — PASS / FAIL
- [ ] Create form with photo — PASS / FAIL
- [ ] Edit form with photo — PASS / FAIL
- [ ] Visibility toggle default OFF — PASS / FAIL
- [ ] Photo upload works — PASS / FAIL
- [ ] Delete cascades — PASS / FAIL
- [ ] Branch dropdown — PASS / FAIL
- [ ] Plato facility ID — PASS / FAIL
- [ ] Sidebar navigation — PASS / FAIL
- [ ] Flash messages — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
