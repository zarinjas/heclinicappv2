# Channel Selection — Notifications

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T03 |
| Slug | channel-selection |
| Process | 8 — Notifications Module |
| Process Step | Step 3 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P8-T01 |
| Blocked Reason | N/A |

---

## Description

Add channel selection to the notification composer — allowing staff to choose which delivery channels to use (Push, Email, In-App, or any combination). Update the `NotificationService` to respect channel selection when sending, rather than always sending all three channels unconditionally.

Per `docs/v2-decisions.md` Step 3 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 3 (line 105), Notification Strategy: 3-channel approach (lines 341-348)
- `laravel/app/Services/NotificationService.php` — Existing service that always sends all 3 channels; needs modification
- `laravel/app/Services/FirebaseService.php` — FirebaseService with `writePushNotification()` and `writeInAppNotification()` methods
- `laravel/app/Models/NotificationLog.php` — channels column stores JSON array (e.g. `['push', 'email', 'in_app']`)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Add channel checkboxes to Vue compose form: Push Notification, Email, In-App Notification (can select any combination)
- Form validation: at least one channel must be selected
- Update `NotificationController@send` to accept and store `channels` array
- Update `NotificationService` methods to check `$channels` array before dispatching each channel:
  - `sendPush()` only runs if `'push'` is in channels
  - `sendEmail()` only runs if `'email'` is in channels
  - `sendInApp()` only runs if `'in_app'` is in channels
- Ensure `NotificationLog.channels` correctly stores the selected channels as JSON

### Out of Scope
- Actual push sending via FCM (P8-T04)
- Email configuration (P8-T05)
- In-app deep link implementation (P8-T06)
- Channel-specific failure handling (P8-T08)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/resources/js/Pages/Admin/Notifications/Compose.vue` — ADD: channel checkboxes group (Push, Email, In-App)
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — UPDATE: `send()` to accept `channels` array, validate at least 1 channel
- `laravel/app/Services/NotificationService.php` — UPDATE: add conditional channel gating in `sendAppointmentConfirmation()` and any general `send()` method

### API Endpoints
- `POST /admin/notifications/compose` — updated to accept: `channels` (array, at least 1 of: `'push'`, `'email'`, `'in_app'`)

### Data / Schema
Existing `channels` column in `notifications_log`:
- JSON array, e.g. `["push", "email", "in_app"]` or `["push"]` or `["email", "in_app"]`
- Already handled by model `$casts = ['channels' => 'array']`

### UI Components (Admin Panel — Vue 3)
- Label: "Delivery Channels"
- Three checkboxes in a row or stacked:
  - [x] Push Notification (default checked)
  - [x] Email (default checked)
  - [x] In-App Notification (default checked)
- All three default to checked (matching current "send all channels" behavior)
- Validation message: "Please select at least one delivery channel" if none checked

### Constraints
- Must maintain backward compatibility: existing code that calls NotificationService without explicit channels should default to all 3 channels
- Channel values must match exactly: `'push'`, `'email'`, `'in_app'`

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] The compose form shows 3 channel checkboxes: Push, Email, In-App (all checked by default)
- [ ] Deselecting all checkboxes and submitting shows a validation error "Please select at least one delivery channel"
- [ ] Submitting with only "Push" checked stores `["push"]` in the `channels` JSON column of `notifications_log`
- [ ] Submitting with all 3 checked stores `["push", "email", "in_app"]` in the `channels` column
- [ ] An existing automated notification (e.g. appointment confirmation) still sends all 3 channels when no explicit channel filter is passed
- [ ] A manual notification saved with channels=["push"] only triggers push send and skips email + in-app (P8-T04 will verify actual send behavior)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Added channel selection to notification composer. Admin can now select Push, Email, and/or In-App channels (all checked by default). User selection is validated (at least one required) and persisted to the `channels` JSON column. NotificationService updated to gate send methods (sendPush/sendEmail/sendInApp) based on provided channels array, with full backward compatibility (null defaults to all 3 channels).

### Files Changed
- `laravel/resources/views/admin/notifications/compose.blade.php` — Added Delivery Channels section with 3 checkboxes (Push/Email/In-App), all checked by default
- `laravel/app/Http/Controllers/Admin/NotificationController.php` — Added channels validation (required, array, min:1, values in:push/email/in_app), custom error message, stores validated channels
- `laravel/app/Services/NotificationService.php` — Added optional `$channels` parameter to `sendAppointmentConfirmation()`, defaults to all 3 for backward compat, gates each send method

### Decisions Made During Implementation
- Used Blade checkboxes instead of Vue (project uses Blade/Tailwind, not Vue)
- Default channels: all 3 checked to preserve existing "send all" behavior
- Backward compat: `$channels = null` parameter defaults to `['push', 'email', 'in_app']`, existing callers unchanged
- Channel values match exactly: `'push'`, `'email'`, `'in_app'`

### Known Limitations
- Actual push/in-app/email sending not verified (out of scope for this task)
- Channel-specific failure handling deferred to P8-T08

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results

- [x] The compose form shows 3 channel checkboxes: Push, Email, In-App (all checked by default) — **PASS** — Delivery Channels section with 3 checkboxes present in compose.blade.php, all default-checked via `old('channels', ['push', 'email', 'in_app'])`
- [x] Deselecting all checkboxes and submitting shows a validation error "Please select at least one delivery channel" — **PASS** — Controller validates `channels` as `required|array|min:1` with custom message; `@error('channels')` renders in view
- [x] Submitting with only "Push" checked stores `["push"]` in the `channels` JSON column of `notifications_log` — **PASS** — Controller uses `$validated['channels']`, model casts `channels` to `array` via `$casts`
- [x] Submitting with all 3 checked stores `["push", "email", "in_app"]` in the `channels` column — **PASS** — Same mechanism as above, array stored as JSON
- [x] An existing automated notification (e.g. appointment confirmation) still sends all 3 channels when no explicit channel filter is passed — **PASS** — `sendAppointmentConfirmation()` accepts `?array $channels = null`, defaults to `['push', 'email', 'in_app']` when null, all 3 send methods called
- [x] A manual notification saved with channels=["push"] only triggers push send and skips email + in-app — **PASS** — `sendPush`/`sendEmail`/`sendInApp` each gated with `in_array()` check against `$selectedChannels`

### Failure Details
None. All 6 acceptance criteria pass.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason
