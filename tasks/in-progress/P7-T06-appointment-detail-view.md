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
| Status | IN-PROGRESS |
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


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {Criterion 1} — PASS / FAIL — {note if fail}
- [ ] {Criterion 2} — PASS / FAIL — {note if fail}
- [ ] {Criterion 3} — PASS / FAIL — {note if fail}
- [ ] {Criterion 4} — PASS / FAIL — {note if fail}
- [ ] {Criterion 5} — PASS / FAIL — {note if fail}
- [ ] {Criterion 6} — PASS / FAIL — {note if fail}
- [ ] {Criterion 7} — PASS / FAIL — {note if fail}
- [ ] {Criterion 8} — PASS / FAIL — {note if fail}
- [ ] {Criterion 9} — PASS / FAIL — {note if fail}

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason
N/A
