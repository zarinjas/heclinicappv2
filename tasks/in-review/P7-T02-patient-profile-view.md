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
| Status | IN-REVIEW |
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
Enhanced the existing `PatientController@show()` method to fetch vitals summary from Plato graphing endpoint and accept `?sync=1` query parameter to bypass proxy cache for manual re-sync. Rewrote `show.blade.php` with grouped sections (Personal Info, Contact, Medical, Vitals), Re-sync from Plato button, and definition-list styling matching the branches/show.blade.php pattern.

### Files Changed
- `laravel/app/Http/Controllers/Admin/PatientController.php` — added `Request` parameter to `show()`, vitals count from `/patient/{id}/graphing`, sync cache-busting via `_nocache` query param
- `laravel/resources/views/admin/patients/show.blade.php` — full rewrite with grouped sections, Re-sync button, vitals count badge, None/Unavailable placeholders, footer with Patient ID

### Decisions Made During Implementation
- Re-sync via GET with `?sync=1` (NOT POST) — simpler implementation, same result. The controller adds a `_nocache=timestamp` query param to bypass PlatoProxyService cache.
- Vitals count displayed as "N records available" with green dot, "Unavailable" (italic) on fetch failure per task spec.
- Allergies handled as string or array — implode if array.

### Known Limitations
- Vitals graphing endpoint uses `try/catch` — HTTP 404 or 5xx from Plato will silently show "Unavailable". This is per task spec (graphing is optional).
- No edit ability for patient data (Plato is source of truth) — per scope constraints.

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED

### Criteria Results
- [x] Clicking a patient name in the patient list navigates to `/admin/patients/{id}` and shows patient details — PASS — index.blade.php links to `route('admin.patients.show', $patientId)`, route defined by `Route::resource('patients')`
- [x] Patient detail page shows: name, NRIC, given ID, phone, DOB, gender, address, nationality — PASS — all fields rendered in show.blade.php grouped into Personal Info and Contact sections
- [x] Patient detail page shows allergies and medical notes (or "None" if empty) — PASS — Medical section with `empty()` checks, shows "None" in gray for empty values; allergies handles both string and array types
- [x] "Re-sync from Plato" button re-fetches patient data and renders updated info — PASS — `?sync=1` link to show route, controller adds `_nocache=timestamp` to bypass PlatoProxyService cache for fresh fetch
- [x] Back link navigates to the patient list at `/admin/patients` — PASS — `route('admin.patients.index')` generates correct URL
- [x] Vitals count section appears (shows number or "Unavailable" message) — PASS — Vitals section with green dot + count when data available, "Unavailable" (italic) on fetch failure
- [x] Invalid patient ID shows a 404 page (not a PHP error) — PASS — `abort(404)` called when `$patient` is empty
- [x] `php -l` passes syntax check on new/modified controller code — PASS — verified with `php -l app/Http/Controllers/Admin/PatientController.php`

### Failure Details
N/A — all criteria passed.

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
