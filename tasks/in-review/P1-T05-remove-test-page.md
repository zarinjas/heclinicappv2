# P1-T05 — Remove test_page/ from Production Codebase

## Task ID
P1-T05

## Title
Remove test_page/ from Production Codebase

## Description
The directory `lib/front_page/test_page/` exists in the production codebase. Test pages expose internal app structure, may contain debug tooling, and should never ship to users. This task removes it cleanly.

Steps:

1. Delete the entire `lib/front_page/test_page/` directory and all files within it.
2. Remove any export for `test_page` from `lib/index.dart`.
3. Remove any GoRouter route referencing `test_page` from `lib/flutter_flow/nav/nav.dart`.
4. Search for any other references to `test_page` widgets or imports across `lib/` and remove them.
5. Verify the app still compiles and runs after removal.

## Dependencies
- None — fully independent task.

## Expected Files
**Deleted:**
- `lib/front_page/test_page/` (entire directory)

**Modified:**
- `lib/index.dart` — remove test_page export
- `lib/flutter_flow/nav/nav.dart` — remove test_page route (if present)
- Any file importing or referencing `TestPageWidget` or similar

## Acceptance Criteria
- [ ] `lib/front_page/test_page/` directory no longer exists.
- [ ] No import or reference to any class from `test_page` remains in the codebase.
- [ ] `lib/index.dart` does not export anything from `test_page`.
- [ ] `lib/flutter_flow/nav/nav.dart` has no route pointing to a test page widget.
- [ ] `flutter build apk` completes without errors after removal.
- [ ] App launches and navigates normally — no broken routes.
- [ ] A grep for `test_page` across `lib/` returns zero results.

## Priority
MEDIUM — code quality and attack surface reduction

## Estimated Effort
1 hour

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Implementation Notes
**Changes made:**
1. Deleted `lib/front_page/test_page/` directory (2 files: `test_page_model.dart`, `test_page_widget.dart`).
2. Removed `test_page` export from `lib/index.dart` (line 3).
3. Removed `TestPageWidget` GoRouter route from `lib/flutter_flow/nav/nav.dart` (lines 102-106).
4. Removed `'testPage'` entry from push notification parameter builder map in `lib/backend/push_notifications/push_notifications_handler.dart` (line 123).
5. Verified grep for `test_page|TestPage|testPage` across `lib/` returns zero results.
6. `flutter build apk` not verified — Flutter SDK unavailable in CI environment. No compilation expected to fail since all imports along with the test_page sources were cleanly removed.

## Status
IN-REVIEW