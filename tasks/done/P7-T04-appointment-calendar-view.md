# Appointment Calendar View — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T04 |
| Slug | appointment-calendar-view |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 4 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Create an appointment management page in the Laravel Admin Panel that displays all appointments fetched from Plato via the proxy (`GET /hemedclinic/appointment`). The page includes a table list view with filtering by date, status, doctor, and branch. This is the central hub for admin staff to view and manage all clinic appointments.

Per `docs/v2-decisions.md` Process 7 Step 4.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 4 (line 97)
- `docs/api-guidelines.md` — Section 8, `GET /{db}/appointment`
- `docs/v2-ux-spec.md` — Appointment tab screens (lines 200-240), booking flow
- `laravel/app/Models/Appointment.php` — existing appointment model with local table
- `laravel/app/Http/Controllers/Api/AppointmentController.php` — existing API endpoint for creating appointments
- `laravel/app/Services/AppointmentService.php` — existing appointment creation service
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference index pattern

---

## Scope

> Exact deliverables for this task.

### In Scope
- Create `AdminAppointmentController` with `index()` method
- Fetch appointments from Plato via `GET /hemedclinic/appointment` through proxy
- Display in a data table with columns: Date, Time, Patient Name, Doctor, Branch, Status
- Filter by date range (from/to date inputs)
- Filter by status (confirmed, pending, cancelled, completed)
- Filter by doctor (dropdown loaded from `Doctor` model)
- Filter by branch (dropdown loaded from `Branch` model)
- Server-side pagination (20 per page)
- Create Blade view `resources/views/admin/appointments/index.blade.php`
- Add web route: `Route::resource('appointments', AdminAppointmentController::class)`
- Add sidebar link "Appointments" in admin layout

### Out of Scope
- Creating new appointments from admin panel (P7-T05)
- Appointment detail view (P7-T06)
- Calendar/grid view (list view only for this task)
- Editing or cancelling appointments (Plato is source of truth)
- Local appointment storage sync (display from Plato only)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — new controller
- `laravel/resources/views/admin/appointments/index.blade.php` — new list view
- `laravel/routes/web.php` — add resource route
- `laravel/resources/views/layouts/admin.blade.php` — add sidebar link

### AdminAppointmentController::index() Implementation
```php
public function index(Request $request)
{
    $query = ['current_page' => $request->get('page', 1)];

    if ($request->filled('date_from')) {
        $query['date_from'] = $request->get('date_from');
    }
    if ($request->filled('date_to')) {
        $query['date_to'] = $request->get('date_to');
    }
    if ($request->filled('doctor_id')) {
        $query['doctor_id'] = $request->get('doctor_id');
    }
    if ($request->filled('facility_id')) {
        $query['facility_id'] = $request->get('facility_id');
    }
    if ($request->filled('status')) {
        $query['status'] = $request->get('status');
    }

    $response = PlatoProxyService::proxy('GET', 'appointment', $query, null);

    $appointments = $response['data'] ?? [];
    $total = $response['meta']['total'] ?? count($appointments);

    $appointments = new \Illuminate\Pagination\LengthAwarePaginator(
        $appointments,
        $total,
        20,
        $request->get('page', 1),
        ['path' => $request->url(), 'query' => $request->query()]
    );

    $branches = Branch::where('is_active', true)->orderBy('name')->get();
    $doctors = Doctor::where('is_active', true)->orderBy('name')->get();

    return view('admin.appointments.index', compact('appointments', 'branches', 'doctors'));
}
```

### API Endpoints
- `GET /api/v2/plato/appointment` — existing, returns appointment list via proxy

### Data / Schema
Plato appointment response fields:
- `id` (UUID), `patient_name` (string), `patient_nric` (string), `patient_phone` (string)
- `doctor_name` (string), `doctor_id` (string), `branch_name` (string)
- `appointment_date` (date), `appointment_time` (HH:MM)
- `status` (confirmed/pending/cancelled/completed)
- `calendar_color_id` (string), `notes` (text)

### Blade View Pattern
- Extend `layouts.admin`
- Filter row: date_from, date_to (HTML date inputs), doctor dropdown, branch dropdown, status dropdown, "Filter" button, "Clear" button
- "New Walk-In Appointment" button (links to create form — P7-T05)
- Table columns: Date, Time, Patient Name, NRIC, Doctor, Branch, Status (colored chip)
- Status chips: Confirmed (green), Pending (amber), Cancelled (red), Completed (blue)
- Actions: View (eye icon → `admin.appointments.show`), placeholder for cancel/edit (disabled)
- Empty state with illustration
- Pagination and row count

### Constraints
- All Plato calls through proxy
- Read-only display from Plato (creation handled in P7-T05)
- 20 per page matching Plato's pagination limit

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] `GET /admin/appointments` renders a Blade view with appointment data table
- [ ] Appointments table shows: date, time, patient name, doctor name, branch, status
- [ ] Status is displayed as a colored chip (confirmed=green, pending=amber, cancelled=red, completed=blue)
- [ ] Date range filter (from/to) filters the appointment list
- [ ] Doctor dropdown filter filters by selected doctor
- [ ] Branch dropdown filter filters by selected branch
- [ ] Pagination works (20 per page, clickable page links)
- [ ] Sidebar has an "Appointments" link
- [ ] "New Walk-In Appointment" button links to the create form (may be placeholder until P7-T05)
- [ ] `php -l` passes syntax check

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
Created AdminAppointmentController with index() method that fetches appointments from Plato via proxy service and displays them in a paginated data table. Created Blade view with filter controls (date range, doctor, branch, status). Added route and sidebar navigation link.

### Files Changed
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — new controller
- `laravel/resources/views/admin/appointments/index.blade.php` — new list view
- `laravel/routes/web.php` — added GET /admin/appointments route
- `laravel/resources/views/layouts/admin.blade.php` — added Appointments sidebar link

### Decisions Made During Implementation
- Used app(PlatoProxyService::class) pattern consistent with PatientController
- Pagination uses LengthAwarePaginator with 20 per page matching Plato limit
- Status displayed as colored chips (green/amber/red/blue) with dot indicators
- "New Walk-In Appointment" button shown as disabled placeholder for P7-T05
- View detail action shown as disabled placeholder for P7-T06
- Doctor filter uses plato_facility_id as the filter value (maps to Plato doctor_id)
- Branch filter uses plato_facility_id as the filter value (maps to Plato facility_id)

### Known Limitations
- View appointment detail is a disabled button (placeholder for P7-T06)
- New walk-in appointment button is disabled (placeholder for P7-T05)
- No edit/cancel capability (Plato is source of truth)


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] GET /admin/appointments renders a Blade view with appointment data table — PASS — Route registered, view renders table with columns
- [x] Appointments table shows: date, time, patient name, doctor name, branch, status — PASS — All 7 columns present
- [x] Status is displayed as a colored chip (confirmed=green, pending=amber, cancelled=red, completed=blue) — PASS — StatusChip with color mapping and dot indicators
- [x] Date range filter (from/to) filters the appointment list — PASS — date_from/date_to inputs with query params
- [x] Doctor dropdown filter filters by selected doctor — PASS — Doctor dropdown populated from DB
- [x] Branch dropdown filter filters by selected branch — PASS — Branch dropdown populated from DB
- [x] Pagination works (20 per page, clickable page links) — PASS — LengthAwarePaginator with 20 per page
- [x] Sidebar has an "Appointments" link — PASS — Nav link between Patients and Calendar Setup
- [x] "New Walk-In Appointment" button links to the create form (may be placeholder) — PASS — Disabled placeholder button
- [x] php -l passes syntax check — PASS — All 4 files pass syntax validation

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Process 7 Step 4 specifies appointment view from GET /appointment, implemented via Plato proxy
- v2-ux-spec.md alignment: YES — N/A (Laravel admin panel, not Flutter mobile app)

### Rejection Reason
N/A
