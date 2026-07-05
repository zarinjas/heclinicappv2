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
| Status | IN-REVIEW |
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
Installed and configured Laravel authentication and role system for the Admin Panel:
- Created migration to add `role` (enum: super_admin, branch_admin, staff) and `branch_id` (nullable) to users table. branch_id has no FK constraint — FK to be added in P2-T02 when branches table exists.
- Created RoleMiddleware with support for multiple roles per route; registered as `role` alias in bootstrap/app.php
- Created Admin AuthController with login/logout using session-based authentication
- Created Admin DashboardController with dashboard view showing user role and placeholder stats
- Created Blade views: auth/login.blade.php (login form with He Clinic branding), layouts/admin.blade.php (sidebar layout with dark navigation), admin/dashboard.blade.php (stats cards + welcome message)
- Created UserSeeder with Super Admin (from .env ADMIN_EMAIL/ADMIN_PASSWORD) and sample Staff user
- Updated User model with role constants (ROLE_SUPER_ADMIN, ROLE_BRANCH_ADMIN, ROLE_STAFF), helper methods (isSuperAdmin(), isBranchAdmin(), isStaff(), hasRole()). branch() relationship deferred to P2-T02.
- Updated DatabaseSeeder to call UserSeeder
- Added admin web routes: /admin/login (GET/POST), /admin/logout (POST), /admin/dashboard (GET, protected by auth + role middleware)
- Added ADMIN_EMAIL and ADMIN_PASSWORD to .env.example
- Sidebar includes placeholder links for Branches, Doctors, and Calendar Setup (marked "Soon")

**QA Fix (Round 2):** Removed `dropForeign(['branch_id'])` from migration down() — no FK was created (foreignId without constrained()). Removed `branch()` relationship from User model — deferred to P2-T02 when Branch model exists.

### Files Changed
- `laravel/database/migrations/2026_07_05_000000_add_role_and_branch_to_users_table.php` — new migration
- `laravel/app/Http/Middleware/RoleMiddleware.php` — new middleware
- `laravel/app/Http/Controllers/Admin/AuthController.php` — new auth controller
- `laravel/app/Http/Controllers/Admin/DashboardController.php` — new dashboard controller
- `laravel/resources/views/admin/auth/login.blade.php` — new login view
- `laravel/resources/views/layouts/admin.blade.php` — new admin layout
- `laravel/resources/views/admin/dashboard.blade.php` — new dashboard view
- `laravel/database/seeders/UserSeeder.php` — new seeder
- `laravel/app/Models/User.php` — added role constants, helper methods (branch() deferred to P2-T02)
- `laravel/database/seeders/DatabaseSeeder.php` — updated to call UserSeeder
- `laravel/routes/web.php` — added admin routes
- `laravel/bootstrap/app.php` — registered role middleware alias
- `laravel/.env.example` — added ADMIN_EMAIL, ADMIN_PASSWORD

### Decisions Made During Implementation
- Did NOT install Laravel Breeze/Jetstream to avoid pulling in Tailwind/Inertia/complexity. Built minimal auth with manual Blade views for maximum control and lighter dependency footprint.
- Used session-based auth for web panel (consistent with Laravel defaults) while Sanctum handles API auth — no conflict.
- RoleMiddleware accepts variable roles: `role:super_admin` or `role:super_admin,branch_admin` — allows flexible route protection.
- Sidebar placeholder links use "Soon" badge pattern — will be replaced with active links when P2-T03 (Branches), P2-T04 (Doctors), and P2-T06 (Calendar Setup) are implemented.
- Admin password default in seeder uses `env('ADMIN_PASSWORD', 'password')` — must be changed in production .env.

### Known Limitations
- No password reset flow for admin panel (not in scope for this task)
- No user management CRUD UI (staff user creation is via seeder only)
- Branch FK on users table is nullable until branches table exists (P2-T02)
- Branch model referenced in User::branch() relationship — will resolve when P2-T02 creates the Branch model
- Login page uses Tailwind CSS classes from Vite — requires `npm run build` to compile assets

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] Auth scaffolding functional — PASS: AuthController with login/logout, Blade login view with CSRF, session-based auth via routes, redirect-to-dashboard on success, logout invalidates session
- [x] Role column exists — PASS: Migration adds enum('role', ['super_admin', 'branch_admin', 'staff']) to users table with default 'staff'
- [x] RoleMiddleware works — PASS: Multi-role check with in_array(), registered as 'role' alias in bootstrap/app.php, used in route groups with auth + role middleware chain
- [x] UserSeeder creates admin — PASS: Reads ADMIN_EMAIL and ADMIN_PASSWORD from env(), creates Super Admin (email_verified_at set), creates sample Staff user; uses firstOrCreate pattern to avoid duplicates
- [x] Admin dashboard loads — PASS: Dashboard view extends admin layout, shows stats cards (Branches, Doctors, Users as placeholders), welcome message with user role badge, sidebar with dark theme and "Soon" placeholder nav links for future modules
- [x] API routes unaffected — PASS: routes/api.php untouched, sanctum middleware intact, Plato proxy route unchanged
- [x] migrate:fresh --seed runs without errors — PASS: Migration up() creates role enum and nullable branch_id without FK constraint; down() only drops columns (no dropForeign crash — FIXED Round 2). User model has no Branch dependency (branch() deferred to P2-T02). DatabaseSeeder calls UserSeeder. No blocking dependencies.

### Failure Details
N/A — All 7 criteria PASSED. Round 1 bugs (dropForeign crash + Branch class reference) resolved in Round 2.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: N/A (admin panel) —

### Rejection Reason
{If REJECTED}
