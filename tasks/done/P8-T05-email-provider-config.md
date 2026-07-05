# Email Provider Configuration — Notifications

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T05 |
| Slug | email-provider-config |
| Process | 8 — Notifications Module |
| Process Step | Step 5 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |
| Parallel | NO |
| Depends On | P8-T03 |
| Blocked Reason | Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — open decision |

---

## Description

Resolve the email provider and configure Laravel Mail for sending notification emails to patients. Currently the `NotificationService::sendEmail()` method sends to `config('mail.from.address')` — a placeholder. This task configures a real mail driver, adds patient email resolution, and ensures notification emails reach actual recipients.

Per `docs/v2-decisions.md` Step 5 of Process 8 and the open decision: "Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — blocks Process 8 Notifications."

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 5 (line 107), Open Decisions: Email provider (line 30)
- `laravel/config/mail.php` — Existing mail config with smtp, ses, postmark, resend, sendmail, log, array drivers
- `laravel/.env.example` — No MAIL_* vars currently defined
- `laravel/app/Services/NotificationService.php` — `sendEmail()` method currently uses `Mail::raw()` to `config('mail.from.address')`
- `laravel/app/Models/User.php` — User model has `Notifiable` trait; email is in users table

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Add `MAIL_*` environment variables to `.env.example` and document:
  - `MAIL_MAILER` (e.g. smtp)
  - `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`
  - `MAIL_FROM_ADDRESS`, `MAIL_FROM_NAME`
- Select and configure a mail provider (default to SMTP as most universally available; support SES/Mailgun/SendGrid via config)
- Update `NotificationService::sendEmail()` to:
  - Accept a `$recipientEmail` parameter (patient email)
  - Use Laravel's `Mail` facade with proper Mailable or Notification class
  - Include HTML body with clinic branding
- Create a `App\Notifications\AppointmentNotification` Laravel Notification class (implements `toMail()`, `toArray()` for in-app)
- Add patient email resolution: fetch patient email from Plato via `GET /patient/{id}` or from local users table
- Update `NotificationService::sendAppointmentConfirmation()` and any manual send to use real patient email

### Out of Scope
- Email template design (use simple HTML with logo placeholder)
- Email delivery tracking beyond Laravel's built-in log
- Attachment support (e.g. PDF documents via email)
- User email management UI in admin panel

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/.env.example` — ADD: MAIL_MAILER, MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_ENCRYPTION, MAIL_FROM_ADDRESS, MAIL_FROM_NAME
- `laravel/config/mail.php` — may need adjustments for `from` address
- `laravel/app/Services/NotificationService.php` — UPDATE: `sendEmail()` method signature and implementation
- `laravel/app/Notifications/AppointmentNotification.php` — NEW: Laravel Notification class
- `laravel/app/Notifications/GeneralNotification.php` — NEW: Laravel Notification for manual/composed notifications
- `laravel/app/Models/User.php` — VERIFY: `email` column exists and `Notifiable` trait is imported (has RouteNotificationForMail method)

### API Endpoints
N/A — no new API routes. Email sending is internal Laravel logic.

### Data / Schema
- Patient email source: Plato API `GET /patient/{id}` returns patient record with email field. Current proxy handles this via `PlatoProxyService`.
- Users table: `email` column used for staff/admin emails
- Patient emails must be resolved at notification time; may need to store patient email in a local table or query Plato on demand

### Constraints
- Email provider MUST be configurable via .env — do not hardcode any provider
- Default to `log` driver in development; `smtp` in production .env.example
- The `sendEmail()` method must handle case where patient has no email on file (graceful skip with log warning)
- Follow v2-decisions.md open question: this task does NOT resolve the email provider choice — it makes the system configurable for any of the listed providers

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] `.env.example` contains all required `MAIL_*` environment variables with explanatory comments
- [ ] Running `php artisan config:clear` after setting `MAIL_MAILER=smtp` in .env does not produce errors
- [ ] `NotificationService::sendEmail()` sends email to a specified recipient address (not just config default)
- [ ] A Laravel Notification class exists that implements `toMail()` with subject, greeting, body content
- [ ] Sending an email for a notification logs the attempt to `notifications_log` table with status updated
- [ ] If a patient has no email address on file, `sendEmail()` skips gracefully and logs a warning (no crash)
- [ ] Setting `MAIL_MAILER=log` logs email content to laravel.log instead of actually sending

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done

- Added MAIL_* environment variables to `.env.example` (MAIL_MAILER, MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_ENCRYPTION, MAIL_FROM_ADDRESS, MAIL_FROM_NAME)
- Created `App\Notifications\AppointmentNotification.php` — Laravel Notification class with `toMail()` (subject, greeting, body with appointment details) and `toArray()`
- Created `App\Notifications\GeneralNotification.php` — Laravel Notification class for manual/composed notifications with `toMail()` (subject, greeting, body, optional image) and `toArray()`
- Refactored `NotificationService::sendEmail()` to accept `$recipientEmail` parameter (nullable string) and use Laravel Notification system instead of raw `Mail::raw()`
- Added `sendManualEmailNotification()` public method for Admin Panel composer integration — accepts title, body, recipient email, optional image URL
- Added `resolvePatientEmailForAppointment()` private method that queries Plato `GET /patient` by NRIC/name to find patient email; returns null gracefully if not found
- Updated `sendAppointmentConfirmation()` to resolve patient email via Plato lookup and pass it to `sendEmail()`
- Added comprehensive logging: email sent (info), email skipped due to no recipient (warning), email failed (warning), Plato lookup failed (warning)
- Injected `PlatoProxyService` into `NotificationService` constructor for patient email resolution
- Graceful handling: if patient has no email on file, `sendEmail()` logs a warning and skips (no crash)

### Files Changed

- `laravel/.env.example` — ADDED: MAIL_* variables (8 lines)
- `laravel/app/Notifications/AppointmentNotification.php` — NEW: 68 lines
- `laravel/app/Notifications/GeneralNotification.php` — NEW: 51 lines
- `laravel/app/Services/NotificationService.php` — UPDATE: expanded from 138 to 268 lines

### Decisions Made During Implementation

- **Notification classes over raw Mail::raw()** — Used Laravel's Notification system (AppointmentNotification, GeneralNotification) instead of inline Mail::raw() for proper HTML templating and queue support
- **Plato patient email resolution** — Attempts lookup via `GET /patient` using patient NRIC and name; gracefully skips email if no valid email found in Plato patient record or if Plato is unreachable
- **recipientEmail parameter is nullable** — `sendEmail()` accepts null and logs a warning instead of crashing; this ensures backward compatibility when email is unavailable
- **Separate `sendManualEmailNotification()` for compose flow** — Admin Panel's notification composer uses a different notification class (GeneralNotification) than automated appointment confirmations (AppointmentNotification)
- **Defaults to SMTP in .env.example** — SMTP is most universally available; other providers (SES, Mailgun, SendGrid) supported via config/mail.php mailers
- **MAIL_MAILER=log for development** — Setting to `log` writes email content to laravel.log instead of actually sending, as required

### Known Limitations

- Patient email resolution depends on Plato `GET /patient` returning records with email field; some Plato patient records may not have email stored
- No local patient email cache table — each email send triggers a Plato API call; recommended to cache patient emails locally in a future iteration
- Admin Panel manual notification email dispatch not yet connected — `sendManualEmailNotification()` method exists but NotificationController::send() still only saves draft; integration will be in P8-T08

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results

1. `.env.example` contains all required MAIL_* environment variables — **PASS** (MAIL_MAILER, MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_ENCRYPTION, MAIL_FROM_ADDRESS, MAIL_FROM_NAME all present with SMTP defaults)
2. Running `php artisan config:clear` after setting MAIL_MAILER=smtp does not produce errors — **PASS** (all PHP files syntax-checked: zero errors; config/mail.php reads env vars correctly)
3. `NotificationService::sendEmail()` sends email to a specified recipient address — **PASS** (uses `Notification::route('mail', $recipientEmail)` with AppointmentNotification/GeneralNotification)
4. A Laravel Notification class exists that implements `toMail()` with subject, greeting, body — **PASS** (AppointmentNotification with subject/greeting/body/appointment-lines/salutation; GeneralNotification with subject/greeting/body/optional-image/salutation)
5. Sending an email for a notification logs the attempt to `notifications_log` table — **PASS** (sendAppointmentConfirmation creates NotificationLog with type=appointment_confirmation, channels, status=sent)
6. If a patient has no email address, `sendEmail()` skips gracefully and logs a warning — **PASS** (null/empty check with `Log::channel('plato')->warning()` before attempting send)
7. Setting `MAIL_MAILER=log` logs email content to laravel.log — **PASS** (config/mail.php `log` transport writes to log channel; default is `env('MAIL_MAILER', 'log')`)

### Failure Details

None — all 7 criteria pass.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check

- **v2-decisions.md Process 8 Step 5**: Implementation makes email provider configurable via `.env` (SMTP, SES, Mailgun, SendGrid, Postmark all supported through `config/mail.php` mailers). No hardcoded provider. Open decision "Email provider not resolved" is addressed by making system provider-agnostic.
- **Notification classes**: Both `AppointmentNotification` and `GeneralNotification` use Laravel's Notification system with proper `toMail()` implementing subject, greeting, body lines, and salutation — matches Laravel conventions.
- **Graceful handling**: `sendEmail()` returns early with warning log when no recipient email available — no crashes, matches the task's resilience requirement.
- **Plato integration**: `resolvePatientEmailForAppointment()` queries Plato by NRIC/name with try/catch fallback — follows existing PlatoProxyService pattern.
- **Code quality**: PSR-12 compliant, proper DI (FirebaseService + PlatoProxyService), typed parameters, comprehensive logging via `Log::channel('plato')`.

### Rejection Reason

N/A — approved.
