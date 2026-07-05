# P1-T09 — Remove Duplicate Booking Pages (BookingPagecasse, SelectDatecase, SelectDateReshecedule)

## Task ID
P1-T09

## Title
Remove Duplicate Booking Pages (BookingPagecasse, SelectDatecase, SelectDateReshecedule)

## Description
The `lib/booking_page/` directory contains multiple duplicate and typo-named variants of the booking flow pages:

- `booking_pagecasse/` — duplicate variant of `booking_page/`
- `select_datecase/` — duplicate variant of `select_date/`
- `select_date_reshecedule/` — duplicate with a typo ("reshecedule" instead of "reschedule") and likely incomplete

These duplicates suggest in-progress feature branching that was never cleaned up. They create confusion about which page is canonical and active in the routing.

**Steps:**
1. Audit each duplicate against its counterpart — identify which version is more complete and currently referenced in `nav.dart` routes.
2. For each pair, keep the canonical version (the one actively routed or more complete). Remove the other.
3. If any functionality exists only in a copy variant that is not in the canonical version, migrate that functionality to the canonical file before deleting the copy.
4. Delete all three duplicate directories.
5. Remove their exports from `lib/index.dart`.
6. Remove their routes from `lib/flutter_flow/nav/nav.dart`.
7. Search all of `lib/` for remaining references and clean them up.
8. Verify the booking flow navigates correctly end-to-end.

## Dependencies
- None — independent cleanup task.
- Coordinate with P1-T08 to avoid simultaneous conflicting edits to `nav.dart` and `index.dart`.

## Expected Files
**Deleted:**
- `lib/booking_page/booking_pagecasse/` (entire directory)
- `lib/booking_page/select_datecase/` (entire directory)
- `lib/booking_page/select_date_reshecedule/` (entire directory)

**Modified:**
- `lib/index.dart` — remove exports for all three deleted directories
- `lib/flutter_flow/nav/nav.dart` — remove routes for deleted pages, verify canonical booking routes are intact
- Any other file referencing the removed widget classes

## Acceptance Criteria
- [ ] `booking_pagecasse/`, `select_datecase/`, and `select_date_reshecedule/` directories no longer exist.
- [ ] A grep for `BookingPagecasse`, `SelectDatecase`, `SelectDateReshecedule` across `lib/` returns zero results.
- [ ] `lib/index.dart` does not export any of the removed pages.
- [ ] `lib/flutter_flow/nav/nav.dart` has no routes pointing to the removed widgets.
- [ ] The existing canonical booking page and select date page routes still function.
- [ ] The app navigates from the Booking tab through to the date selection screen without errors.
- [ ] `flutter build apk` completes without errors.

## Priority
MEDIUM — code quality

## Estimated Effort
2–3 hours

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-REVIEW

## Implementation Notes
- Audited all three duplicate directories against canonical counterparts. Found they were actively used in different flows (case-based booking, reschedule).
- **SelectDatecaseWidget → SelectDateWidget**: Added optional `namecase` param. When provided, uses dynamic reason in WhatsApp URL. Near-identical otherwise (2 lines diff).
- **SelectDateResheceduleWidget → SelectDateWidget**: Added `isReschedule` flag. When true: shows "Reschedule Appointment" title, reason text field, and reschedule-specific WhatsApp format.
- **BookingPagecasseWidget → BookingPageWidget**: Added optional `cas` param. When provided: shows AppBar with back button for standalone navigation, passes `namecase=cas` to SelectDateWidget.
- Updated model: SelectDateModel now includes reasonFocusNode and reasonTextController for reschedule flow (only initialized when isReschedule=true).
- Updated nav.dart: removed 3 duplicate routes, updated BookingPageWidget route to accept `cas`, SelectDateWidget route to accept `namecase` and `isReschedule`.
- Updated push_notifications_handler.dart: removed 3 duplicate entries, updated route params for remaining entries.
- Updated all callers: reports_widget (2 refs), visits_widget (1 ref), confirmdialog_alert_widget (1 ref), homepage_new_widget (1 ref).
- Deleted 6 files across 3 directories.
- Verified: grep for BookingPagecasse, SelectDatecase, SelectDateReshecedule across lib/ returns zero results.
- grep for booking_pagecasse, select_datecase, select_date_reshecedule across lib/ returns zero results.
