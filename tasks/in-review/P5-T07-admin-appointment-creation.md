# P5-T07 — Admin Appointment Creation and Confirmation

## Task ID
P5-T07

## Title
Admin Appointment Creation and Confirmation

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T07 |
| Slug | admin-appointment-creation |
| Process | 5 — Booking Flow |
| Process Step | Step 7 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P5-T06 |
| Blocked Reason | N/A |

---

## Description

Create the Laravel API endpoint that receives confirmed WhatsApp booking data from the admin and creates an appointment in Plato via the proxy. After the patient sends a WhatsApp booking request (from P5-T06), clinic staff confirm availability and use the admin panel to create the actual appointment in Plato. This task builds the server-side logic for: receiving booking data, calling Plato's POST /appointment API, and triggering confirmation notifications. Per v2-decisions.md Process 5 Step 7.

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 7
- `docs/api-guidelines.md` — POST /appointment, appointment booking flow
- `docs/CODEBASE.md` — Section 15 (Plato API Appointment Booking Flow)
- `docs/CODEBASE.md` — Section 11 (Plato API endpoints for appointment)
- `docs/CODEBASE.md` — Section 20 (Admin Panel architecture)
- `laravel/app/Http/Controllers/Api/PlatoProxyController.php` — existing proxy controller

---

## Scope

### In Scope
- Create `AppointmentController` in Laravel under `app/Http/Controllers/Api/`
- Create `POST /api/v2/admin/appointments` endpoint for admin to create appointments
- Endpoint accepts: patient data (name, nric, phone), branch info, doctor info, date, time, calendar color ID
- Forwards the appointment creation to Plato via `POST /appointment` using the proxy
- After successful Plato appointment creation, trigger notification dispatch:
  - Push notification via Firebase Admin SDK (existing `sendPushNotificationsTrigger`)
  - Email notification via Laravel Mail
  - In-App notification written to Firestore `historynotif` collection

### Out of Scope
- Admin Panel UI for appointment management (Process 7)
- WhatsApp Center module (Process 10)
- Full notification composer (Process 8)
- Appointment calendar view in admin (Process 7)
- Walk-in appointment creation (Process 7)

---

## Technical Spec

### Files to Create or Modify
- `laravel/app/Http/Controllers/Api/AppointmentController.php` — new controller
- `laravel/app/Services/AppointmentService.php` — business logic for appointment creation
- `laravel/app/Services/NotificationService.php` — notification dispatch service
- `laravel/routes/api.php` — add route for POST /api/v2/admin/appointments

### API Endpoints
- `POST /api/v2/admin/appointments` (Laravel, for admin panel)
  - Body: `{ patient_name, patient_nric, patient_phone, branch_id, doctor_id, doctor_name, appointment_date, appointment_time, calendar_color_id, notes }`
- `POST /api/v2/plato/appointment` (Plato proxy — create appointment)
  - Body: Plato-formatted appointment payload with color (calendar ID), patient info, date/time

### Database (if needed)
- `appointments` table (MySQL): id, plato_appointment_id, patient_name, patient_nric, patient_phone, branch_id, doctor_id, doctor_name, appointment_date, appointment_time, status, created_at, updated_at
- Statuses: pending, confirmed, cancelled, completed

### Notification Payload (to dispatch)
- Push: title "Appointment Confirmed", body "Your appointment with {doctor} at {branch} on {date} {time} is confirmed."
- Email: HTML email template with appointment details
- In-App: Write to Firestore `historynotif` with deep link to appointments tab

### Constraints
- Plato API token stays in Laravel .env — never exposed to mobile APK
- All Plato calls route through existing `PlatoProxyController`
- Sanctum auth required for admin endpoints
- Appointment creation must be atomic — roll back if any step fails
- Handle Plato API errors gracefully (return user-friendly error messages)

---

## Acceptance Criteria

- [ ] POST /api/v2/admin/appointments accepts booking data and creates appointment in Plato
- [ ] Successful Plato appointment creation returns the Plato appointment ID
- [ ] Push notification is sent to the patient's device via Firebase FCM
- [ ] Email notification is queued/sent via Laravel Mail
- [ ] In-App notification is written to Firestore `historynotif` collection
- [ ] If Plato API call fails, endpoint returns error (does NOT send notifications)
- [ ] Unauthenticated requests to the admin endpoint return 401
- [ ] Appointment record is saved in local MySQL `appointments` table for reference

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
- Created `appointments` migration with fields: plato_appointment_id, patient_name, patient_nric, patient_phone, branch_id, branch_name, doctor_id, doctor_name, appointment_date, appointment_time, calendar_color_id, notes, status, plato_response, notified_at
- Created `Appointment` Eloquent model with branch/doctor relationships and proper attribute casting
- Created `config/firebase.php` with FIREBASE_PROJECT_ID, FIREBASE_WEB_API_KEY, Firestore and FCM endpoint configs
- Created `FirebaseService` for writing to Firestore via REST API:
  - `writeToFirestore()` — generic Firestore document writer with API key auth
  - `writePushNotification()` — writes to `ff_push_notifications` collection to trigger existing cloud function `sendPushNotificationsTrigger`
  - `writeInAppNotification()` — writes to `historynotif` collection with deep_link support
  - Proper Firestore REST API document serialization with typed field values
- Created `NotificationService` for 3-channel dispatch:
  - Push: via `FirebaseService.writePushNotification()` triggering existing Cloud Function
  - Email: via Laravel Mail facade (raw text email)
  - In-App: via `FirebaseService.writeInAppNotification()` to Firestore `historynotif`
  - Logs all notification attempts to MySQL `notifications_log` table
- Created `AppointmentService` with transactional appointment creation:
  - Creates local MySQL record first
  - Forwards to Plato API via `POST /appointment` through existing `PlatoProxyService`
  - Updates record with Plato appointment ID on success
  - Dispatches 3-channel notification to patient
  - Rolls back on Plato failure (DB transaction)
- Created `AppointmentController` with `POST /api/v2/admin/appointments`:
  - Input validation for all fields
  - Proper error responses for validation (422), Plato failures (502), and unexpected errors (500)
  - Returns 201 with appointment details on success
- Added route behind `auth:sanctum` middleware for 401 enforcement
- Added Firebase env vars to `.env.example`

### Files Changed
- `laravel/database/migrations/2026_07_05_000010_create_appointments_table.php` — new
- `laravel/app/Models/Appointment.php` — new
- `laravel/config/firebase.php` — new
- `laravel/app/Services/FirebaseService.php` — new
- `laravel/app/Services/NotificationService.php` — new
- `laravel/app/Services/AppointmentService.php` — new
- `laravel/app/Http/Controllers/Api/AppointmentController.php` — new
- `laravel/routes/api.php` — added POST /api/v2/admin/appointments route
- `laravel/.env.example` — added FIREBASE_* vars

### Decisions Made During Implementation
- Firestore writes use the REST API directly (via Laravel HTTP client) instead of requiring `kreait/firebase-php` package, since it's not in composer.json. This avoids adding a new dependency.
- Push notifications leverage the existing Firebase Cloud Function `sendPushNotificationsTrigger` by writing to the `ff_push_notifications` Firestore collection (same trigger as existing admin panel push notification flow).
- Firebase Web API Key is stored in `.env` and passed as `?key=` query parameter for Firestore REST API authentication.
- Plato appointment payload uses minimal required fields (name, phone, date, time, color, ic, notes) based on the Plato API documentation for `POST /appointment`.
- Email notifications use `Mail::raw()` with a simple text body — full HTML email templates deferred to Process 8 (Notifications Module).
- Notification dispatch failures are logged but do NOT fail the appointment creation — the Plato appointment and MySQL record are already committed.

### Known Limitations
- Firestore REST API key auth requires the Firebase Web API Key to have Firestore write permissions (Firestore security rules must allow server-side writes or the API key must be restricted).
- Email notifications currently send to the app admin email (config mail.from.address) as a placeholder — Process 8 will implement proper patient email targeting.
- No patient device token → push notification mapping is maintained in Laravel; push notifications rely on the `ff_push_notifications` collection trigger which targets all users. Targeted push to specific patients requires Process 8.

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results
- [ ] Admin endpoint creates Plato appointment — PASS / FAIL
- [ ] Plato appointment ID returned — PASS / FAIL
- [ ] Push notification sent — PASS / FAIL
- [ ] Email notification sent — PASS / FAIL
- [ ] In-App notification written — PASS / FAIL
- [ ] Error handling on Plato failure — PASS / FAIL
- [ ] Auth enforcement (401) — PASS / FAIL
- [ ] MySQL record saved — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- api-guidelines.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
