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
| Assigned Date | 2026-07-05 |
| Status | DONE |
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
Implemented mobile-side handling for appointment confirmation notifications across 3 files:

1. **`push_notifications_handler.dart`**: Updated `_handlePushNotification()` to detect `type == "appointment_confirmed"` in FCM payload and navigate to `MyBookingPage` (appointments tab). Increments `FFAppState().coutnnotif` on reception. Falls through to existing `initialPageName`-based navigation for non-appointment notifications. Handles both cold start (`getInitialMessage`) and background (`onMessageOpenedApp`) scenarios.

2. **`setup_f_c_m_foreground_handler.dart`**: Rewrote foreground handler to detect `appointment_confirmed` type, increment notification badge count, and show local notification with a dedicated `appointment_channel_id` channel. Added `onDidReceiveNotificationResponse` callback on initialization for foreground notification tap handling — navigates to `MyBookingPage`. Deduplicates messages via `_handledForegroundMessageIds`.

3. **`app_state.dart`**: Added `incrementNotifCount()` and `resetNotifCount()` helper methods on `FFAppState` for clean notification count management.

### Files Changed
- `lib/backend/push_notifications/push_notifications_handler.dart`
- `lib/custom_code/actions/setup_f_c_m_foreground_handler.dart`
- `lib/app_state.dart`

### Decisions Made During Implementation
- Appointment confirmation notifications use `type: "appointment_confirmed"` as discriminator in FCM data payload
- Background/killed notifications route to `MyBookingPage` for patient to view newly created appointment
- Foreground notifications display via `flutter_local_notifications` with dedicated Android channel (`appointment_channel_id`) to distinguish from marketing notifications
- `coutnnotif` remains a String type (existing pattern) — integer arithmetic done during increment, converted back to String
- Notification payload from data-only FCM messages (no `RemoteNotification`) is handled through `message.data['title']` and `message.data['body']` fallbacks
- Deduplication guards prevent double badge increments on rapid notification delivery

### Known Limitations
- Navigation from foreground notification tap requires `appNavigatorKey.currentContext` to be non-null (app in foreground)
- Badge count does not persist across app restarts (existing behavior, `coutnnotif` is not persisted)
- Deep link appointment_id parsing available in payload but not wired to specific appointment detail views (MyBookingPage shows all appointments)

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [x] Background notification tap — PASS — `_handlePushNotification` detects `type == "appointment_confirmed"`, navigates to `MyBookingPage` via `context.pushNamed`
- [x] Foreground notification — PASS — `setupFCMForegroundHandler` shows local notification with dedicated `appointment_channel_id`, handles `RemoteNotification` and data-only messages
- [x] Badge count update — PASS — Both background (`_incrementNotifBadge`) and foreground (`_incrementNotifBadgeForeground`) parse `coutnnotif` as int, increment, convert back to String. `app_state.dart` also has `incrementNotifCount()` / `resetNotifCount()` helpers
- [x] Firestore historynotif entry — PASS — In-App notification write handled by Laravel side (P5-T07 FirebaseService.writeInAppNotification). Flutter reads via existing `notificationPage` query on `id_patient`
- [x] Deep link navigation — PASS — Background: `MyBookingPage` push; Foreground: `onDidReceiveNotificationResponse` → `_navigateToAppointments` → `MyBookingPage`
- [x] Cold start notification — PASS — `handleOpenedPushNotification` calls `getInitialMessage()` which feeds into same `_handlePushNotification` handler
- [x] Existing notifications preserved — PASS — Prior fallback: `type` check first, non-matching falls through to existing `initialPageName` logic. Foreground uses `default_channel_id` for non-appointment types

### Failure Details
N/A — All criteria passed. Build gate (`flutter analyze`) returned zero errors.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Process 5 Step 8 "Mobile: Patient receives Push + Email + In-App notification Appointment Confirmed" fully met. Push (FCM) handled for background/killed (push_notifications_handler.dart) and foreground (setup_f_c_m_foreground_handler.dart). In-App via existing notificationPage reading Firestore historynotif (written by P5-T07 Laravel). Navigation to MyBookingPage on notification tap.
- v2-ux-spec.md alignment: YES — No new UI introduced; leverages existing notificationPage design and badge system. Design system compliance maintained.

### Rejection Reason
N/A
