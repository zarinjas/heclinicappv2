# Patient Profile View — Plato Data with Manual Re-Sync

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T02 |
| Slug | patient-profile-view |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 2 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P7-T01 |
| Blocked Reason | N/A |

---

## Description

Create a patient profile detail page in the Laravel Admin Panel accessible from the patient list. The page displays all patient data fetched from Plato via the proxy (`GET /hemedclinic/patient/{id}`), including demographic info, vitals summary, and clinical history links. Includes a "Re-sync from Plato" button that forces a fresh fetch.

Per `docs/v2-decisions.md` Process 7 Step 2.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 2 (line 95)
- `docs/api-guidelines.md` — Section 8, `GET /{db}/patient/{id}` and `GET /{db}/patient/{id}/graphing`
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference `show()` pattern
- `laravel/resources/views/admin/branches/show.blade.php` — reference detail view pattern (definition list, status badges)
- `laravel/app/Services/PlatoProxyService.php` — proxy method signature

---

## Scope

> Exact deliverables for this task.

### In Scope
- Add `PatientController@show($id)` method fetching patient from `GET /hemedclinic/patient/{id}`
- Display patient fields: Name, NRIC, Phone, Given ID, Date of Birth, Gender, Address, Nationality, Allergies, Medical Notes
- Optional: Fetch vitals summary from `GET /patient/{id}/graphing` and show a simple count or "No vitals data" message
- "Re-sync from Plato" button that re-fetches the patient data and refreshes the page
- Blade view `resources/views/admin/patients/show.blade.php`
- Styled as a definition list (`<dl>`) matching `branches/show.blade.php` pattern
- Back link to patient list
- Links to related sections: Appointments for this patient (deferred to future tasks)

### Out of Scope
- Editing patient data (Plato is source of truth)
- Patient document upload UI (P7-T03)
- Appointment history list embedded in profile (future)
- Vitals graphing rendering (stays in mobile app)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/PatientController.php` — add `show($id)` method
- `laravel/resources/views/admin/patients/show.blade.php` — new detail view
- (No new routes needed — `Route::resource` already generates `show` route)

### PatientController::show() Implementation
```php
public function show($id)
{
    $response = PlatoProxyService::proxy('GET', "patient/{$id}", null, null);

    if (empty($response['data'])) {
        abort(404, 'Patient not found in Plato');
    }

    $patient = $response['data'];

    // Optionally fetch vitals summary
    $vitalsCount = null;
    try {
        $graphingResponse = PlatoProxyService::proxy('GET', "patient/{$id}/graphing", null, null);
        $vitalsCount = count($graphingResponse['data'] ?? []);
    } catch (\Exception $e) {
        $vitalsCount = null; // silently fail — graphing is optional
    }

    return view('admin.patients.show', compact('patient', 'vitalsCount'));
}
```

### API Endpoints
- `GET /api/v2/plato/patient/{id}` — fetch single patient (via proxy)
- `GET /api/v2/plato/patient/{id}/graphing` — vitals summary (optional)

### Data / Schema
Patient fields from Plato:
- `id` (UUID), `givenid` (string), `name` (string), `nric` (string), `phone` (string)
- `dob` (date), `gender` (string), `address` (string), `nationality` (string)
- `allergies` (string/array), `medical_notes` (text)
- `created_at`, `updated_at`

### Blade View Pattern (follow `branches/show.blade.php`)
- Extend `layouts.admin`
- Title: patient name + given ID badge
- Definition list: field labels on left (gray uppercase), values on right (dark text)
- Sections: Personal Info (name, NRIC, DOB, gender), Contact (phone, address), Medical (allergies, notes), Vitals (count or "No data")
- Re-sync button: teal `bg-[#00C9A7]` button, POST to same page with `?sync=1` or a dedicated sync action
- Back link: left arrow SVG + "Back to Patients" → `route('admin.patients.index')`

### Constraints
- All Plato calls through `PlatoProxyService`
- Read-only — no PUT/PATCH to Plato from admin panel
- Vitals graphing fetch is optional — show "Unavailable" if endpoint fails

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Clicking a patient name in the patient list navigates to `/admin/patients/{id}` and shows patient details
- [ ] Patient detail page shows: name, NRIC, given ID, phone, DOB, gender, address, nationality
- [ ] Patient detail page shows allergies and medical notes (or "None" if empty)
- [ ] "Re-sync from Plato" button re-fetches patient data and renders updated info
- [ ] Back link navigates to the patient list at `/admin/patients`
- [ ] Vitals count section appears (shows number or "Unavailable" message)
- [ ] Invalid patient ID shows a 404 page (not a PHP error)
- [ ] `php -l` passes syntax check on new/modified controller code

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
