# P2-T02 — MySQL Schema

## Task ID
P2-T02

## Title
MySQL Schema: Branches, Doctors, Calendars, Settings, Notifications Log

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T02 |
| Slug | mysql-schema |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 2 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P2-T01 |
| Blocked Reason | N/A |

---

## Description

Create the MySQL database schema for the Admin Panel: branches, doctors, plato_calendars, settings, and notifications_log tables. Each migration must include proper foreign keys, indexes, and default values. Create corresponding Eloquent models with relationships. Per v2-decisions.md Process 2 Step 2.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 2: "MySQL schema: branches, doctors, plato_calendars, settings, notifications_log"
- `laravel/database/migrations/` — existing migrations directory
- `laravel/app/Models/` — existing models directory (User.php already exists)
- `docs/v2-decisions.md` — Process 5 Step 2: Booking flow references Plato facility IDs (needs branches.branch_plato_facility_id)
- `docs/v2-decisions.md` — Process 5 Step 3: Doctor visibility toggle (needs doctors.is_visible_in_app)
- `docs/api-guidelines.md` — GET /systemsetup for calendar color IDs (needs plato_calendars)

---

## Scope

### In Scope
- Create `branches` migration: id, name, address, phone, whatsapp_number, image, operating_hours, plato_facility_id, is_active, created_at, updated_at
- Create `doctors` migration: id, user_id (nullable), branch_id, name, specialty, bio, photo, plato_facility_id, is_visible_in_app (default false), is_active, created_at, updated_at
- Create `plato_calendars` migration: id, doctor_id, plato_calendar_color_id, name, is_active, created_at, updated_at
- Create `settings` migration: id, key (unique), value, description, created_at, updated_at
- Create `notifications_log` migration: id, type, title, body, target_type, target_ids (JSON), channels (JSON), status, sent_at, created_at, updated_at
- Create Eloquent models: Branch, Doctor, PlatoCalendar, Setting, NotificationLog
- Define model relationships (Doctor belongsTo Branch, PlatoCalendar belongsTo Doctor, etc.)
- Add `branch_id` foreign key to `users` table (relate staff to branch)
- Add proper indexes on frequently queried columns (plato_facility_id, is_visible_in_app, status)

### Out of Scope
- Filling tables with real data (that happens in subsequent tasks via seeders/CRUD)
- CRUD controllers and views (P2-T03, P2-T04)
- Calendar setup UI (P2-T06)
- Notifications composer and sending logic (Process 8)

---

## Technical Spec

### Files to Create or Modify
- `laravel/database/migrations/xxxx_create_branches_table.php`
- `laravel/database/migrations/xxxx_create_doctors_table.php`
- `laravel/database/migrations/xxxx_create_plato_calendars_table.php`
- `laravel/database/migrations/xxxx_create_settings_table.php`
- `laravel/database/migrations/xxxx_create_notifications_log_table.php`
- `laravel/database/migrations/xxxx_add_branch_id_to_users_table.php`
- `laravel/app/Models/Branch.php`
- `laravel/app/Models/Doctor.php`
- `laravel/app/Models/PlatoCalendar.php`
- `laravel/app/Models/Setting.php`
- `laravel/app/Models/NotificationLog.php`
- `laravel/app/Models/User.php` — add relationship methods

### API Endpoints
- N/A (schema only, no API endpoints in this task)

### Data / Schema

**branches:**
| Column | Type | Constraints |
|--------|------|------------|
| id | bigint unsigned | PK, auto_increment |
| name | varchar(255) | NOT NULL |
| address | text | nullable |
| phone | varchar(50) | nullable |
| whatsapp_number | varchar(50) | nullable |
| image | varchar(255) | nullable |
| operating_hours | json | nullable |
| plato_facility_id | varchar(100) | nullable, INDEX |
| is_active | boolean | default true |
| timestamps | | created_at, updated_at |

**doctors:**
| Column | Type | Constraints |
|--------|------|------------|
| id | bigint unsigned | PK, auto_increment |
| user_id | bigint unsigned | nullable, FK → users.id (for staff login) |
| branch_id | bigint unsigned | FK → branches.id, CASCADE on delete |
| name | varchar(255) | NOT NULL |
| specialty | varchar(255) | nullable |
| bio | text | nullable |
| photo | varchar(255) | nullable |
| plato_facility_id | varchar(100) | nullable, INDEX |
| is_visible_in_app | boolean | default false, INDEX |
| is_active | boolean | default true |
| timestamps | | created_at, updated_at |

**plato_calendars:**
| Column | Type | Constraints |
|--------|------|------------|
| id | bigint unsigned | PK, auto_increment |
| doctor_id | bigint unsigned | FK → doctors.id, CASCADE on delete |
| plato_calendar_color_id | varchar(50) | NOT NULL |
| name | varchar(255) | nullable |
| is_active | boolean | default true |
| timestamps | | created_at, updated_at |

**settings:**
| Column | Type | Constraints |
|--------|------|------------|
| id | bigint unsigned | PK, auto_increment |
| key | varchar(255) | NOT NULL, UNIQUE |
| value | text | nullable |
| description | varchar(255) | nullable |
| timestamps | | created_at, updated_at |

**notifications_log:**
| Column | Type | Constraints |
|--------|------|------------|
| id | bigint unsigned | PK, auto_increment |
| type | varchar(50) | NOT NULL (e.g. appointment_confirmed) |
| title | varchar(255) | NOT NULL |
| body | text | NOT NULL |
| target_type | varchar(50) | NOT NULL (all, branch, doctor, patient, date_range) |
| target_ids | json | nullable |
| channels | json | NOT NULL (push, email, in_app) |
| status | varchar(50) | default 'pending' (pending, sent, failed) |
| sent_at | timestamp | nullable |
| timestamps | | created_at, updated_at |

### Constraints
- All tables use InnoDB engine for FK support
- `doctors.is_visible_in_app` defaults to false (per v2-decisions: "default OFF")
- `branches.plato_facility_id` is nullable (mapping happens in P2-T03 CRUD)
- `plato_calendars` uses cascade delete when doctor is removed
- String length for `plato_facility_id` and `plato_calendar_color_id` must accommodate Plato's ID format

---

## Acceptance Criteria

- [ ] `php artisan migrate` creates all 6 new tables without errors
- [ ] `php artisan migrate:rollback` drops all new tables cleanly
- [ ] Foreign key constraints are enforced (deleting a branch cascades to doctors and plato_calendars)
- [ ] All Eloquent models exist with correct `$fillable`, `$casts`, and relationship methods
- [ ] `doctors.is_visible_in_app` defaults to `false`
- [ ] Indexes exist on `doctors.plato_facility_id` and `doctors.is_visible_in_app`
- [ ] `settings.key` has a unique constraint
- [ ] `users.branch_id` foreign key references `branches.id`

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled}

### Files Changed
- {To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] All tables created — PASS / FAIL
- [ ] Migration rollback works — PASS / FAIL
- [ ] Foreign keys enforced — PASS / FAIL
- [ ] Models complete — PASS / FAIL
- [ ] is_visible_in_app defaults to false — PASS / FAIL
- [ ] Indexes confirmed — PASS / FAIL
- [ ] settings.key unique — PASS / FAIL
- [ ] users.branch_id FK — PASS / FAIL

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
