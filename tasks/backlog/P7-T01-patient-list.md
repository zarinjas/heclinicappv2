# Patient List — Server-Side Pagination, Search

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T01 |
| Slug | patient-list |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 1 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build a patient listing page in the Laravel Admin Panel. Patients are fetched from Plato via the proxy (`GET /hemedclinic/patient`) with server-side pagination (20 per page), and searchable by name, NRIC, and phone number. This is the entry point for all patient management in the admin panel.

Per `docs/v2-decisions.md` Process 7 Step 1.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 1 (line 94)
- `docs/api-guidelines.md` — Section 8, Plato endpoint `GET /{db}/patient` and pagination rules (lines 150-170)
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference CRUD index pattern (search + sort + paginate)
- `laravel/resources/views/admin/branches/index.blade.php` — reference Blade table pattern
- `laravel/resources/views/layouts/admin.blade.php` — sidebar nav pattern

---

## Scope

> Exact deliverables for this task.

### In Scope
- Create `PatientController` with `index()` method that fetches patients from Plato via `PlatoProxyService`
- Server-side pagination: 20 patients per page, using Plato's `?current_page=N` parameter
- Search by name (LIKE match on Plato `name` field)
- Search by NRIC (Plato `nric` field)
- Search by phone (Plato `phone` field)
- Search filters passed to Plato's `GET /{db}/patient` endpoint as query params
- Create Blade view `resources/views/admin/patients/index.blade.php`
- Table columns: Name, NRIC, Phone, Actions (View link to profile)
- Styled with the existing admin design system (Tailwind V2 colors: primary #0F1B3D, accent #00C9A7)
- Add web route: `Route::resource('patients', PatientController::class)` in `routes/web.php`
- Add sidebar link in `resources/views/layouts/admin.blade.php`

### Out of Scope
- Patient profile detail page (P7-T02)
- Patient document upload (P7-T03)
- Creating or editing patients (Plato is source of truth, admin panel is read-only for patient data)
- Pagination beyond 20/page (Plato's limit)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/PatientController.php` — new controller with index() method
- `laravel/resources/views/admin/patients/index.blade.php` — Blade table view
- `laravel/routes/web.php` — add Resource route
- `laravel/resources/views/layouts/admin.blade.php` — add sidebar nav link

### PatientController::index() Implementation
```php
public function index(Request $request)
{
    // Build query params for Plato
    $query = ['current_page' => $request->get('page', 1)];

    if ($request->filled('search_name')) {
        $query['name'] = $request->get('search_name');
    }
    if ($request->filled('search_nric')) {
        $query['nric'] = $request->get('search_nric');
    }
    if ($request->filled('search_phone')) {
        $query['phone'] = $request->get('search_phone');
    }

    // Fetch from Plato via proxy service
    $response = PlatoProxyService::proxy('GET', 'patient', $query, null);

    $patients = $response['data'] ?? [];
    $total = $response['meta']['total'] ?? count($patients);
    $currentPage = $request->get('page', 1);
    $perPage = 20;

    // Create a LengthAwarePaginator for Blade pagination links
    $patients = new \Illuminate\Pagination\LengthAwarePaginator(
        $patients,
        $total,
        $perPage,
        $currentPage,
        ['path' => $request->url(), 'query' => $request->query()]
    );

    return view('admin.patients.index', compact('patients'));
}
```

### API Endpoints
- `GET /api/v2/plato/patient?current_page=N` — via PlatoProxyController (existing)
- `GET /api/v2/plato/patient?name=SEARCH&nric=SEARCH&phone=SEARCH&current_page=N` — search params

### Data / Schema
Plato patient response fields (from `docs/api-guidelines.md`):
- `id` (UUID) — patient ID in Plato
- `name` (string) — full name
- `nric` (string) — NRIC number
- `phone` (string) — phone number
- `givenid` (string) — auto-generated clinic patient ID

### Blade View Pattern (follow `resources/views/admin/branches/index.blade.php`)
- Extend `layouts.admin`
- Search form: 3 text inputs (Name, NRIC, Phone) + Search button
- Table: striped rows, sticky header
- Columns: # (row number), Name, NRIC, Given ID, Phone, Actions (View eye icon linking to `admin.patients.show`)
- Empty state: centered SVG + message "No patients found"
- Pagination: `{{ $patients->links() }}`
- Row count: "Showing X-Y of Z patients"

### Constraints
- All Plato calls must route through `PlatoProxyService` — never direct HTTP to Plato
- Pagination: always 20 per page (Plato's enforced limit)
- Read-only — admin panel does not modify patient data

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] `GET /admin/patients` renders a Blade view with a table of patients from Plato
- [ ] Pagination works: 20 patients per page, clickable page links
- [ ] Search by name filters patient list (input "Ahmad" shows only matching patients)
- [ ] Search by NRIC filters patient list
- [ ] Search by phone filters patient list
- [ ] Sidebar has a "Patients" link between "Doctors" and "Calendar Setup"
- [ ] Empty state message appears when no patients match search criteria
- [ ] `php -l app/Http/Controllers/Admin/PatientController.php` passes syntax check

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
