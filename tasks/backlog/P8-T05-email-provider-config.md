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
| Assigned Date | |
| Status | BACKLOG |
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

### Files Changed

### Decisions Made During Implementation

### Known Limitations

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
