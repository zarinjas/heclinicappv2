# P2-T01 — Laravel Project Setup with Auth and Roles

## Task ID
P2-T01

## Title
Laravel Project Setup with Auth and Roles

## Header

| Field | Value |
|-------|-------|
| Task ID | P2-T01 |
| Slug | laravel-auth-role-setup |
| Process | 2 — Laravel Admin Panel Scaffold |
| Process Step | Step 1 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Set up Laravel authentication and role system for the Admin Panel. Install Laravel Breeze or Jetstream with Sanctum API tokens, configure three roles (Super Admin, Branch Admin, Staff), create role middleware and seeders, and set up the basic admin dashboard layout. Per v2-decisions.md Process 2 Step 1.

---

## Context

- `docs/v2-decisions.md` — Process 2, Step 1: "Laravel project setup on VPS — auth, roles (Super Admin, Branch Admin, Staff)"
- `laravel/` — existing Laravel project with PlatoProxyController (api routes already scaffolded)
- `laravel/routes/api.php` — existing API routes with sanctum middleware
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — existing proxy controller
- `docs/api-guidelines.md` — Plato API authentication (Bearer token) reference

---

## Scope

### In Scope
- Install Laravel Breeze (Blade stack for admin panel) or standalone Sanctum for API auth
- Create User model with `role` field (enum: super_admin, branch_admin, staff)
- Create RoleMiddleware for route-level role checking
- Create `roles` migration adding role column to users table
- Create UserSeeder with default Super Admin account
- Set up admin layout (Blade template with sidebar navigation)
- Create Admin Dashboard controller and view (placeholder for future modules)
- Add initial README for Laravel setup instructions

### Out of Scope
- Branch management CRUD (P2-T03)
- Doctor management CRUD (P2-T04)
- Plato API proxy layer (P2-T05 — existing partial; P2-T05 will extend)
- Calendar setup UI (P2-T06)
- Patient and appointment management (Process 7)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Models/User.php` — add role field and role-checking methods
- `laravel/database/migrations/xxxx_add_role_to_users_table.php` — migration for role column
- `laravel/app/Http/Middleware/RoleMiddleware.php` — middleware to check user role
- `laravel/app/Http/Controllers/Admin/DashboardController.php` — admin dashboard
- `laravel/database/seeders/UserSeeder.php` — default admin user
- `laravel/resources/views/layouts/admin.blade.php` — admin layout with sidebar
- `laravel/resources/views/admin/dashboard.blade.php` — dashboard view
- `laravel/routes/web.php` — add admin web routes
- `laravel/app/Http/Kernel.php` — register RoleMiddleware
- `laravel/config/auth.php` — ensure sanctum guards are configured

### API Endpoints
- N/A (API routes already set up in `routes/api.php`; P2-T01 focuses on web/auth)

### Data / Schema
- `users` table additions:
  - `role`: enum('super_admin', 'branch_admin', 'staff') — default 'staff'
  - `branch_id`: foreign key to branches table (nullable, will be used in P2-T03)
- Default Super Admin: email from `.env` (`ADMIN_EMAIL`, `ADMIN_PASSWORD`)

### Constraints
- All admin routes must be protected by auth and role middleware
- Sanctum token-based auth for API (already configured)
- Session-based auth for web admin panel (Blade views)
- Super Admin has unrestricted access; Branch Admin scoped to their branch (will enforce in later tasks)

---

## Acceptance Criteria

- [ ] Laravel Breeze (or auth scaffolding) installed and functional — login/logout works
- [ ] `users` table has a `role` column with enum values: super_admin, branch_admin, staff
- [ ] RoleMiddleware correctly restricts routes based on user role
- [ ] UserSeeder creates a default Super Admin account from `.env` configuration
- [ ] Admin dashboard loads after login with sidebar navigation (placeholder links for future modules)
- [ ] Existing API routes (`/api/v2/plato/{path}`) continue to work after auth setup
- [ ] `php artisan migrate:fresh --seed` runs without errors

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
- [ ] Auth scaffolding functional — PASS / FAIL
- [ ] Role column exists — PASS / FAIL
- [ ] RoleMiddleware works — PASS / FAIL
- [ ] UserSeeder creates admin — PASS / FAIL
- [ ] Admin dashboard loads — PASS / FAIL
- [ ] API routes unaffected — PASS / FAIL
- [ ] migrate:fresh --seed works — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: N/A (admin panel) —

### Rejection Reason
{If REJECTED}
