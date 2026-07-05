# Branch Profiles CMS Enhancements — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T06 |
| Slug | branch-profiles-cms |
| Process | 9 — CMS Module |
| Process Step | Step 6 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | P2-T03 (Branch Management CRUD — DONE) |
| Blocked Reason | N/A |

---

## Description

Enhance the existing Branch Management module in the Laravel Admin Panel to support photo upload (Firebase Storage), Google Maps link, and rich operating hours configuration. The existing model (`Branch.php`:38) already has `fillable` for `image`, `address`, `operating_hours` (cast as array), and `whatsapp_number`. Add `google_maps_link` to the migration and model. Enhance the admin Blade form with photo upload preview, structured operating hours editor, and Google Maps link input. Ensure Flutter branch config API (`GET /api/v2/config/branches`) returns these CMS fields.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 6 (line 119), Decision #11 (line 24): Branch photos managed by Admin Panel CMS
- `docs/v2-ux-spec.md` — Booking flow branch selection screen (Process 5, line 75), Branch info sections
- `docs/CODEBASE.md` — Branch model (Section 20), existing BranchController, branch table migration
- `docs/api-guidelines.md` — N/A

---

## Scope

### In Scope
- Laravel: New migration to add `google_maps_link` column (VARCHAR 500 NULL) to `branches` table
- Laravel: Update `Branch` model `$fillable` to include `google_maps_link`
- Laravel: Enhance `Admin/BranchController` form Blade view:
  - Photo upload with preview (upload to Firebase Storage, store URL in `image` column)
  - Google Maps link input (URL to Google Maps location)
  - Structured operating hours editor (e.g., JSON array of `{day, open_time, close_time, is_closed}`)
  - Address textarea, phone input, WhatsApp number input
  - Plato facility ID input, active toggle
- Laravel: Update `Admin/BranchController@store` and `@update` to handle multipart photo upload and operating_hours array
- Laravel: Delete photo from Firebase Storage when branch is deleted
- Laravel: Ensure `GET /api/v2/config/branches` endpoint returns `image`, `address`, `operating_hours`, `whatsapp_number`, `google_maps_link`
- Laravel: Create `GET /api/v2/config/branches` public API endpoint if not already existing (for booking branch selection screen)
- Flutter: Verify booking flow branch selection screen uses `image` for branch photo and `address`/`operating_hours` for display

### Out of Scope
- Creating new branches in Admin Panel (already exists from P2-T03 — enhance existing form only)
- Branch analytics or appointment count display
- Branch-specific working hours for appointment slot filtering (Plato handles via Calendar Setup)

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/{timestamp}_add_google_maps_link_to_branches_table.php` — new migration
- `laravel/app/Models/Branch.php` — add `google_maps_link` to fillable
- `laravel/app/Http/Controllers/Admin/BranchController.php` — enhance store/update to handle photo upload and operating_hours array, enhance destroy to remove photo
- `laravel/resources/views/admin/branches/form.blade.php` — add photo upload preview, Google Maps link input, operating hours editor
- `laravel/resources/views/admin/branches/index.blade.php` — show photo thumbnail in table
- `laravel/routes/api.php` — add `GET /api/v2/config/branches` if not present
- `laravel/app/Http/Controllers/Api/BranchConfigController.php` — new or enhanced controller for branches API
- `lib/backend/api_requests/api_calls.dart` — verify branch config API call exists

### API Endpoints
- New: `GET /api/v2/config/branches` — return `[{id, name, address, phone, whatsapp_number, image, operating_hours, google_maps_link}]` for active branches
- Existing admin routes: `POST /admin/branches`, `PUT /admin/branches/{id}`, `DELETE /admin/branches/{id}`

### Data / Schema
Branch model (`laravel/app/Models/Branch.php`) already has:
```php
protected $fillable = [
    'name', 'address', 'phone', 'whatsapp_number', 'image',
    'operating_hours', 'plato_facility_id', 'is_active',
];
```
New field to add: `google_maps_link` (VARCHAR 500, nullable)

Operating hours storage format (JSON array in `operating_hours` column, cast to array):
```json
[
  {"day": "Monday", "open_time": "09:00", "close_time": "18:00", "is_closed": false},
  {"day": "Tuesday", "open_time": "09:00", "close_time": "18:00", "is_closed": false},
  ...
]
```

### UI Components (Flutter)
- Branch selection screen (booking flow): branch card with name, address, image (CachedNetworkImage), operating hours, Google Maps link button
- Skeleton loader while fetching branches

### Constraints
- Photo must be uploaded via Laravel to Firebase Storage
- `whatsapp_number` used by booking WhatsApp redirect (Process 5 Step 6)
- `plato_facility_id` maps to Plato `/facility` for doctor listing

---

## Acceptance Criteria

- [ ] `google_maps_link` column added to branches table (migration runs successfully)
- [ ] Admin branch form includes photo upload with image preview (upload to Firebase Storage, store URL in `image`)
- [ ] Admin branch form includes Google Maps link input
- [ ] Admin branch form includes structured operating hours configuration (per day: open time, close time, closed toggle)
- [ ] Admin can edit existing branch with all CMS fields (photo, maps link, hours, address, WhatsApp, phone)
- [ ] Deleting a branch removes associated photo from Firebase Storage
- [ ] `GET /api/v2/config/branches` returns `image`, `address`, `operating_hours`, `whatsapp_number`, `google_maps_link` for active branches
- [ ] Flutter booking flow branch selection screen uses CMS branch data (image, address, operating_hours)

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

