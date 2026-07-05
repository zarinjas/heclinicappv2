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
IN-PROGRESS
