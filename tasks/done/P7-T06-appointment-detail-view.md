# Appointment Detail View — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T06 |
| Slug | appointment-detail-view |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 6 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | NO |
| Depends On | P7-T04 |
| Blocked Reason | N/A |

---

## Description

Create an appointment detail page in the Laravel Admin Panel accessible from the appointment list. The page shows full appointment details fetched from Plato via the proxy (`GET /hemedclinic/appointment` with ID filter) or from the local `appointments` table, whichever has the most complete data. Displays patient info, appointment timing, doctor/branch assignment, status, and notes.

Per `docs/v2-decisions.md` Process 7 Step 6.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 6 (line 99)
- `docs/v2-ux-spec.md` — Appointment card design (lines 200-220)
- `laravel/app/Models/Appointment.php` — existing local appointment model with all fields
- `laravel/app/Http/Controllers/Api/AppointmentController.php` — API store endpoint
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference `show()` pattern
- `laravel/resources/views/admin/branches/show.blade.php` — reference detail view pattern (definition list)

---

## Scope

> Exact deliverables for this task.

### In Scope
- Add `AdminAppointmentController@show($id)` method
- Fetch appointment from local `appointments` table (which contains data from Plato + local metadata)
- Fallback: fetch from Plato via proxy if local record not found
- Display all appointment fields: Patient Name, NRIC, Phone, Doctor, Branch, Date, Time, Status, Notes, Calendar Color ID
- Show Plato appointment ID as reference
- Show created/updated timestamps from local DB
- Status displayed as a colored badge (confirmed=green, pending=amber, cancelled=red, completed=blue)
- "Back to Appointments" link
- Link to patient profile page (if patient exists in Plato)
- Blade view `resources/views/admin/appointments/show.blade.php`

### Out of Scope
- Editing appointment details (Plato is source of truth)
- Cancelling appointments from admin panel
- Rescheduling appointments
- Sending notifications from detail view
- Email/WhatsApp integration from detail page

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — add `show($id)` method
- `laravel/resources/views/admin/appointments/show.blade.php` — new detail view
- (No new routes needed — resource route already generates `show`)

### AdminAppointmentController::show() Implementation
```php
public function show($id)
{
    $appointment = Appointment::with(['branch', 'doctor'])->find($id);

    if (!$appointment) {
        // Fallback: try fetching from Plato
        $response = PlatoProxyService::proxy('GET', 'appointment', ['id' => $id], null);
        $data = $response['data'][0] ?? $response['data'] ?? null;

        if (!$data) {
            abort(404, 'Appointment not found');
        }

        // Convert Plato data to an object-like structure for the view
        $appointment = (object) $data;
    }

    return view('admin.appointments.show', compact('appointment'));
}
```

### API Endpoints
- `GET /api/v2/plato/appointment?id={id}` — fetch single appointment from Plato (fallback)

### Data / Schema
From local `appointments` table (or Plato response):
- `id`, `plato_appointment_id` (UUID), `patient_name`, `patient_nric`, `patient_phone`
- `branch_id`, `branch_name`, `doctor_id`, `doctor_name`
- `appointment_date` (date), `appointment_time` (HH:MM)
- `calendar_color_id`, `status` (confirmed/pending/cancelled/completed), `notes`
- `plato_response` (JSON — raw Plato API response), `notified_at` (datetime, null if not notified)
- `created_at`, `updated_at`

### Blade View Pattern (follow `branches/show.blade.php`)
- Extend `layouts.admin`
- Title: patient name + " — Appointment Detail"
- Back link: left arrow SVG + "Back to Appointments" → `route('admin.appointments.index')`
- Status badge: large colored pill (confirmed=green, pending=amber, cancelled=red, completed=blue)
- Definition list sections:
  1. **Patient Info:** Name, NRIC, Phone
  2. **Appointment Details:** Date, Time, Status, Plato Appointment ID (monospace, copy-friendly)
  3. **Assignment:** Doctor Name, Branch Name, Calendar Color ID
  4. **Notes:** full text or "No notes" placeholder
  5. **Local Record:** Created at, Updated at, Notification sent at (or "Not yet")
- Link to patient profile: "View Patient Profile" → `route('admin.patients.show', ['id' => $appointment->patient_plato_uid])` if available

### Constraints
- Primary data source: local `appointments` table (created during P5-T07 walk-in flow)
- Fallback to Plato proxy for appointments created outside the admin panel
- Read-only display — no edit/delete actions
- All Plato calls through proxy

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Clicking "View" on an appointment in the list navigates to `/admin/appointments/{id}` and shows detail page
- [ ] Detail page shows: patient name, NRIC, phone, doctor name, branch name, appointment date/time
- [ ] Status is shown as a colored badge (green/amber/red/blue matching status)
- [ ] Plato appointment ID is displayed (monospace, readable format)
- [ ] Notes section shows appointment notes or "No notes" if empty
- [ ] "Back to Appointments" link returns to the appointment list
- [ ] Invalid appointment ID shows a 404 page (not a PHP error)
- [ ] Local DB record timestamps (created_at, updated_at) are displayed
- [ ] `php -l` passes syntax check

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done

Implemented the appointment detail view in the Laravel Admin Panel. Added `show()` method to `AdminAppointmentController` that first tries to find the appointment in the local `appointments` table (by primary key, then by `plato_appointment_id`), and falls back to fetching from Plato via the proxy service if no local record exists. Created a Blade view `admin/appointments/show.blade.php` following the `branches/show.blade.php` pattern with grouped sections for Patient Info, Appointment Details, Assignment, Notes, and Local Record timestamps. Updated routes to include the `show` resource action. Replaced the disabled "coming soon" button in the index view with a working link to the detail page.

### Files Changed
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — added `show($id)` method, imported `Appointment` model
- `laravel/resources/views/admin/appointments/show.blade.php` — new detail view with grouped definition lists, colored status badge, patient profile link, back navigation
- `laravel/routes/web.php` — added `'show'` to `Route::resource('appointments')->only([...])`
- `laravel/resources/views/admin/appointments/index.blade.php` — replaced disabled "coming soon" button with clickable link to `admin.appointments.show` route

### Decisions Made During Implementation
- `show()` tries local DB in two ways: first by auto-increment primary key (`find($id)`), then by `plato_appointment_id` (`where('plato_appointment_id', $id)`). This supports both local IDs and Plato UUIDs from the index page links.
- Plato-fetched appointments are cast to `(object)` for consistent property access in the view. A `from_plato` flag is set to conditionally hide local record timestamps (created_at, updated_at, notified_at) which don't apply to Plato-only records.
- The `plato_response` JSON field on the local model is checked for `patient_id` to build the "View Patient Profile" link when available.

### Known Limitations
- Plato-only appointments (not created locally) do not show local record timestamps or notification status.
- No edit/delete/cancel actions are provided on the detail page — this is read-only display per scope.


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] Clicking "View" on an appointment in the list navigates to `/admin/appointments/{id}` and shows detail page — PASS — Index view now has `<a href="{{ route('admin.appointments.show', $appointment['id'] ?? 0) }}">` link; route maps to `AdminAppointmentController@show` at `/admin/appointments/{id}`.
- [x] Detail page shows: patient name, NRIC, phone, doctor name, branch name, appointment date/time — PASS — All fields rendered in Patient Info, Appointment Details, and Assignment sections of show.blade.php.
- [x] Status is shown as a colored badge (green/amber/red/blue matching status) — PASS — Status badge uses correct color mapping: confirmed=green, pending=amber, cancelled=red, completed=blue with dot indicator.
- [x] Plato appointment ID is displayed (monospace, readable format) — PASS — Rendered with `font-mono` CSS class for monospace rendering.
- [x] Notes section shows appointment notes or "No notes" if empty — PASS — `@if ($notes)` renders notes text; `@else` shows "No notes" placeholder in italic gray.
- [x] "Back to Appointments" link returns to the appointment list — PASS — Left arrow SVG link with `route('admin.appointments.index')`.
- [x] Invalid appointment ID shows a 404 page (not a PHP error) — PASS — `abort(404, 'Appointment not found.')` called when neither local DB nor Plato has the record.
- [x] Local DB record timestamps (created_at, updated_at) are displayed — PASS — `Local Record` section shows Created At, Updated At, and Notification Sent timestamps when appointment has a local record (`from_plato === false`).
- [x] `php -l` passes syntax check — PASS — All four modified files: AdminAppointmentController.php, routes/web.php, show.blade.php, index.blade.php — zero syntax errors.

### Failure Details
(None — all criteria passed.)


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Process 7 Step 6 "Appointment detail view" fully implemented. AdminAppointmentController@show retrieves appointment (local DB → plato_appointment_id → Plato proxy fallback), render read-only detail with all required fields.
- v2-ux-spec.md alignment: YES — Follows admin panel patterns from branches/show.blade.php (definition list groups, card wrapper, #0F1B3D/#00C9A7 color tokens, back link with SVG arrow, footer with timestamps). Status badges use the same color scheme as the index page (green/amber/red/blue).

### Rejection Reason
N/A
