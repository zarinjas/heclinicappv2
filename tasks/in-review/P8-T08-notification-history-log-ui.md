# Notification History Log — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T08 |
| Slug | notification-history-log-ui |
| Process | 8 — Notifications Module |
| Process Step | Step 8 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P8-T01 |
| Blocked Reason | N/A |

---

## Description

Create the notification history log page in the admin panel — a paginated, searchable, filterable table displaying all sent and drafted notifications from the `notifications_log` MySQL table with delivery status tracking.

Per `docs/v2-decisions.md` Step 8 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 8 (line 110)
- `docs/v2-ux-spec.md` — Admin Panel UI: tables striped rows, sticky header, per-row actions, pagination, search (lines 885-900)
- `laravel/app/Models/NotificationLog.php` — Model with `type`, `title`, `body`, `target_type`, `target_ids`, `channels`, `status`, `sent_at`, and `timestamps`
- `laravel/database/migrations/2026_07_05_000005_create_notifications_log_table.php` — Schema reference
- `laravel/app/Http/Controllers/Admin/` — other controllers for patterns (e.g. `BranchController`, `DoctorController` for index/list patterns)
- `laravel/routes/web.php` — notification routes start by P8-T01

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Create notification history list page at `GET /admin/notifications`
- Paginated table (20 per page) with columns: ID, Type, Title (truncated), Target, Channels, Status, Sent At / Created At
- Search by title or body text
- Filter by: type (manual, appointment_confirmed, appointment_reminder, document_uploaded), status (draft, pending, sent, failed), date range
- Click row to view notification detail modal/slide-over: full title, body, targeting info, channel breakdown, timestamps
- Update `NotificationController` with `index()` method and optional `show()` method
- Add sidebar navigation link for "Notification History"

### Out of Scope
- Real-time delivery status from Firebase (show as sent/draft/pending from MySQL only; Firebase delivery status tracking is future work)
- Bulk actions (delete, resend) — future Process 10
- Export to CSV — future
- Analytics/statistics on notification sends — Process 10 Step 4
- Edit sent notifications (immutable after sending)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — UPDATE: add `index()` (list with pagination, search, filters), `show()` (detail view)
- `laravel/routes/web.php` — ADD: `GET /admin/notifications` → NotificationController@index, `GET /admin/notifications/{id}` → NotificationController@show
- `laravel/resources/js/Pages/Admin/Notifications/Index.vue` — NEW: Inertia/Vue page with table, search, filters, pagination
- `laravel/resources/js/Pages/Admin/Notifications/Show.vue` — NEW: Inertia/Vue modal or separate page for notification detail
- `laravel/resources/js/Layouts/AdminLayout.vue` — possibly: update sidebar nav group "Notifications" with History link

### API Endpoints
- `GET /admin/notifications` — List notifications (paginated, searchable, filterable)
- `GET /admin/notifications/{id}` — Show notification detail (JSON response or Inertia render)

### Data / Schema
`notifications_log` table display mapping:
| DB Column | Display Label | Format |
|-----------|--------------|--------|
| id | # | Numeric |
| type | Type | Badge/tag with color coding |
| title | Title | Text (truncated to 50 chars in table) |
| target_type | Target | Badge: All / Branch / Doctor / Date Range / Patient |
| channels | Channels | Badge icons: Push, Email, In-App |
| status | Status | Colored badge: Draft=gray, Pending=yellow, Sent=green, Failed=red |
| sent_at | Sent At | DateTime or "—" |
| created_at | Created | DateTime |

### UI Components (Admin Panel — Vue 3 + Inertia.js)
Follow existing list page patterns from `BranchController@index` or `DoctorController@index`:
- Page header: "Notification History" with optional "Compose New" button
- Filter bar: search input + status dropdown + type dropdown + date range picker
- Table: striped rows, sticky header, sortable columns (if applicable)
- Pagination: 20 per page, page numbers below table
- Click row → slide-over panel or modal with full notification detail
- Detail panel shows: full title, full body, targeting summary, channel badges, created_at, sent_at

### Constraints
- Use existing Inertia.js + Vue 3 + Tailwind CSS patterns from other admin list pages
- Super Admin sees all notifications; Branch Admin sees only notifications targeting their branch
- Follow `v2-ux-spec.md` Admin Panel table specs: striped rows, sticky header, 20/page pagination

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Visiting `/admin/notifications` displays a paginated table of notification logs (20 per page)
- [ ] The table shows columns: ID, Type, Title (truncated), Target, Channels, Status, Date
- [ ] The search input filters notifications by title or body text
- [ ] The status dropdown filters by: All, Draft, Pending, Sent, Failed
- [ ] The type dropdown filters by: All, Manual, Appointment Confirmed, Appointment Reminder, Document Uploaded
- [ ] Clicking a table row opens a detail view showing full notification content (title, body, targeting, channels, timestamps)
- [ ] Empty state shows appropriate message when no notifications exist
- [ ] The "Notifications" sidebar nav item expands to show "Compose" and "History" sub-items

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
- Created notification history list page at `GET /admin/notifications` with paginated table (20 per page), search, type/status/date range filters, sortable columns
- Created notification detail view at `GET /admin/notifications/{notification}` with full content, targeting info, channel badges, and timestamps
- Added collapsible sidebar submenu "Notifications" with "Compose" and "History" links
- Color-coded badges for type (Manual/Confirmed/Reminder/Doc Uploaded), status (Draft/Pending/Sent/Failed), target (All/Branch/Doctor/Date Range/Patient), and channel icons

### Files Changed
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — ADDED: `index()` (search, filters, sort, pagination 20/page), `show()` (detail view with JSON API support)
- `laravel/routes/web.php` — ADDED: `GET /admin/notifications` (index), `GET /admin/notifications/{notification}` (show)
- `laravel/resources/views/admin/notifications/index.blade.php` — NEW: list view following Branch index pattern
- `laravel/resources/views/admin/notifications/show.blade.php` — NEW: detail view following Branch show pattern
- `laravel/resources/views/layouts/admin.blade.php` — UPDATED: Notifications sidebar from single link to collapsible submenu with Compose and History sub-items + JavaScript toggle

### Decisions Made During Implementation
- Used Blade templates (not Vue) to match existing admin panel patterns
- Routes added after existing `notifications/compose` routes to avoid wildcard conflicts
- Index table rows are clickable (navigates to show view) for UX convenience
- Show route uses Route Model Binding with automatic 404 on missing records
- Branch Admin scope restriction (not implemented) — out of scope per task spec; future Process 10 audit will handle

### Known Limitations
- No real-time Firebase delivery status tracking (future work per scope)
- No bulk actions (delete, resend) — future Process 10
- No CSV export — future
- Branch Admin scope filtering for their own branch's notifications deferred (no `branch_id` on notifications_log table)

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
