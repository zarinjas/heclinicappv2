# In-App Notifications — Deep Link Support

## Header

| Field | Value |
|-------|-------|
| Task ID | P8-T06 |
| Slug | inapp-deep-links |
| Process | 8 — Notifications Module |
| Process Step | Step 6 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P8-T04 |
| Blocked Reason | N/A |

---

## Description

Implement in-app notification writes to Firestore `historynotif` collection with proper deep link support. Verify that the Flutter app's existing notification handler correctly navigates to deep-linked screens. In-app notifications must match what Push and Email deliver, but persist in Firestore for the in-app notification center.

Per `docs/v2-decisions.md` Step 6 of Process 8.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 8 Step 6 (line 108), Notification Strategy (lines 341-366)
- `laravel/app/Services/FirebaseService.php` — `writeInAppNotification()` method writes to Firestore `historynotif` collection
- `laravel/app/Services/NotificationService.php` — `sendInApp()` calls FirebaseService
- `firebase/functions/index.js` — Cloud Function push payload includes `initialPageName` and `parameterData` for deep links
- `lib/backend/schema/historynotif_record.dart` — Flutter Firestore record model for `historynotif` collection
- `lib/backend/push_notifications/push_notifications_handler.dart` — Handles push notification routing with 27 parameter builder mappings
- `lib/front_page/notification_page/notification_page_widget.dart` — Flutter notification center widget (streams from historynotif)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Ensure `FirebaseService::writeInAppNotification()` writes documents to Firestore `historynotif` with:
  - `title`, `body` — notification content
  - `timestamp` — Firestore server timestamp
  - `read` — false (boolean, not string "no") **FIX**: Change existing string usage to boolean
  - `deep_link` — screen route + parameters (e.g. `'appointments'`, `'health/records'`)
  - `type` — notification type (e.g. `'appointment_confirmed'`, `'manual'`, `'document_uploaded'`, `'appointment_reminder'`)
  - `id_patient` — the patient's Plato ID (from FFAppState or resolved from appointment)
- Update `NotificationService::sendInApp()` to accept and pass deep_link and type parameters
- Verify Flutter `notification_page_widget.dart` handles deep link tap: mark as read + navigate to deep-linked screen
- Verify Flutter push handler `push_notifications_handler.dart` correctly maps `initialPageName` + `parameterData` for deep links from both push and in-app notifications
- **FIX**: Change the `read` field in `historynotif_record.dart` from String (`"yes"`/`"no"`) to Boolean for new documents; maintain backward compatibility

### Out of Scope
- Changing the Flutter notification center UI (P8-T09 / future Process 10 polish)
- Notification dropdown component fixes (future Process 10)
- Firestore security rules update (Process 10 Step 6)
- Push notification payload changes (deep link already supported via `initialPageName` + `parameterData`)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Services/FirebaseService.php` — UPDATE: `writeInAppNotification()` to include `deep_link`, `type`, `id_patient` fields; change `read` to boolean `false`
- `laravel/app/Services/NotificationService.php` — UPDATE: `sendInApp()` to accept `$deepLink` and `$type` parameters
- `lib/backend/schema/historynotif_record.dart` — UPDATE: `read` field from String to bool (with migration helper for old String data); add `deep_link` and `type` fields
- `lib/front_page/notification_page/notification_page_widget.dart` — VERIFY/UPDATE: tap handler to parse `deep_link` and navigate accordingly
- `laravel/app/Services/AppointmentService.php` — possibly: trigger in-app notification on appointment creation

### Data / Schema
Firestore `historynotif` document (target structure):
```
{
  "id_patient": "PlatoPatientId123",
  "title": "Appointment Confirmed",
  "body": "Your appointment with Dr. X on 2026-07-10 at 10:00 AM is confirmed.",
  "timestamp": <server_timestamp>,
  "read": false,              // BOOLEAN (was String "no")
  "deep_link": "appointments",
  "type": "appointment_confirmed",
  "appointment": "PlatoApptId456"  // optional, existing field
}
```

### Firestore Write (Laravel Side)
```php
// In FirebaseService::writeInAppNotification()
$data = [
    'id_patient' => $params['id_patient'] ?? null,
    'title' => $params['title'],
    'body' => $params['body'],
    'timestamp' => ['server_timestamp' => true],
    'read' => false,  // boolean
    'deep_link' => $params['deep_link'] ?? null,
    'type' => $params['type'] ?? 'general',
];
```

### Deep Link Routes (Flutter)
Existing handler mappings in `push_notifications_handler.dart` around line 27 (parameter builder) should be reused for in-app notification tap:
- `'appointments'` → `MyBookingPage`
- `'health/records'` → `ReportsWidget` with tab=0
- `'health/vitals'` → `ReportsWidget` with tab=1
- `'health/documents'` → `ReportsWidget` with tab=2
- `'profile'` → `MyProfilePage`

### Constraints
- Firestore writes from Laravel use REST API (not Admin SDK) — use `FirebaseService::writeToFirestore()` existing method
- Must handle backward compatibility: old `read` = `"yes"`/`"no"` Strings should still be treated as read/unread in Flutter UI
- In-app notification `id_patient` must match `FFAppState().idplato` for proper filtering in Flutter query

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] `writeInAppNotification()` writes to Firestore `historynotif` with `read: false` (boolean), `deep_link`, `type`, and `id_patient` fields
- [ ] An in-app notification written with `deep_link: "appointments"` appears in the Flutter notification center
- [ ] Tapping an in-app notification with `deep_link: "appointments"` navigates to the Appointments tab/screen
- [ ] Tapping an in-app notification marks it as read (boolean `true`)
- [ ] Old notifications with `read: "yes"` (string) still display correctly as read (backward compatibility)
- [ ] An in-app notification written with `type: "appointment_confirmed"` displays correctly in the notification list
- [ ] In-app notification `id_patient` matches the intended patient and does NOT appear for other patients

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done

1. **FirebaseService::writeInAppNotification()** — Added `id_patient` field to the payload, sourced from the `$data` array. All other fields (`title`, `body`, `read: false` (boolean), `deep_link`, `type`, `timestamp`) were already present.
2. **NotificationService::sendInApp()** — Updated signature to accept `$deepLink` and `$type` parameters (with sensible defaults). Now passes `id_patient` from the Appointment model.
3. **Appointment model** — Added `patient_plato_id` to `$fillable` so it can be stored when known.
4. **historynotif_record.dart** — Added `title`, `body`, `deepLink`, `type` fields. Changed `read` field from `String?` to `dynamic` with a `readBool` getter that handles both `bool` (new) and `String` "yes"/"no" (old) formats. The `read` string getter is preserved for backward compatibility via `readBool`. Updated `createHistorynotifRecordData` to accept `bool? readBool` alongside `String? read`. Updated `equals`/`hash` methods.
5. **notification_page_widget.dart** — Updated tap handler:
   - Writes `readBool: true` (boolean) instead of `read: '"yes"'` (string) when marking as read.
   - Added deep link navigation: parses `deepLink` field and routes to `MyBookingPage` (appointments), `Reports` (health/*), or `HomepageNew` (profile).
   - Fallback to old message/tittle-based logic when `deepLink` is empty (backward compatible).

### Files Changed

- `laravel/app/Services/FirebaseService.php` — added `id_patient` to payload
- `laravel/app/Services/NotificationService.php` — updated `sendInApp` signature + id_patient
- `laravel/app/Models/Appointment.php` — added `patient_plato_id` to fillable
- `lib/backend/schema/historynotif_record.dart` — new fields, read backward compat
- `lib/front_page/notification_page/notification_page_widget.dart` — deep link nav + boolean read

### Decisions Made During Implementation

- **Timestamp format**: Kept `now()->timestamp` (integer) instead of server timestamp sentinel. The existing `toFirestoreValue()` method does not handle the Firestore server timestamp sentinel format, and adding such support would require changes to the shared serializer.
- **Backward compatibility**: The `read` field uses a `dynamic` type internally and exposes both `readBool` (bool) and `read` (String) getters. Old documents with `read: "yes"`/`"no"` strings continue to work.
- **`id_patient` resolution**: Added `patient_plato_id` to the Appointment model fillable. When not set on the appointment, `id_patient` will be `null` in the Firestore document. The Flutter query filters by `id_patient = FFAppState().idplato`, so documents without `id_patient` will not appear in the mobile app notification center (but can be queried in the admin panel).

### Known Limitations

- Notifications without `id_patient` set will not appear in the Flutter notification center (filtered out by query).
- The `tittle` typo field from old documents is preserved for backward compat; preferred field is `title`. New documents write `title`.
- `health/*` deep links all route to `ReportsWidget` without differentiating the tab index (tab selection is a future enhancement in Process 10).

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results

1. `writeInAppNotification()` writes `read: false` (boolean), `deep_link`, `type`, `id_patient` → **PASS** (FirebaseService.php:127-131 — all fields present, `read` is `false` bool, `deep_link` and `type` have defaults, `id_patient` accepted from data array)
2. In-app notification with `deep_link: "appointments"` appears in Flutter notification center → **PASS** (historynotif stream includes all records matching id_patient; deep_link is a data field, not a filter)
3. Tapping notification with `deep_link: "appointments"` navigates to Appointments → **PASS** (notification_page_widget.dart:157-158 — `case 'appointments': context.pushNamed('MyBookingPage')`)
4. Tapping marks notification as read (boolean `true`) → **PASS** (notification_page_widget.dart:149 — `readBool: true` in Firestore update)
5. Old notifications with `read: "yes"` (string) display as read → **PASS** (readBool getter returns true for String "yes"; read getter returns "yes"; UI shows read when `read != 'no'`)
6. Notification with `type: "appointment_confirmed"` displays in list → **PASS** (type field stored in record model; list displays all matching patient records regardless of type)
7. `id_patient` matches intended patient, doesn't appear for others → **PASS** (query filters `id_patient == FFAppState().idplato`)

### Build Gate
- Flutter analyze: 0 errors (BUILD GATE PASS)

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason
