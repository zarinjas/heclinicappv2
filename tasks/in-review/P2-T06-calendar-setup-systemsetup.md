# P2-T06 — Calendar Setup UI (SystemSetup Sync)

## Task ID
P2-T06

## Title
Calendar Setup UI — Map Doctors to Plato Calendar Color IDs

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T06 |
| Slug | calendar-setup-systemsetup |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 6 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P2-T04 |
| Blocked Reason | N/A |

---

## Description

Build the Calendar Setup module in the Admin Panel. Fetch Plato calendar data from `GET /systemsetup` via the proxy layer, store calendar color IDs in the `plato_calendars` table, and provide a UI to map each doctor to their corresponding Plato calendar color ID. This mapping is required for POST /appointment/slots to check availability per doctor's calendar. Per v2-decisions.md Process 2 Step 6 and Process 5 Step 1 prerequisite.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 6: "GET /systemsetup sync — Calendar Setup UI — map doctor to Plato calendar color ID"
- `docs/v2-decisions.md` — Process 5, Step 1: "Prerequisite: Process 2 step 6 complete (Calendar Setup in Admin Panel)"
- `docs/api-guidelines.md` — "5. API Temujanji (Appointments)" — calendar color IDs from `GET /systemsetup`, `POST /appointment/slots` with `check_for_conflicts` array
- `laravel/app/Models/PlatoCalendar.php` — created in P2-T02
- `laravel/app/Models/Doctor.php` — created in P2-T02, with CRUD in P2-T04

---

## Scope

### In Scope
- Create `CalendarSetupController` with:
  - Index: list all doctor-to-calendar mappings
  - Sync: fetch calendars from Plato via `GET /systemsetup` through proxy
  - Map: associate a doctor with one or more Plato calendar color IDs
  - Unmap: remove doctor-calendar association
- Blade views: calendar setup index (table showing doctor, calendar name, calendar color ID, active status), sync button, map form
- Integration with Plato proxy: use the Laravel proxy's internal HTTP client to call Plato's `GET /systemsetup` (not going through the public proxy endpoint)
- Parse `GET /systemsetup` response to extract calendar entries (each with color ID, name, etc.)
- Store synced calendars in `plato_calendars` table linked to doctors
- Toggle calendar active/inactive per doctor
- Sync button on index page: triggers Plato fetch, updates calendar list
- Flash success/error messages
- Admin sidebar navigation link

### Out of Scope
- Creating appointments (Process 5 Step 7 and Process 7)
- Modifying Plato calendars (read-only from Plato)
- Syncing other system setup data (just calendars)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/CalendarSetupController.php` — sync and manage calendar mappings
- `laravel/app/Services/PlatoSystemSetupService.php` — service to fetch and parse Plato systemsetup data
- `laravel/resources/views/admin/calendar-setup/index.blade.php` — calendar mapping list
- `laravel/resources/views/admin/calendar-setup/map.blade.php` — map doctor to calendar form
- `laravel/resources/views/layouts/admin.blade.php` — add Calendar Setup to sidebar
- `laravel/routes/web.php` — add calendar setup routes (GET index, POST sync, POST map, DELETE unmap)

### API Endpoints (Internal)
- `GET /systemsetup` (Plato API, called internally via Laravel HTTP client) — returns calendar data
  - Response contains calendar entries with: `color` (ID), `name`, `doctor`, etc.

### Data / Schema
- `plato_calendars` table (created in P2-T02): id, doctor_id, plato_calendar_color_id, name, is_active
- Calendar data from Plato `GET /systemsetup` response:
  - `color`: the unique calendar color ID (used in `check_for_conflicts` for POST /appointment/slots)
  - `name`: calendar/doctor name from Plato
  - Additional fields: doctor mapping, facility info

### UI Components (Admin Panel — Blade)
- Index table: Doctor name, Calendar name, Plato Color ID, Active status, Actions (Edit Map, Delete)
- Sync button: large button at top "Sync Calendars from Plato" — triggers fetch and updates or inserts records
- Map form: doctor dropdown (from doctors table), calendar selection (from synced calendars), active toggle
- Last synced timestamp shown on index page
- Loading indicator during sync
- Empty state: "No calendars synced yet. Click Sync to fetch from Plato."

### Constraints
- Calendar sync must NOT create duplicate entries — upsert by plato_calendar_color_id + doctor_id
- Calendar color ID must be stored exactly as returned from Plato (string format)
- Doctors without calendar mappings should show a warning on the index
- Sync endpoint must be POST (not GET) to prevent CSRF/accidental triggering

---

## Acceptance Criteria

- [ ] Calendar Setup index page loads showing all doctor-calendar mappings with doctor name, calendar name, color ID, and active status
- [ ] "Sync Calendars from Plato" button fetches `GET /systemsetup` from Plato via internal proxy, parses response, and stores/updates calendar entries
- [ ] Synced calendars are stored in `plato_calendars` table with correct plato_calendar_color_id
- [ ] Admin can map a doctor to one or more synced calendar color IDs with active/inactive toggle
- [ ] Admin can unmap (delete) a doctor-calendar association
- [ ] Calendar Setup link appears in admin sidebar navigation
- [ ] Duplicate calendar entries are not created on repeated sync (upsert behavior)
- [ ] Last sync timestamp is displayed on the index page
- [ ] Flash success/error messages appear after sync and map operations

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
- Created `PlatoSystemSetupService` — fetches and parses calendar entries from `GET /systemsetup` via `PlatoProxyService`
- Created `CalendarSetupController` with full resource CRUD + sync endpoint (POST /admin/calendars/sync)
- Created Form Requests: `StorePlatoCalendarRequest`, `UpdatePlatoCalendarRequest`
- Created 4 Blade views: index (with sync card, search/filter, table, unmapped doctor warning, empty state), create (map doctor to calendar), edit, show
- Added migration to make `doctor_id` nullable on `plato_calendars` table (required for unlinked synced calendars)
- Added routes: `Route::resource('calendars', CalendarSetupController::class)` + explicit `POST calendars/sync` before resource
- Updated admin sidebar: replaced disabled "Calendar Setup (Soon)" placeholder with active navigation link
- Sync stores parsed calendar entries in `plato_calendars` with `doctor_id = null`, then admin maps to doctors via create form
- Last sync timestamp stored in `settings` table via `Setting` model
- Unmapped doctor warning shown on index when active doctors have no calendar mapping
- Duplicate prevention: sync upserts by `plato_calendar_color_id` + `doctor_id IS NULL`

### Files Changed
- `laravel/app/Services/PlatoSystemSetupService.php` — NEW
- `laravel/app/Http/Controllers/Admin/CalendarSetupController.php` — NEW
- `laravel/app/Http/Requests/StorePlatoCalendarRequest.php` — NEW
- `laravel/app/Http/Requests/UpdatePlatoCalendarRequest.php` — NEW
- `laravel/database/migrations/2026_07_05_000007_make_doctor_id_nullable_on_plato_calendars.php` — NEW
- `laravel/resources/views/admin/calendars/index.blade.php` — NEW
- `laravel/resources/views/admin/calendars/create.blade.php` — NEW
- `laravel/resources/views/admin/calendars/edit.blade.php` — NEW
- `laravel/resources/views/admin/calendars/show.blade.php` — NEW
- `laravel/routes/web.php` — MODIFIED (added CalendarSetupController import and routes)
- `laravel/resources/views/layouts/admin.blade.php` — MODIFIED (Calendar Setup sidebar link)

### Decisions Made During Implementation
- Made `doctor_id` nullable on `plato_calendars` table via migration — required because sync from Plato creates entries not yet mapped to any doctor
- Sync stores calendars with `doctor_id = null`; admin uses "Map Calendar" form to link to a doctor
- Duplicate prevention: checks by `plato_calendar_color_id` + `doctor_id IS NULL` for synced entries
- Calendars that no longer exist in Plato are set to `is_active = false` (not deleted)
- Sync results are flashed to session for display in the "Available Plato Calendars" panel on index page

### Known Limitations
- Calendar sync depends on `PlatoProxyService` which requires valid `PLATO_API_TOKEN` in .env — if not configured, sync will fail with 401
- The systemsetup endpoint response format may vary; the parser handles `data.calendar`, `data.calendars` arrays and recursively searches for calendar entries
- No auto-mapping by doctor name match — admin must manually map each calendar to the correct doctor

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] Index page loads — PASS / FAIL
- [ ] Sync from Plato works — PASS / FAIL
- [ ] Calendar entries stored — PASS / FAIL
- [ ] Doctor-calendar mapping — PASS / FAIL
- [ ] Unmapping works — PASS / FAIL
- [ ] Sidebar navigation — PASS / FAIL
- [ ] Duplicate prevention — PASS / FAIL
- [ ] Last sync timestamp — PASS / FAIL
- [ ] Success/error messages — PASS / FAIL

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
