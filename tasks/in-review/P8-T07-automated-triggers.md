# Automated Notification Triggers

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T07 |
| Slug | automated-triggers |
| Process | 8 — Notifications Module |
| Process Step | Step 7 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P8-T04, P8-T05, P8-T06 |
| Blocked Reason | N/A |

---

## Description

Implement automated notification triggers for key events: appointment confirmed (Push+Email+In-App, immediate), appointment reminder (Push+In-App, 24h and 1h before), and new document uploaded (Push+In-App, immediate). Use Laravel's scheduler for time-based reminders and hook into existing controller methods for immediate triggers.

Per `docs/v2-decisions.md` Step 7 of Process 8 (lines 109).

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 7 (line 109), Notification triggers quick reference (line 366)
- `laravel/app/Services/NotificationService.php` — Existing `sendAppointmentConfirmation()` entry point
- `laravel/app/Services/AppointmentService.php` — `createAppointment()` method, existing appointment logic
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — `store()` creates appointments
- `laravel/app/Http/Controllers/Admin/PatientController.php` — `uploadDocument()` uploads patient documents
- `laravel/app/Models/Appointment.php` — `appointment_date`, `appointment_time`, `notified_at`, status fields
- `laravel/app/Models/PatientDocument.php` — document upload model (if exists)
- `laravel/routes/console.php` — Laravel scheduler registration (needs task scheduling)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope

**Trigger 1 — Appointment Confirmed (Push + Email + In-App, immediate):**
- Hook into `AppointmentService::createAppointment()` or `AdminAppointmentController::store()` after successful Plato API booking
- Call `NotificationService::sendAppointmentConfirmation(Appointment $appointment)` which already exists but needs refinement
- Must use real patient email (from P8-T05) and proper deep links (from P8-T06)

**Trigger 2 — Appointment Reminder (Push + In-App, 24h and 1h before):**
- Create Laravel scheduled command: `app:send-appointment-reminders`
- Query appointments for tomorrow (appointment_date = now+1day) that have not been reminded yet
- Query appointments for today in the next hour (appointment_time within next 60 min) that have not been reminded yet
- Send Push + In-App reminder with deep link to appointments screen
- Track reminder sent status to prevent duplicates (add `reminded_24h_at` and `reminded_1h_at` timestamp columns to appointments table)

**Trigger 3 — New Document Uploaded (Push + In-App, immediate):**
- Hook into `PatientController::uploadDocument()` after successful Firebase Storage upload
- Send Push + In-App notification to the patient with deep link to health/documents tab
- Include document filename in notification body

### Out of Scope
- Reminder timing customization (24h/1h is fixed)
- WhatsApp notification integration (Process 10)
- Notification preferences per user (all patients receive all triggers)
- Queue-based/batch sending optimization (future)
- Resend on failure logic

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Services/NotificationService.php` — UPDATE: `sendAppointmentConfirmation()` to pull patient email from Plato, add deep link; ADD: `sendAppointmentReminder()`, `sendDocumentUploadedNotification()` methods
- `laravel/app/Services/AppointmentService.php` — UPDATE: `createAppointment()` to trigger confirmation notification after successful booking
- `laravel/app/Http/Controllers/Admin/PatientController.php` — UPDATE: `uploadDocument()` to trigger document notification after successful upload
- `laravel/app/Console/Commands/SendAppointmentReminders.php` — NEW: Artisan command for scheduled reminders
- `laravel/routes/console.php` — ADD: `$schedule->command('app:send-appointment-reminders')->everyMinute();`
- `laravel/database/migrations/2026_07_05_000014_add_reminder_tracking_to_appointments.php` — NEW: adds `reminded_24h_at` and `reminded_1h_at` nullable timestamps to `appointments` table

### API Endpoints
N/A — triggers are internal to Laravel app logic.

### Data / Schema

**Appointments table additions:**
```php
$table->timestamp('reminded_24h_at')->nullable()->after('notified_at');
$table->timestamp('reminded_1h_at')->nullable()->after('reminded_24h_at');
```

**Reminder query logic:**
```php
// 24h reminder: appointments tomorrow, not yet reminded
Appointment::whereDate('appointment_date', now()->addDay()->toDateString())
    ->whereNull('reminded_24h_at')
    ->get();

// 1h reminder: appointments today, time within next 60 min, not yet reminded
Appointment::whereDate('appointment_date', now()->toDateString())
    ->whereTime('appointment_time', '>=', now()->format('H:i'))
    ->whereTime('appointment_time', '<=', now()->addHour()->format('H:i'))
    ->whereNull('reminded_1h_at')
    ->get();
```

### Console Command
```php
class SendAppointmentReminders extends Command
{
    protected $signature = 'app:send-appointment-reminders';
    protected $description = 'Send appointment reminders for 24h-before and 1h-before upcoming appointments';

    public function handle(NotificationService $notificationService)
    {
        // Query 24h reminders
        // For each: $notificationService->sendAppointmentReminder($appointment, '24h')
        // Update reminded_24h_at = now()
        
        // Query 1h reminders
        // For each: $notificationService->sendAppointmentReminder($appointment, '1h')
        // Update reminded_1h_at = now()
    }
}
```

### Constraints
- Scheduler runs every minute — the command must be idempotent and efficient
- Patient email may not exist — skip email for reminder gracefully (reminder is Push + In-App only per spec)
- Document upload: patient ID must be resolved from the document's patient context
- All notifications must log to `notifications_log` table with appropriate type
- Reminders must respect channel selection from P8-T03: only Push + In-App (no email for reminders per v2-decisions spec)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Creating a new appointment via Admin Panel triggers an immediate appointment confirmation notification (Push + Email + In-App)
- [ ] The appointment confirmation notification includes patient email resolved from Plato data
- [ ] After uploading a patient document via Admin Panel, a document notification (Push + In-App) is sent to that patient
- [ ] The document notification includes the document filename in the body
- [ ] Running `php artisan app:send-appointment-reminders` sends reminders for appointments occurring within the next 24 hours
- [ ] Running `php artisan app:send-appointment-reminders` sends reminders for appointments occurring within the next 1 hour
- [ ] Each appointment receives at most one 24h reminder and one 1h reminder (no duplicate sends on repeated runs)
- [ ] The `app:send-appointment-reminders` command is registered in console routes and runs via scheduler
- [ ] All automated notifications are logged in the `notifications_log` table with correct `type` (appointment_confirmation, appointment_reminder, document_uploaded)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done

**Trigger 1 — Appointment Confirmed:** Already fully implemented by prior tasks (P8-T04 FCM, P8-T05 Email, P8-T06 Deep Links). `AppointmentService::createAppointment()` calls `NotificationService::sendAppointmentConfirmation()` which dispatches Push+Email+In-App with proper email resolution and deep links. No new code required for this trigger.

**Trigger 2 — Appointment Reminder:**
- Created `database/migrations/2026_07_05_000014_add_reminder_tracking_to_appointments.php` — adds `reminded_24h_at` and `reminded_1h_at` nullable timestamps to appointments table
- Updated `app/Models/Appointment.php` — added `reminded_24h_at` and `reminded_1h_at` to `$fillable` and `$casts` (datetime)
- Added `sendAppointmentReminder()` to `app/Services/NotificationService.php` — dispatches Push+In-App (no email per spec), updates reminder timestamp, logs to notifications_log
- Created `app/Console/Commands/SendAppointmentReminders.php` — queries appointments due for 24h and 1h reminders (those with null timestamp and correct date/time window), calls sendAppointmentReminder, idempotent (won't re-notify)
- Updated `routes/console.php` — registers `app:send-appointment-reminders` to run everyMinute() via Laravel scheduler

**Trigger 3 — New Document Uploaded:**
- Added `sendDocumentUploadedNotification()` to `app/Services/NotificationService.php` — dispatches Push+In-App with deep link `health/documents`, logs to notifications_log with type `document_uploaded`
- Updated `app/Http/Controllers/Admin/PatientController.php` — `uploadDocument()` now calls `sendDocumentUploadedNotification()` with the patient Plato ID and original filename after successful upload
- Refactored `sendInApp()` to use new private `writeInAppNotify()` helper for cleaner in-app notification writes

### Files Changed

- `laravel/database/migrations/2026_07_05_000014_add_reminder_tracking_to_appointments.php` — NEW
- `laravel/app/Models/Appointment.php` — UPDATED (fillable + casts for reminder timestamps)
- `laravel/app/Services/NotificationService.php` — UPDATED (added sendAppointmentReminder, sendDocumentUploadedNotification, writeInAppNotify helper)
- `laravel/app/Console/Commands/SendAppointmentReminders.php` — NEW
- `laravel/routes/console.php` — UPDATED (added scheduler entry)
- `laravel/app/Http/Controllers/Admin/PatientController.php` — UPDATED (triggers document notification after upload)

### Decisions Made During Implementation

- In-App notification write refactored into `writeInAppNotify()` helper to avoid duplicating FirebaseService call pattern across appointment and document flows
- Reminder notification is Push+In-App only (no email) per v2-decisions.md spec
- Scheduler runs everyMinute() — command is idempotent via nullable timestamp guards
- Document notification includes original client filename in body; patient name lookup deferred (optional per spec)

### Known Limitations

- Patient name not included in document notification body (optional, requires extra Plato API call to resolve)
- Reminder timing (24h/1h) is fixed, not configurable
- No queue/batch optimization — reminders send synchronously in scheduler loop

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED / FAILED

### Criteria Results

### Failure Details

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason
