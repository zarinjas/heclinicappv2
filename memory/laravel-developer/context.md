# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
P2-T03 — Branch Management CRUD (IN-REVIEW)

## Last Completed Task
P2-T02 — MySQL Schema (DONE)

## Implementation Summary — P2-T03
- BranchController: full CRUD resource controller (index, create, store, show, edit, update, destroy)
- StoreBranchRequest: validation (name required, WhatsApp +60 prefix, Plato facility ID unique)
- UpdateBranchRequest: same rules with ignore current branch on unique check
- Blade views: index (searchable table, sortable name, active/inactive badges, pagination), create/edit forms, show detail
- Updated admin.blade.php: Branches sidebar placeholder replaced with active route link
- Routes: Route::resource('branches', BranchController::class) under auth+role middleware
- BranchSeeder: 3 sample Malaysian branches (Shah Alam, Bangi active; Putrajaya inactive)
- DatabaseSeeder: added BranchSeeder call
- Flash success messages via session on create/update/delete
- Delete confirmation via JS confirm() dialog

## Implementation Summary — P2-T02
- migrations: branches, doctors, plato_calendars, settings, notifications_log tables created
- Added foreign key on users.branch_id → branches.id (nullOnDelete)
- Models: Branch, Doctor, PlatoCalendar, Setting, NotificationLog with fillable, casts, relationships
- User model: added branch() BelongsTo relationship
- FK cascades: doctors.branch_id → cascadeOnDelete, plato_calendars.doctor_id → cascadeOnDelete
- Nullable FKs use nullOnDelete: doctors.user_id, users.branch_id

## Implementation Summary — P2-T01
- Migration: added `role` (enum: super_admin, branch_admin, staff) and `branch_id` to users table
- RoleMiddleware: checks user role(s), registered as `role` alias in bootstrap/app.php
- Admin AuthController: session-based login/logout with Blade views
- Admin DashboardController: dashboard view with stats cards and welcome message
- Blade views: admin.auth.login, layouts.admin (dark sidebar with placeholder nav), admin.dashboard
- UserSeeder: creates Super Admin from .env ADMIN_EMAIL/ADMIN_PASSWORD, sample Staff user
- User model: role constants (ROLE_SUPER_ADMIN, ROLE_BRANCH_ADMIN, ROLE_STAFF), helper methods, branch relationship
- Routes: /admin/login, /admin/dashboard (protected by auth + role middleware)
- Manual Blade auth (no Breeze/Jetstream) for minimal dependencies

## Known Constraints
- Plato API token lives in .env only — never exposed in any API response, log, or mobile code
- All Plato list endpoints must implement pagination: current_page loop until empty response
- HTTP 429 handling: exponential backoff 1s → 2s → 4s → 8s, then fail gracefully with clear message
- Monitor x-ratelimit-remaining header — pause calls when near limit
- MySQL schemas in v2-decisions.md are authoritative — do not alter column names
- Admin Panel timeout: 10s per Plato request, retry once, then fail with message

## Pending Items
- Sidebar links for Doctors, Calendar Setup are placeholders — implemented in P2-T04, P2-T06
- Admin password reset flow not implemented (out of scope)
