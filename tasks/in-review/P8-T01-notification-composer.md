# Notification Composer — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T01 |
| Slug | notification-composer |
| Process | 8 — Notifications Module |
| Process Step | Step 1 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Create the admin panel notification composer page — a form where staff can draft and send push notifications. The composer must include fields for title, body, and optional image URL. This is the entry point for all manual notification sends in Process 8, replacing the current "broadcast all" approach with a structured UI.

Per `docs/v2-decisions.md` Step 1 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8, Section "Notifications Module" (lines 101-111), Notification Strategy (lines 341-366)
- `docs/v2-ux-spec.md` — Admin Panel UI specs (lines 830-948): forms max 720px centered, section grouping, button styling
- `docs/CODEBASE.md` — Firebase Section (Firestore collections: ff_push_notifications, historynotif), Admin Panel architecture
- `docs/api-guidelines.md` — N/A for this task

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Create `NotificationController` in `laravel/app/Http/Controllers/Admin/`
- Create Inertia.js + Vue 3 composer page with: title (text input), body (textarea), image_url (text input, optional)
- Add POST route `admin/notifications/compose` to `laravel/routes/web.php`
- Form validation: title required (max 255), body required (max 2000), image_url optional (valid URL if provided)
- Write draft to `notifications_log` table with status=`draft` (send logic comes in P8-T04)
- Basic success flash message after compose

### Out of Scope
- Targeting (P8-T02)
- Channel selection (P8-T03)
- Actual push send logic (P8-T04)
- Notification history list view (P8-T08)
- Email sending (P8-T05)
- In-app write (P8-T06)
- Automated triggers (P8-T07)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — NEW: controller with `compose()` (show form) and `send()` (validate + save draft)
- `laravel/routes/web.php` — ADD: `GET /admin/notifications/compose` and `POST /admin/notifications/compose` inside auth+role middleware group
- `laravel/resources/js/Pages/Admin/Notifications/Compose.vue` — NEW: Inertia/Vue form component using Tailwind CSS
- `laravel/resources/js/Layouts/AdminLayout.vue` — possibly: add sidebar nav link "Notifications" with sub-items (Compose, History)

### API Endpoints
- `GET /admin/notifications/compose` — Show compose form page
- `POST /admin/notifications/compose` — Submit notification draft

### Data / Schema
Writing to `notifications_log` table (migration: `2026_07_05_000005_create_notifications_log_table.php`):
- `type` = `'manual'`
- `title` — from form
- `body` — from form
- `image` (needs column addition or store image_url in body/notes field)
- `target_type` = `'all'` (placeholder; P8-T02 adds targeting)
- `target_ids` = `null`
- `channels` = `['push', 'email', 'in_app']` (placeholder; P8-T03 makes this configurable)
- `status` = `'draft'`

**NOTE:** The current `notifications_log` migration lacks an `image_url` column. Add a migration: `2026_07_05_000012_add_image_to_notifications_log.php` with `$table->string('image_url', 500)->nullable()->after('body');`

### UI Components (Admin Panel — Vue 3 + Inertia.js + Tailwind CSS)
Use existing admin layout pattern from `DoctorController@create` or `BranchController@create`:
- Page title: "Compose Notification"
- Form max-w-3xl, centered
- Input group: Title (type="text", required, maxlength=255)
- Textarea group: Body (rows=6, required, maxlength=2000)
- Input group: Image URL (type="url", optional, placeholder="https://...")
- Submit button: "Save Draft" (primary color)
- Flash message on success: green banner "Notification draft saved"

### Constraints
- Must use Inertia.js + Vue 3 + Tailwind CSS (matching existing admin pages)
- Must be wrapped in `auth` + `role:super_admin,branch_admin,staff` middleware
- All Plato calls must route through Laravel proxy (N/A here — no Plato calls needed)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Visiting `/admin/notifications/compose` while logged in as admin shows the compose form with title, body, and image URL fields
- [ ] Submitting the form with valid data saves a record to the `notifications_log` table with status `'draft'`
- [ ] Submitting the form with empty title or body shows validation errors inline
- [ ] Submitting the form with an invalid image_url format shows a validation error
- [ ] Successful submission displays a success flash message and redirects back to the compose page (or shows success banner)
- [ ] The "Notifications" nav item exists in the admin sidebar (can navigate to compose)
- [ ] Visiting the compose page while not logged in redirects to `/admin/login`
- [ ] The `notifications_log` table has the `image_url` column after migration

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created the admin panel notification composer — a Blade form page where staff can draft notifications with title, body, and optional image URL. Writes drafts to `notifications_log` MySQL table with status `draft` and placeholder targeting (`all`) and channels (`push`, `email`, `in_app`) for future Process 8 tasks.

### Files Changed
- `laravel/database/migrations/2026_07_05_000012_add_image_to_notifications_log.php` — NEW: adds `image_url` column to `notifications_log` table
- `laravel/app/Models/NotificationLog.php` — UPDATE: added `image_url` to `$fillable`
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — NEW: `compose()` (show form) and `send()` (validate + save draft)
- `laravel/routes/web.php` — ADD: `GET /admin/notifications/compose` and `POST /admin/notifications/send` routes inside auth+role middleware
- `laravel/resources/views/admin/notifications/compose.blade.php` — NEW: Blade form with title, body (textarea), image_url (optional URL) inputs
- `laravel/resources/views/layouts/admin.blade.php` — ADD: Notifications sidebar nav link with bell icon

### Decisions Made During Implementation
- Used Blade + Tailwind CSS v4 (not Inertia/Vue) to match existing admin panel convention — all other pages are pure Blade
- Route names: `admin.notifications.compose` (GET) and `admin.notifications.send` (POST)
- Drafts saved with default channels `['push', 'email', 'in_app']` and target `all` — these will be made configurable in P8-T02 and P8-T03
- Character counter JavaScript added following the Doctors create page pattern

### Known Limitations
- Send logic not yet implemented (P8-T04); notifications saved as `draft` only
- No targeting or channel selection (P8-T02, P8-T03)
- No notification history list view yet (P8-T08)

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] {Criterion 1} — PASS — Compose route returns view with title input, body textarea, image_url input fields
- [x] {Criterion 2} — PASS — send() validates and creates NotificationLog with status='draft', type='manual'
- [x] {Criterion 3} — PASS — `required` validation rules + @error directives in Blade for both title and body
- [x] {Criterion 4} — PASS — `url` validation rule + @error('image_url') in Blade template
- [x] {Criterion 5} — PASS — redirect with `->with('success', ...)` flash message; layout renders session('success') in green banner
- [x] {Criterion 6} — PASS — Notifications nav link added to admin.blade.php sidebar with bell SVG icon
- [x] {Criterion 7} — PASS — Routes wrapped in `auth` + `role` middleware group; Laravel handles redirect to login
- [x] {Criterion 8} — PASS — Migration adds `image_url` varchar(500) nullable after `body` column

### Failure Details
N/A — All criteria PASSED.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason
