# Analytics Dashboard — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | T04 |
| Slug | analytics-dashboard |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 4 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | P2-T02 (MySQL schema exists), P7-T01 (patient list), P8-T08 (notification log UI) |
| Blocked Reason | N/A |

---

## Description

Upgrade the existing minimalist Admin Panel Dashboard (`DashboardController`) with live analytics: appointment trends over time, total patient count, total appointment count for the month, and notification delivery stats. Data sources from the local MySQL database (appointments, patients tables) and notification logs. Display using simple Blade-based cards and a Chart.js line chart for appointment trends. This replaces the placeholder dashboard that currently only passes `auth()->user()`.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 4
- `docs/v2-ux-spec.md` — Admin Panel dashboard patterns
- `docs/CODEBASE.md` — Laravel models: Appointment, Patient, NotificationLog
- Current file: `laravel/app/Http/Controllers/Admin/DashboardController.php` (REPLACE)
- Current view: `laravel/resources/views/admin/dashboard.blade.php` (REPLACE)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Replace `DashboardController@index` to query analytics:
  - Total patients count (from patients table or Plato proxy)
  - Total appointments this month
  - Appointments by day (last 30 days, for chart)
  - Total notifications sent (from `notification_logs` table)
  - Notification delivery success rate (%)
- Update `dashboard.blade.php` with stat cards and a Chart.js line chart
- Include Chart.js via CDN in the Blade view
- Role-aware data scoping: Branch Admin sees only their branch's data
- Stats refresh via page reload (no AJAX auto-refresh needed in v1)

### Out of Scope
- Date range picker — fixed "last 30 days" for chart, "this month" for counters
- Export to CSV/PDF
- Real-time WebSocket dashboard updates
- Revenue/financial analytics — Plato handles this

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/DashboardController.php` — REPLACE: add analytics queries
- `laravel/resources/views/admin/dashboard.blade.php` — REPLACE: stat cards + chart

### Data / Schema
Available local MySQL tables:
- `appointments`: `id`, `patient_id`, `branch_id`, `doctor_id`, `appointment_date`, `status`, `created_at`
- `notification_logs`: `id`, `notification_id`, `channel`, `status`, `sent_at`
- Patients: sourced from Plato via proxy (not stored locally; use `PatientService` or proxy)

### UI Components
- **Stat cards (4):** Total Patients, Appointments This Month, Notifications Sent, Delivery Rate
- **Chart:** Chart.js line chart — appointments per day (last 30 days), X-axis = dates, Y-axis = count
- Admin Panel color palette from ui-design-system.md (primary `#0F1B3D`, accent `#00C9A7`)

### Constraints
- Branch Admin must only see their own branch's stats (P10-T05 may add scoping, but implement basic check here too)
- Chart.js loaded via CDN: `<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>`
- Dashboard route: `GET /admin/dashboard` (already exists)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Dashboard loads at `/admin/dashboard` with 4 stat cards (Patients, Appointments, Notifications, Delivery Rate)
- [ ] Stat cards display real numeric values (not hardcoded)
- [ ] Line chart renders with appointment data for last 30 days
- [ ] Chart X-axis shows dates, Y-axis shows appointment count
- [ ] Branch Admin sees only their assigned branch's data (stat cards + chart)
- [ ] Super Admin sees all branch data aggregated
- [ ] Page loads without JavaScript errors (Chart.js CDN resolves)
- [ ] PHP syntax check passes: `php -l app/Http/Controllers/Admin/DashboardController.php`

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
- [ ] 4 stat cards loaded — PENDING
- [ ] Real numeric values — PENDING
- [ ] Chart renders 30 days — PENDING
- [ ] Chart axis labels — PENDING
- [ ] Branch Admin scoping — PENDING
- [ ] Super Admin aggregation — PENDING
- [ ] No JS errors — PENDING
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
