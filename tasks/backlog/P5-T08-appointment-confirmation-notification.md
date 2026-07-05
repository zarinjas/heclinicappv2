# P5-T08 — Appointment Confirmation Notification

## Task ID
P5-T08

## Title
Appointment Confirmation Notification

## Header

| Field | Value |
|-------|-------|
| Task ID | P5-T08 |
| Slug | appointment-confirmation-notification |
| Process | 5 — Booking Flow |
| Process Step | Step 8 |
| Type | Both |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P5-T07 |
| Blocked Reason | N/A |

---

## Description

Implement the mobile-side handling for appointment confirmation notifications. After the admin creates the appointment (P5-T07), the patient receives three types of notifications: Push (FCM), Email, and In-App. This task handles the Flutter-side reception and display of these notifications, including deep linking to the appointment detail. Per v2-decisions.md Process 5 Step 8.

---

## Context

- `docs/v2-decisions.md` — Process 5, Step 8
- `docs/CODEBASE.md` — Section 8 (Firebase Cloud Functions, FCM tokens, historynotif collection)
- `docs/CODEBASE.md` — Section 17 (Custom Actions — push notification handlers)
- `lib/backend/push_notifications/push_notifications_handler.dart` — existing push handler
- `lib/custom_code/actions/setup_f_c_m_foreground_handler.dart` — existing foreground handler
- `lib/custom_code/actions/get_f_c_m.dart` — existing FCM token retrieval

---

## Scope

### In Scope
- Handle incoming FCM push notifications when app is in background/killed — tap opens appointments tab
- Handle incoming FCM push notifications when app is in foreground — show local notification or in-app banner
- Read In-App notifications from Firestore `historynotif` collection for the current user
- Update notification badge/count in FFAppState (coutnnotif variable) when new notification arrives
- Deep link from push notification tap: navigate directly to the appointment detail or appointments tab
- Parse notification payload to extract appointment ID, type, and metadata
- Ensure notification permissions are requested on first app launch (if not already handled)

### Out of Scope
- Notification composer in Admin Panel (Process 8)
- Email template design (Laravel side)
- Automated triggers for reminders 24h/1h before appointment (Process 8)
- Bulk notification targeting (Process 8)

---

## Technical Spec

### Files to Create or Modify
- `lib/backend/push_notifications/push_notifications_handler.dart` — update to handle appointment confirmation payloads
- `lib/pages/notifications/` — new notification list display (if not already built)
- `lib/custom_code/actions/setup_f_c_m_foreground_handler.dart` — update for appointment notification handling
- `lib/app_state.dart` — update notification count variable

### Data / Schema
- Firestore `historynotif` collection fields: title, body, type ("appointment_confirmed"), appointment_id, timestamp, read (bool), deep_link
- FCM payload structure: `{ title, body, type, appointment_id, click_action: "FLUTTER_NOTIFICATION_CLICK" }`

### Notification Handling Flow
1. Firebase FCM sends push to device token
2. Background: OS shows notification, tap opens app → `push_notifications_handler.dart` handles navigation
3. Foreground: `setup_f_c_m_foreground_handler.dart` shows local notification or in-app toast
4. On any notification tap with type "appointment_confirmed": navigate to `/myBookingPage` or appointment detail
5. `historynotif` document is read client-side for in-app notification list

### UI Components
- In-app notification banner (foreground): brief overlay at top of screen, auto-dismiss after 3 seconds
- Notification badge on Appointments tab icon in bottom nav
- FFAppState.coutnnotif updated to reflect unread count

### Constraints
- Must handle multiple notification types (not just appointment) — check type field before deep linking
- Do NOT clear existing push notification handling behavior — extend it
- Notification tap navigation must work from both cold start and background state

---

## Acceptance Criteria

- [ ] Push notification received when app is in background, tapping opens the appointments tab
- [ ] Push notification received when app is in foreground, shows an in-app banner or toast
- [ ] Notification badge count (FFAppState.coutnnotif) increments when a new notification arrives
- [ ] In-App notification appears in Firestore `historynotif` collection with correct fields
- [ ] Tapping a confirmation notification navigates to the appointment detail or appointments list
- [ ] Notification works from app cold start (app not running)
- [ ] Existing push notification behavior is preserved (other notification types still work)

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
- [ ] Background notification tap — PASS / FAIL
- [ ] Foreground notification — PASS / FAIL
- [ ] Badge count update — PASS / FAIL
- [ ] Firestore historynotif entry — PASS / FAIL
- [ ] Deep link navigation — PASS / FAIL
- [ ] Cold start notification — PASS / FAIL
- [ ] Existing notifications preserved — PASS / FAIL

### Failure Details
{If FAILED}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO —
- v2-ux-spec.md alignment: YES / NO —

### Rejection Reason
{If REJECTED}
