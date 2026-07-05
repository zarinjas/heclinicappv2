# Doctor Profiles CMS Enhancements — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P9-T05 |
| Slug | doctor-profiles-cms |
| Process | 9 — CMS Module |
| Process Step | Step 5 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | P2-T04 (Doctor Management CRUD — DONE) |
| Blocked Reason | N/A |

---

## Description

Enhance the existing Doctor Management module in the Laravel Admin Panel to support photo upload (Firebase Storage), a TipTap rich text bio editor, specialty field, and batch branch assignment. The existing model (`Doctor.php`:42) already has `fillable` for all these fields (`photo`, `bio`, `specialty`, `branch_id`, `is_visible_in_app`, `is_active`), but the admin Blade view (from P2-T04) needs a rich form with image upload preview and a rich text editor for the bio. Ensure Flutter doctor config API (`GET /api/v2/config/doctors`) returns photo and bio fields for mobile display.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 9 Step 5 (line 118), Decision #9 (line 22): Doctor photos and bio managed by Admin Panel CMS
- `docs/v2-ux-spec.md` — Doctor Cards (lines 368-369)
- `docs/CODEBASE.md` — Doctor model (Section 20), existing DoctorController
- `docs/api-guidelines.md` — N/A

---

## Scope

### In Scope
- Laravel: Enhance existing `Admin/DoctorController` form Blade view to include:
  - Photo upload with preview (upload to Firebase Storage, store URL in `photo` column)
  - TipTap rich text bio editor (or textarea with basic formatting if TipTap not available)
  - Specialty text input
  - Branch assignment dropdown (select from existing branches)
  - Visibility toggle (is_visible_in_app)
- Laravel: Update `Admin/DoctorController@store` and `@update` to handle multipart photo upload
- Laravel: Ensure existing `GET /api/v2/config/doctors` (from `Api/DoctorConfigController`) returns `photo`, `bio`, `specialty` fields alongside existing data
- Laravel: Delete photo from Firebase Storage when doctor is deleted
- Flutter: Verify `DoctorConfigController` or the Flutter-side doctor data model reads `photo` and `bio` for display
- Flutter: If doctor card in `homepage_new_widget.dart` renders doctor list, ensure it uses `photo` (CachedNetworkImage) and `bio` fields from API

### Out of Scope
- Creating new doctors in Admin Panel (already exists from P2-T04 — enhance existing form only)
- Doctor login/user account creation
- Plato facility sync for doctors (already handled in P2-T04)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/DoctorController.php` — enhance store/update to handle photo upload, enhance destroy to remove photo
- `laravel/resources/views/admin/doctors/form.blade.php` — add photo upload with preview, TipTap bio, specialty, branch dropdown, visibility toggle
- `laravel/resources/views/admin/doctors/index.blade.php` — show photo thumbnail in table
- `laravel/app/Http/Controllers/Api/DoctorConfigController.php` — verify response includes photo, bio, specialty
- `lib/backend/api_requests/api_calls.dart` — verify `DoctorConfigCall` returns photo+bio (or add if missing)
- `lib/front_page/homepage_new/homepage_new_widget.dart` — doctor card rendering (verify photo CachedNetworkImage usage)

### API Endpoints
- Existing: `GET /api/v2/config/doctors` — must include `photo`, `bio`, `specialty` in response
- Existing admin routes: `POST /admin/doctors`, `PUT /admin/doctors/{id}`, `DELETE /admin/doctors/{id}`

### Data / Schema
Doctor model (`laravel/app/Models/Doctor.php`) already has fillable:
```php
protected $fillable = [
    'user_id', 'branch_id', 'name', 'specialty', 'bio', 'photo',
    'plato_facility_id', 'is_visible_in_app', 'is_active',
];
```

### UI Components (Flutter)
- Doctor cards on home screen (or booking flow): circular avatar (80px) using CachedNetworkImage for `photo`, fallback to placeholder if no photo
- Doctor name + specialty displayed below avatar

### Constraints
- Photo must be uploaded via Laravel to Firebase Storage (not directly from Flutter)
- `is_visible_in_app = true` doctors only shown in app (existing filtering in DoctorConfigController)
- Plato `/facility` still provides name — our CMS adds photo + bio

---

## Acceptance Criteria

- [ ] Admin doctor form includes photo upload with image preview (upload to Firebase Storage, store URL)
- [ ] Admin doctor form includes rich text bio editor (TipTap or basic formatting)
- [ ] Admin doctor form includes specialty text input
- [ ] Admin doctor form includes branch assignment dropdown (list of existing branches)
- [ ] Admin doctor form includes visibility toggle (is_visible_in_app)
- [ ] Admin can edit existing doctor: change photo, bio, specialty, branch, visibility
- [ ] Deleting a doctor also removes associated photo from Firebase Storage
- [ ] `GET /api/v2/config/doctors` response includes `photo`, `bio`, `specialty` fields for each doctor
- [ ] Flutter doctor rendering uses `photo` from CMS (CachedNetworkImage) with fallback placeholder

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

