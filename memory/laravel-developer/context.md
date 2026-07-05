# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
P7-T01 — Patient List — Server-Side Pagination, Search (IN-REVIEW)

## Implementation Summary — P7-T01
- `app/Http/Controllers/Admin/PatientController.php`: new controller with index() querying Plato /patient endpoint via PlatoProxyService with search params (name, NRIC, phone) and current_page pagination. Uses LengthAwarePaginator for Blade pagination links. Includes show() stub for patient detail view.
- `resources/views/admin/patients/index.blade.php`: Blade view with search form (3 text inputs), data table (Name, NRIC, Given ID, Phone, View action), empty state, pagination links.
- `resources/views/admin/patients/show.blade.php`: stub detail view with back link and patient info definition list.
- `routes/web.php`: added PatientController import and Route::resource('patients')->only(['index', 'show']) under auth+role middleware.
- `resources/views/layouts/admin.blade.php`: added Patients sidebar nav link with people SVG icon between Doctors and Calendar Setup.

## Last Completed Task
P5-T07 — Admin Appointment Creation and Confirmation (DONE)

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
