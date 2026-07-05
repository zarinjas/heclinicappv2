# FCM Push Notification — Cloud Function Upgrade

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T04 |
| Slug | fcm-push-upgrade |
| Process | 8 — Notifications Module |
| Process Step | Step 4 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P8-T02, P8-T03 |
| Blocked Reason | N/A |

---

## Description

Upgrade the existing `sendPushNotificationsTrigger` Firebase Cloud Function and the Laravel-side push dispatch logic to support targeted notification delivery. Currently all pushes broadcast to "All" users. This task adds targeting: resolving FCM tokens for specific branches, doctors, appointment date ranges, or individual patients.

Per `docs/v2-decisions.md` Step 4 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `firebase/functions/index.js` — Existing Cloud Function `sendPushNotificationsTrigger` (Firestore trigger on `ff_push_notifications/{id} onCreate`)
- `laravel/app/Services/FirebaseService.php` — `writePushNotification()` method writes to Firestore `ff_push_notifications` collection
- `laravel/app/Services/NotificationService.php` — Orchestrates push dispatch, currently hardcodes `target_audience: 'All'`
- `docs/CODEBASE.md` — Firebase Section: Firestore collections `fcm_tokens` (subcollection inside `users/{uid}`), `ff_push_notifications` structure
- `docs/v2-decisions.md` — Process 8 Steps 2-3 (targeting + channels)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Update `NotificationService::sendPush()` to pass targeting information to `FirebaseService::writePushNotification()`
- Update `FirebaseService::writePushNotification()` to accept and store `user_refs` array (Firestore document paths for targeted users) and targeting metadata
- Upgrade `sendPushNotificationsTrigger` Cloud Function to:
  - Support `user_refs` for direct targeting (users whose tokens to use)
  - Support `branch_ids`, `doctor_ids` targeting (resolve which users to send to)
  - Support `target_date_range` for appointment-based targeting
- Add helper to resolve FCM tokens for a given target segment (branch → users → fcm tokens)
- Maintain backward compatibility: when no targeting specified, fall back to broadcast-all behavior

### Out of Scope
- Email sending (P8-T05)
- In-app notification writes (P8-T06)
- Scheduled/automated triggers (P8-T07)
- Notification history log UI (P8-T08)
- Deep link support in push payload (P8-T06)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `firebase/functions/index.js` — UPDATE: `sendPushNotificationsTrigger` to handle targeted sends with `user_refs`, `branch_ids`, `doctor_ids`, `target_date_range`
- `laravel/app/Services/FirebaseService.php` — UPDATE: `writePushNotification()` to accept and store `user_refs` array and targeting fields
- `laravel/app/Services/NotificationService.php` — UPDATE: `sendPush()` to build `user_refs` from targeting data before calling FirebaseService
- `laravel/app/Models/User.php` — possibly: add relationship to FCM tokens or method to resolve tokens

### Data / Schema
Firestore document `ff_push_notifications/{id}` (new/updated fields):
- `user_refs` — array of Firestore document paths (e.g. `["users/uid1", "users/uid2"]`) — if present, send only to these users
- `branch_ids` — array of branch IDs (Cloud Function resolves branches → users → tokens)
- `doctor_ids` — array of doctor IDs (Cloud Function resolves doctors → users → tokens)
- `target_date_range` — object `{from: "YYYY-MM-DD", to: "YYYY-MM-DD"}` — sends to users with appointments in range
- `target_audience` — string ("All" default, or specific audience filter)
- `batch_index` / `num_batches` — existing batch support for large sends

FCM tokens are stored in Firestore at `users/{uid}/fcm_tokens/{auto-id}` with fields: `fcm_token`, `device_type`, `created_at`.

### Cloud Function Logic (Pseudocode)
```
if (notification.user_refs exists):
    resolve FCM tokens from specific user paths
else if (notification.branch_ids exists):
    find all users with branch_id in branch_ids → resolve FCM tokens
else if (notification.doctor_ids exists):
    find all users with doctor_id in doctor_ids → resolve FCM tokens
else if (notification.target_date_range exists):
    find users with appointments in date range → resolve FCM tokens
else:
    resolve all FCM tokens (existing broadcast behavior via fcm_tokens collection group)
```

### Constraints
- Firebase Cloud Function has 540s timeout, 2GB memory — batching must stay within limits
- Existing batch logic (batch_index, num_batches) must be preserved or enhanced for targeted sends
- FCM token resolution must handle cases where a target user has no tokens registered (graceful skip)
- The `ff_push_notifications` collection is in the default Firestore database (`(default)`)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Writing a `ff_push_notifications` document with `user_refs` containing specific user paths sends push only to those users' FCM tokens
- [ ] Writing a `ff_push_notifications` document with `branch_ids` sends push only to users belonging to those branches
- [ ] Writing a `ff_push_notifications` document WITHOUT targeting fields maintains broadcast-all behavior (backward compatible)
- [ ] The Cloud Function handles the case where a target user has no FCM tokens without crashing
- [ ] The `status` field on the `ff_push_notifications` document is updated to "succeeded" after successful send
- [ ] Large sends (>500 tokens) use batching correctly without hitting Firestore query limits
- [ ] `NotificationService::sendPush()` from Laravel correctly passes targeting data to Firestore

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
