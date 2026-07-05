# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
P2-T01 — Laravel Project Setup with Auth and Roles (IN-REVIEW — Round 2 after QA fix)

## Last Completed Task
None (first Process 2 task implemented).

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
- Branch model referenced in User::branch() — resolves when P2-T02 creates Branch model
- Sidebar links for Branches, Doctors, Calendar Setup are placeholders — implemented in P2-T03, P2-T04, P2-T06
- Admin password reset flow not implemented (out of scope)
