# Create Walk-In Appointment — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T05 |
| Slug | create-walkin-appointment |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 5 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P7-T04 |
| Blocked Reason | N/A |

---

## Description

Build a form in the Laravel Admin Panel that allows admin staff to create walk-in appointments for patients. The form sends data to Plato via the proxy (`POST /hemedclinic/appointment`) and optionally saves a local record in the `appointments` table for tracking. The existing `AppointmentService` and `AppointmentController` (API) already contain the creation logic — this task adapts it for the web admin interface.

Per `docs/v2-decisions.md` Process 7 Step 5.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 5 (line 98)
- `docs/api-guidelines.md` — Section 8, `POST /{db}/appointment`
- `laravel/app/Services/AppointmentService.php` — existing `createAppointment()` method
- `laravel/app/Http/Controllers/Api/AppointmentController.php` — existing API store endpoint (reference validation and service call)
- `laravel/app/Models/Appointment.php` — existing local appointment model
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference `store()` pattern with FormRequest
- `laravel/resources/views/admin/branches/create.blade.php` — reference create form pattern

---

## Scope

> Exact deliverables for this task.

### In Scope
- Create `StoreAppointmentRequest` FormRequest with validation rules
- Add `AdminAppointmentController@create()` — shows the appointment creation form
- Add `AdminAppointmentController@store()` — processes form, calls `AppointmentService::createAppointment()`, creates local DB record
- Form fields: Patient Name, NRIC, Phone, Branch (dropdown), Doctor (dropdown — filtered by selected branch), Appointment Date (date picker, future dates only), Appointment Time (time picker), Notes (textarea)
- Optional: Slot availability check via `POST /appointment/slots` before submission (if feasible)
- Client-side validation for required fields
- Server-side validation via FormRequest
- Success: redirect to appointment list with flash message
- Failure: redirect back with validation errors and old input
- Blade views: `resources/views/admin/appointments/create.blade.php`
- Web route: add `create` and `store` actions to existing resource route

### Out of Scope
- Editing appointments (Plato is source of truth — admin panel is create-only)
- Cancelling appointments from admin panel
- Slot availability calendar UI (defer to future if needed)
- Patient search/autocomplete (enter patient details manually)
- WhatsApp notification sending (P5-T07/P5-T08 already handle patient notification flow)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Http/Requests/StoreAppointmentRequest.php` — new FormRequest
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — add `create()`, `store()` methods
- `laravel/resources/views/admin/appointments/create.blade.php` — new form view
- `laravel/routes/web.php` — ensure resource route covers create/store

### FormRequest Validation Rules
```php
public function rules(): array
{
    return [
        'patient_name' => ['required', 'string', 'max:255'],
        'patient_nric' => ['required', 'string', 'max:20'],
        'patient_phone' => ['required', 'string', 'max:20'],
        'branch_id' => ['required', 'exists:branches,id'],
        'branch_name' => ['required', 'string'],
        'doctor_id' => ['required', 'exists:doctors,id'],
        'doctor_name' => ['required', 'string'],
        'appointment_date' => ['required', 'date', 'after:today'],
        'appointment_time' => ['required', 'date_format:H:i'],
        'calendar_color_id' => ['nullable', 'string'],
        'notes' => ['nullable', 'string', 'max:1000'],
    ];
}
```

### AdminAppointmentController::store() Implementation
```php
public function store(StoreAppointmentRequest $request)
{
    $appointment = AppointmentService::createAppointment($request->validated());

    if ($appointment) {
        return redirect()
            ->route('admin.appointments.index')
            ->with('success', 'Walk-in appointment created successfully.');
    }

    return redirect()
        ->back()
        ->withInput()
        ->with('error', 'Failed to create appointment. Plato API error.');
}
```

### API Endpoints
- `POST /api/v2/plato/appointment` — via proxy (called by `AppointmentService`)
- `POST /api/v2/plato/appointment/slots` — optional slot check (if needed for time validation)

### Blade View Pattern (follow `branches/create.blade.php`)
- Extend `layouts.admin`
- Title: "New Walk-In Appointment"
- Form: POST to `route('admin.appointments.store')`, `@csrf`
- Card wrapper: `bg-white rounded-xl border border-gray-100 shadow-sm`
- Fields grouped:
  1. Patient Info: name*, nric*, phone*
  2. Appointment Details: branch dropdown* (triggers doctor filter), doctor dropdown*, date input*, time input*
  3. Notes: textarea (optional)
- Doctor dropdown filters based on selected branch (JS or HTMX reload)
- Submit button: teal `bg-[#00C9A7]`, "Create Appointment"
- Cancel link: back to `admin.appointments.index`

### Constraints
- All Plato calls through proxy
- Use existing `AppointmentService::createAppointment()` — do not duplicate logic
- Appointment date must be in the future
- Local DB record created via `AppointmentService` (already implemented)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] `GET /admin/appointments/create` renders the walk-in appointment form
- [ ] Form includes fields: patient name, NRIC, phone, branch dropdown, doctor dropdown, date, time, notes
- [ ] Doctor dropdown filters to show only doctors from the selected branch
- [ ] Submitting the form with valid data creates an appointment via Plato proxy
- [ ] A local DB record is created in the `appointments` table
- [ ] After successful creation, redirected to appointment list with success flash message
- [ ] Submitting with invalid data shows validation errors and preserves old input
- [ ] Past dates are rejected with validation error
- [ ] Required fields (name, NRIC, phone, branch, doctor, date, time) are validated
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
- [ ] {Criterion 10} — PASS / FAIL — {note if fail}

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
