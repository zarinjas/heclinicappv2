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
| Assigned Date | |
| Status | BACKLOG |
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
