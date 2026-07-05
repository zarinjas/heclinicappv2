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
| Assigned Date | |
| Status | BACKLOG |
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
{To be filled}

### Files Changed
- {To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

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
