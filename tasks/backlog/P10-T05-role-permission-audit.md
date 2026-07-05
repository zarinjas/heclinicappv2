# Role and Permission Audit — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | T05 |
| Slug | role-permission-audit |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 5 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P2-T01 (Auth + roles exist), ALL Admin controllers must exist |
| Blocked Reason | N/A |

---

## Description

Audit and enforce role-based data scoping across all Admin Panel controllers. Currently, the `branch_admin` role exists in the `users` table and `RoleMiddleware` checks the role, but Branch Admin users can view and modify data across all branches — not just their own. This task adds branch-scoping to every query in every Admin controller so that `branch_admin` users see only their assigned branch's patients, appointments, doctors, CMS content, and notifications.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 5
- `docs/CODEBASE.md` — Roles: super_admin, branch_admin, staff; User model `branch_id` foreign key
- `laravel/app/Models/User.php` — role constants, `isSuperAdmin()`, `isBranchAdmin()`, `isStaff()`, `branch()` relationship
- `laravel/app/Http/Middleware/RoleMiddleware.php` — existing middleware (access gate only, no data scoping)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Audit ALL admin controllers for branch-scoping gaps (list below)
- Add `when()` scoping to every DB query: if user is `branch_admin`, filter `WHERE branch_id = auth()->user()->branch_id`
- Controllers to audit and fix:
  1. `Admin/AdminAppointmentController.php` — filter appointments by branch
  2. `Admin/BranchController.php` — Branch Admin: restrict to their own branch (view only, no edit)
  3. `Admin/CalendarSetupController.php` — filter calendar setups by branch
  4. `Admin/CmsArticleController.php` — filter articles by branch (or global access for all)
  5. `Admin/CmsServicePackageController.php` — filter service packages by branch
  6. `Admin/CmsSliderController.php` — filter sliders by branch
  7. `Admin/CmsVideoController.php` — filter videos by branch
  8. `Admin/DashboardController.php` — P10-T04 already handles this
  9. `Admin/DoctorController.php` — filter doctors by branch
  10. `Admin/NotificationController.php` — filter notification logs by branch
  11. `Admin/PatientController.php` — filter patients by branch
- Add `BranchScope` helper trait or base query method for reusable branch filtering
- Verify routes that use `role:super_admin,branch_admin,staff` middleware also apply data scoping
- Remove any `branch_admin` access to sensitive endpoints (user management, settings, system-wide config)

### Out of Scope
- Changing role definitions (super_admin, branch_admin, staff are fixed)
- Permission granularity beyond branch-scoping (e.g., can_create vs can_edit)
- Staff role scoping (staff may have branch_id too — handle if set)
- Frontend Blade template restrictions (if user can't see the data in controller, Blade doesn't matter)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Traits/BranchScoped.php` — NEW: trait with `scopeToUserBranch($query)` helper
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/BranchController.php` — MODIFY: restrict branch_admin to view own branch
- `laravel/app/Http/Controllers/Admin/CalendarSetupController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/CmsArticleController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/CmsServicePackageController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/CmsSliderController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/CmsVideoController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/DoctorController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — MODIFY: add branch scoping
- `laravel/app/Http/Controllers/Admin/PatientController.php` — MODIFY: add branch scoping

### BranchScoped Trait Design
```php
trait BranchScoped {
    protected function scopeByBranchHasColumn(Builder $query): Builder {
        if (auth()->user()?->isBranchAdmin()) {
            return $query->where('branch_id', auth()->user()->branch_id);
        }
        return $query;
    }
}
```

### Constraints
- Do NOT break existing Super Admin access (they must see all data as before)
- Do NOT change API controllers — they serve the mobile app (patient-scoped, not admin-scoped)
- `Staff` role: if `branch_id` is set, apply same scoping as `branch_admin`
- All scoping is additive — it narrows queries, never expands them

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Branch Admin user sees ONLY their own branch's appointments in the appointment list
- [ ] Branch Admin user sees ONLY their own branch's patients
- [ ] Branch Admin user sees ONLY their own branch's doctors
- [ ] Branch Admin user sees ONLY their own branch's CMS content (articles, videos, sliders, service packages)
- [ ] Branch Admin user sees ONLY their own branch's calendar setups
- [ ] Branch Admin user sees ONLY their own branch's notification logs
- [ ] Branch Admin user CANNOT view or edit other branches via URL parameter manipulation
- [ ] Super Admin user continues to see ALL branches' data (no regression)
- [ ] PHP syntax check passes on all modified controllers

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled}

### Files Changed
{To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] Branch Admin appointments scoped — PENDING
- [ ] Branch Admin patients scoped — PENDING
- [ ] Branch Admin doctors scoped — PENDING
- [ ] Branch Admin CMS content scoped — PENDING
- [ ] Branch Admin calendar setups scoped — PENDING
- [ ] Branch Admin notification logs scoped — PENDING
- [ ] URL parameter bypass blocked — PENDING
- [ ] Super Admin no regression — PENDING
- [ ] PHP syntax check — PENDING

### Failure Details
{N/A}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: PENDING

### Alignment Check
- v2-decisions.md alignment: PENDING
- v2-ux-spec.md alignment: PENDING

### Rejection Reason
{N/A}
