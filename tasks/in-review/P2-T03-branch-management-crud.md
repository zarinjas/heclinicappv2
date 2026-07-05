# P2-T03 — Branch Management CRUD

## Task ID
P2-T03

## Title
Branch Management Module — CRUD with WhatsApp Number and Plato Facility ID

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T03 |
| Slug | branch-management-crud |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 3 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P2-T02 |
| Blocked Reason | N/A |

---

## Description

Build the Branch Management module in the Laravel Admin Panel. Provide full CRUD for branches with WhatsApp number per branch and Plato facility ID mapping. Use Blade views with the admin layout from P2-T01. The Plato facility ID maps to Plato's `GET /facility` response for cross-referencing. Per v2-decisions.md Process 2 Step 3.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 3: "Branch Management module — CRUD + WhatsApp number per branch + Plato facility ID mapping"
- `docs/v2-decisions.md` — Process 5, Step 2: Branch selection screen references Admin Panel branch data
- `docs/v2-decisions.md` — Process 5, Step 6: WhatsApp redirect uses branch WhatsApp number
- `laravel/app/Models/Branch.php` — created in P2-T02
- `laravel/resources/views/layouts/admin.blade.php` — created in P2-T01
- `laravel/routes/web.php` — admin routes from P2-T01

---

## Scope

### In Scope
- Create `BranchController` with CRUD methods (index, create, store, edit, update, destroy)
- Blade views: index (table with name, phone, WhatsApp, Plato facility ID, status), create/edit form, show details
- Validation: name required, phone and whatsapp_number validated as Malaysian phone format, plato_facility_id must be unique per branch
- List all branches in admin index with active/inactive toggle
- Store WhatsApp number per branch (used in P5-T06 for booking redirect)
- Store Plato facility ID mapping (used in booking flow to link branch to Plato facility data)
- Form validation with error messages in Blade
- Flash messages on create/update/delete success
- Seed sample branches (optional, 2-3 Malaysian branches for testing)
- Admin sidebar navigation link to Branches module

### Out of Scope
- Doctor management CRUD (P2-T04)
- Calendar setup UI (P2-T06)
- Branch assignment to users/staff (can be done in Process 7)
- Public API endpoints for branch list (Process 5 booking flow uses Plato proxy; Admin Panel data may supplement via future API)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/BranchController.php` — CRUD controller
- `laravel/app/Http/Requests/StoreBranchRequest.php` — form request validation
- `laravel/app/Http/Requests/UpdateBranchRequest.php` — form request validation
- `laravel/resources/views/admin/branches/index.blade.php` — list view
- `laravel/resources/views/admin/branches/create.blade.php` — create form
- `laravel/resources/views/admin/branches/edit.blade.php` — edit form
- `laravel/resources/views/admin/branches/show.blade.php` — detail view
- `laravel/resources/views/layouts/admin.blade.php` — add Branches to sidebar nav
- `laravel/routes/web.php` — add branch resource route
- `laravel/database/seeders/BranchSeeder.php` — sample data

### API Endpoints
- N/A (web-based admin panel CRUD)

### Data / Schema
- `branches` table (created in P2-T02): name, address, phone, whatsapp_number, image, operating_hours, plato_facility_id, is_active

### UI Components (Admin Panel — Blade)
- Table listing: searchable by name, sortable columns, pagination (10 per page)
- Status badge: Active (green) / Inactive (grey)
- Action buttons: View, Edit, Delete (with confirmation modal)
- Form: text inputs for name/phone/WhatsApp/Plato facility ID, textarea for address, toggle for is_active
- Operating hours: text field with hint format "Mon-Fri: 8:00 AM - 5:00 PM, Sat: 8:00 AM - 1:00 PM"
- Image field: file upload placeholder (actual upload implementation can be in future process)
- Delete confirmation SweetAlert or Blade modal

### Constraints
- `plato_facility_id` should match the ID returned by Plato's `GET /facility` endpoint
- WhatsApp number format: Malaysian (+60) prefix, stored as string
- Super Admin can manage all branches; Branch Admin restricted to own branch (middleware enforcement not required yet, but code structure should support future scoping)
- All routes under `/admin/` prefix with `auth` and `role:super_admin` middleware

---

## Acceptance Criteria

- [ ] Branch index page loads showing all branches in a paginated table (name, phone, WhatsApp, Plato facility ID, status, actions)
- [ ] Create branch form validates required fields (name) and stores a new branch with all fields
- [ ] Edit branch form pre-fills existing data and updates correctly on save
- [ ] Delete branch shows confirmation and removes the branch (with cascade to doctors/calendars)
- [ ] Active/inactive toggle works — inactive branches can be filtered/hidden
- [ ] Plato facility ID is stored and displayed correctly
- [ ] WhatsApp number field accepts +60 format numbers
- [ ] Flash success message appears after create/update/delete operations
- [ ] Branch link appears in admin sidebar navigation

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created full Branch Management CRUD module in Laravel Admin Panel:
- BranchController with index (search + sort + paginate), create, store, show, edit, update, destroy
- StoreBranchRequest and UpdateBranchRequest with validation (Malaysian WhatsApp prefix +60 required, unique Plato facility ID)
- Blade views: index (searchable table with active/inactive badges, sortable name column, pagination), create/edit forms with all fields, show detail view
- Sidebar navigation updated: Branches placeholder replaced with active route link
- Resource routes registered under /admin/ with auth + role:super_admin middleware
- BranchSeeder with 3 sample Malaysian branches (Shah Alam, Bangi active; Putrajaya inactive)
- Flash success messages on create/update/delete
- Delete confirmation via JavaScript confirm()
- Hidden input for is_active to handle unchecked checkbox (value=0)

### Files Changed
- laravel/app/Http/Controllers/Admin/BranchController.php (new)
- laravel/app/Http/Requests/StoreBranchRequest.php (new)
- laravel/app/Http/Requests/UpdateBranchRequest.php (new)
- laravel/resources/views/admin/branches/index.blade.php (new)
- laravel/resources/views/admin/branches/create.blade.php (new)
- laravel/resources/views/admin/branches/edit.blade.php (new)
- laravel/resources/views/admin/branches/show.blade.php (new)
- laravel/resources/views/layouts/admin.blade.php (updated sidebar)
- laravel/routes/web.php (added resource route)
- laravel/database/seeders/BranchSeeder.php (new)
- laravel/database/seeders/DatabaseSeeder.php (added BranchSeeder call)

### Decisions Made During Implementation
- Used Laravel resource route (Route::resource) which provides all 7 CRUD routes automatically
- Search filters by name, phone, or Plato facility ID
- Sortable column on name with ascending/descending toggle via URL params
- Clipboard-friendly empty state on index page when no branches exist

### Known Limitations
- Image field is a URL text input; file upload to be added in future process (Process 9 CMS covers branch profile photos)
- Delete uses JavaScript confirm() rather than a Blade modal; can upgrade later
- pagination navigation uses default Tailwind/Laravel style; styling pass needed for consistency

### Files Changed
- laravel/app/Http/Controllers/Admin/BranchController.php (new)
- laravel/app/Http/Requests/StoreBranchRequest.php (new)
- laravel/app/Http/Requests/UpdateBranchRequest.php (new)
- laravel/resources/views/admin/branches/index.blade.php (new)
- laravel/resources/views/admin/branches/create.blade.php (new)
- laravel/resources/views/admin/branches/edit.blade.php (new)
- laravel/resources/views/admin/branches/show.blade.php (new)
- laravel/resources/views/layouts/admin.blade.php (updated sidebar)
- laravel/routes/web.php (added resource route)
- laravel/database/seeders/BranchSeeder.php (new)
- laravel/database/seeders/DatabaseSeeder.php (added BranchSeeder call)

### Decisions Made During Implementation
- Used Laravel resource route (Route::resource) which provides all 7 CRUD routes automatically
- Search filters by name, phone, or Plato facility ID
- Sortable column on name with ascending/descending toggle via URL params
- Inactive branches are marked with gray badge and hidden unchecked checkbox on create
- Delete uses JavaScript confirm() for immediate feedback

### Known Limitations
- Image field is a URL text input; file upload to be added in Process 9 (CMS)
- Delete confirmation via JS prompt rather than modal component; can upgrade later
- Pagination uses default Tailwind/Laravel style (pagination passed to view via ->links())
- Branch admin scope restriction (own branch only) not enforced yet — middleware ready for future scoping as noted in task constraints

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

PASSED

### Criteria Results
- [ ] Index page loads — PASS — index.blade.php has full paginated table with search, sortable name column, all required columns, pagination links
- [ ] Create form works — PASS — create.blade.php has all fields with proper validation error display, StoreBranchRequest validates name required, WhatsApp +60 prefix, unique Plato facility ID
- [ ] Edit form works — PASS — edit.blade.php pre-fills all fields via old('field', $branch->field), UpdateBranchRequest ignores current branch on unique check
- [ ] Delete works — PASS — JS confirm() dialog on submit, cascadeOnDelete on doctors.branch_id migration ensures related records removed
- [ ] Active/inactive toggle — PASS — checkbox with hidden input for 0 ensures false value submitted, status badge in index (green/gray)
- [ ] Plato facility ID — PASS — field in create/edit forms and displayed in index table + show detail view
- [ ] WhatsApp number — PASS — regex /^\+60/ validation in both StoreBranchRequest and UpdateBranchRequest with custom message
- [ ] Flash messages — PASS — session('success') block in admin.blade.php layout, controller uses ->with('success', ...) on create/update/delete
- [ ] Sidebar navigation — PASS — Branches placeholder replaced with active route link, routeIs('admin.branches.*') for active state highlighting

### Failure Details
N/A — All 9/9 criteria PASSED

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
