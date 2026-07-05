# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
P7-T05 — Create Walk-In Appointment — Admin Panel (IN-REVIEW)

## Implementation Summary — P7-T04
- `app/Http/Controllers/Admin/AdminAppointmentController.php`: new controller with index() fetching appointments from Plato via proxy (`GET /appointment`), supports filters (date_from, date_to, doctor_id, facility_id, status), uses LengthAwarePaginator with 20/page
- `resources/views/admin/appointments/index.blade.php`: Blade view with filter row (date range, doctor/branch dropdowns, status), data table (Date, Time, Patient Name, NRIC, Doctor, Branch, Status chip), colored status chips (green/amber/red/blue), empty state, pagination
- `routes/web.php`: added AdminAppointmentController import and Route::resource('appointments')->only(['index']) under auth+role middleware
- `resources/views/layouts/admin.blade.php`: added Appointments sidebar nav link with calendar SVG icon between Patients and Calendar Setup
- `database/migrations/2026_07_05_000011_create_patient_documents_table.php`: patient_documents table with patient_plato_uid, filename, original_name, title, mime_type, size_bytes, uploaded_by FK, unique on (patient_plato_uid, filename)
- `app/Services/PatientDocumentService.php`: upload/delete/list/serve for patient PDFs using Laravel Storage public disk at `patients/{uid}/documents/{uuid}.pdf`
- `app/Http/Controllers/Admin/PatientController.php`: added uploadDocument() (validates PDF only, max 10MB), deleteDocument(), show() now passes $documents
- `resources/views/admin/patients/show.blade.php`: Documents section with upload form, document list table (title/filename/size/date, download/delete actions), empty state
- `routes/web.php`: POST /admin/patients/{patient}/documents and DELETE /admin/patients/{patient}/documents/{filename}
- Fallback to local storage because kreait/laravel-firebase not installed

## Last Completed Task
P7-T02 — Patient Profile View — Plato Data with Manual Re-Sync (DONE)

## Implementation Summary — P7-T02
- `app/Http/Controllers/Admin/PatientController.php`: enhanced `show()` method — added `Request` parameter for `?sync=1` support (cache-busting via `_nocache` query param), vitals count from `/patient/{id}/graphing` endpoint, passes `$vitalsCount` to view
- `resources/views/admin/patients/show.blade.php`: full rewrite with grouped sections (Personal Info, Contact, Medical, Vitals), "Re-sync from Plato" button, vitals count badge with green dot, None/Unavailable placeholders, footer with Patient ID

## Implementation Summary — P7-T01
- `app/Http/Controllers/Admin/PatientController.php`: new controller with index() querying Plato /patient endpoint via PlatoProxyService with search params (name, NRIC, phone) and current_page pagination. Uses LengthAwarePaginator for Blade pagination links. Includes show() for patient detail view.
- `resources/views/admin/patients/index.blade.php`: Blade view with search form (3 text inputs), data table (Name, NRIC, Given ID, Phone, View action), empty state, pagination links.
- `routes/web.php`: added PatientController import and Route::resource('patients')->only(['index', 'show']) under auth+role middleware.
- `resources/views/layouts/admin.blade.php`: added Patients sidebar nav link with people SVG icon between Doctors and Calendar Setup.

## Implementation Summary — P5-T07
- `database/migrations/2026_07_05_000010_create_appointments_table.php`: appointments table
- `app/Models/Appointment.php`: Eloquent model with branch/doctor BelongsTo
- `config/firebase.php`: Firebase project config
- `app/Services/FirebaseService.php`: Firestore REST API client
- `app/Services/NotificationService.php`: 3-channel dispatch (push/email/in-app)
- `app/Services/AppointmentService.php`: transactional appointment creation with Plato proxy
- `app/Http/Controllers/Api/AppointmentController.php`: POST /api/v2/admin/appointments

## Known Constraints
- Plato API token lives in .env only — never exposed
- All Plato list endpoints must implement pagination: current_page loop until empty
- HTTP 429 handling: exponential backoff 1s → 2s → 4s → 8s
- Monitor x-ratelimit-remaining header
- MySQL schemas in v2-decisions.md are authoritative
- Admin Panel timeout: 10s per Plato request
