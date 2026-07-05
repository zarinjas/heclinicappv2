# Targeting System — Notifications

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T02 |
| Slug | targeting-system |
| Process | 8 — Notifications Module |
| Process Step | Step 2 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P8-T01 |
| Blocked Reason | N/A |

---

## Description

Extend the notification composer with targeting — the ability to send notifications to specific audience segments rather than broadcasting to all users. Supports: All users, By Branch, By Doctor, By Appointment Date Range, and Specific Patient.

Per `docs/v2-decisions.md` Step 2 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 2 (line 104), Notification Strategy (lines 341-366)
- `docs/CODEBASE.md` — Firebase Firestore collections: fcm_tokens, users table, branch/doctor models
- `laravel/app/Models/Branch.php` — Branch model with `id`, `name`, `is_active`, relations
- `laravel/app/Models/Doctor.php` — Doctor model with `id`, `name`, `branch_id`, `is_visible_in_app`, relations
- `laravel/app/Models/User.php` — User model with roles, Notifiable trait
- `laravel/app/Models/Appointment.php` — Appointment model with `appointment_date`, `patient_name`, relations

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Add targeting type selector to Vue compose form (dropdown: All / By Branch / By Doctor / By Appointment Date Range / Specific Patient)
- Conditional dynamic fields based on selected targeting type:
  - By Branch: multi-select from branches table (active branches only)
  - By Doctor: multi-select from doctors table (filtered by branch if branch selected)
  - By Appointment Date Range: date range picker (from/to), optional branch filter
  - Specific Patient: searchable patient input (autocomplete or text with patient lookup via Plato)
- Update `NotificationLog` model to store targeting data in existing `target_type` and `target_ids` columns
- Update `NotificationController@send` to parse and store targeting data

### Out of Scope
- Actual targeted message delivery logic (comes in P8-T04)
- Patient search via Plato API integration (use text input placeholder; full Plato search in P8-T07)
- FCM token resolution for target segments (P8-T04)
- Date range validation against Plato appointment data (P8-T07)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/resources/js/Pages/Admin/Notifications/Compose.vue` — ADD: targeting type dropdown + conditional dynamic fields
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — UPDATE: `send()` to accept and validate targeting fields, store in NotificationLog
- `laravel/app/Models/NotificationLog.php` — VERIFY: `target_type` (e.g. 'all', 'branch', 'doctor', 'date_range', 'specific_patient') and `target_ids` (JSON array of IDs) fillable
- `laravel/app/Models/Branch.php` — READ ONLY (reference for listing branches)
- `laravel/app/Models/Doctor.php` — READ ONLY (reference for listing doctors)

### API Endpoints
- `POST /admin/notifications/compose` — updated to accept: `target_type` (required), `target_ids[]` (array), `date_from` (nullable date), `date_to` (nullable date)

### Data / Schema
`notifications_log` table:
- `target_type` — varchar(50): one of `'all'`, `'branch'`, `'doctor'`, `'appointment_date_range'`, `'specific_patient'`
- `target_ids` — JSON nullable: array of branch/doctor/patient IDs (e.g. `[1, 3, 5]`)
- `target_date_from` — nullable date column (need to add via migration)
- `target_date_to` — nullable date column (need to add via migration)

**NEW MIGRATION:** `2026_07_05_000013_add_targeting_fields_to_notifications_log.php` with `$table->date('target_date_from')->nullable()->after('target_ids'); $table->date('target_date_to')->nullable()->after('target_date_from');`

### UI Components (Admin Panel — Vue 3)
- Targeting type: `<select>` dropdown with 5 options
- Branch multi-select: checkboxes or multi-select component populated via Inertia prop `branches` (active only)
- Doctor multi-select: checkboxes or multi-select component populated via Inertia prop `doctors`
- Date range: two `<input type="date">` fields (from, to)
- Patient search: `<input type="text">` with placeholder "Enter patient name or NRIC"
- All fields conditionally shown/hidden with `v-if` based on `target_type`

### Constraints
- Branch Admin users should only see their own branch's doctors when targeting; Super Admin sees all branches
- Follow existing Tailwind CSS form patterns from BranchController/DoctorController create forms

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] The compose form shows a "Target Audience" dropdown with 5 options: All, By Branch, By Doctor, By Appointment Date Range, Specific Patient
- [ ] Selecting "By Branch" shows a multi-select list of active branches from the database
- [ ] Selecting "By Doctor" shows a multi-select list of doctors from the database
- [ ] Selecting "By Appointment Date Range" shows date from/to picker fields
- [ ] Selecting "Specific Patient" shows a text input for patient name/NRIC
- [ ] Switching targeting types correctly hides/shows only the relevant fields (no stale field data persists)
- [ ] Submitting the form stores the selected `target_type` and `target_ids` in the `notifications_log` table
- [ ] Branch Admin users see only their branch's doctors (not all doctors)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
- Created migration `2026_07_05_000013_add_targeting_fields_to_notifications_log.php` adding `target_date_from` and `target_date_to` columns to `notifications_log` table
- Updated `NotificationLog` model: added `target_date_from`, `target_date_to` to `$fillable` and `$casts` (date)
- Updated `NotificationController@compose()` to pass `$branches` (active only) and `$doctors` (filtered by branch if user has `branch_id`) to the Blade view
- Updated `NotificationController@send()` to accept and validate `target_type` (required, one of 5 values), `target_ids` (array of integers), `target_date_from`, `target_date_to`, `target_patient` (string). For `specific_patient` type, patient text is stored as a single-element `target_ids` array.
- Updated `compose.blade.php`: added "Target Audience" section with dropdown selector and 4 conditional panels (branch checkboxes, doctor checkboxes, date range inputs, patient text input) toggled via JavaScript

### Files Changed
- `laravel/database/migrations/2026_07_05_000013_add_targeting_fields_to_notifications_log.php` (NEW)
- `laravel/app/Models/NotificationLog.php` — added 2 fillable fields + date casts
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — updated compose() and send()
- `laravel/resources/views/admin/notifications/compose.blade.php` — added targeting section with JS toggle

### Decisions Made During Implementation
- Used plain Blade (not Vue/Inertia) since the existing codebase uses Blade templates exclusively
- Patient targeting uses a plain text input as placeholder (full Plato search deferred to P8-T07)
- Branch Admin doctor filtering uses `auth()->user()->branch_id` — same pattern as other controllers
- Date range validation uses Laravel's `after_or_equal` rule on `target_date_to`
- For "All Users" targeting, `target_ids` is set to null (no filter needed)

### Known Limitations
- Patient targeting stores the text input in `target_ids` JSON array as-is; no Plato validation yet
- No autocomplete for patient search (deferred to P8-T07)
- Branch admin filtering relies on existing `branch_id` on User model

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
