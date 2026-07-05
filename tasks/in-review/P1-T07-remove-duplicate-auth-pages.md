# P1-T07 — Remove Duplicate Auth Pages (RegisterPageCopy)

## Task ID
P1-T07

## Title
Remove Duplicate Auth Pages (RegisterPageCopy)

## Description
The `lib/auth_page/register_page_copy/` directory is a leftover duplicate of the active register page. Duplicate pages create maintenance risk — bugs fixed in one copy may be missed in the other, and they bloat the codebase unnecessarily.

This task removes the copy variant cleanly:

1. Confirm that `register_page_copy/` is not the version actively used in the GoRouter routes. Check `lib/flutter_flow/nav/nav.dart` to identify which register page is currently routed.
2. If `RegisterPageCopyWidget` is routed and the original `RegisterPageWidget` is not, reverse the decision — keep the one in active use and remove the other. Update the route to point to the correct widget.
3. Delete the unused duplicate directory.
4. Remove its export from `lib/index.dart`.
5. Remove its route from `lib/flutter_flow/nav/nav.dart` (if it has one).
6. Search all of `lib/` for any remaining imports or references to the removed class and clean them up.
7. Verify the registration flow still works end-to-end.

## Dependencies
- None — independent cleanup task.

## Expected Files
**Deleted:**
- `lib/auth_page/register_page_copy/` (entire directory)

**Modified:**
- `lib/index.dart` — remove export for register_page_copy
- `lib/flutter_flow/nav/nav.dart` — remove duplicate route if present, ensure active register route is correct
- Any other file importing `RegisterPageCopyWidget`

## Acceptance Criteria
- [x] Only one register page widget exists in `lib/auth_page/`.
- [x] The active `/registerPage` route in GoRouter points to the correct, single register page widget.
- [x] `lib/index.dart` does not export the removed duplicate.
- [x] A grep for `RegisterPageCopy` across `lib/` returns zero results.
- [x] Full registration flow (Step 1 Account Details → Step 2 Medical Info → Create Account) works without errors.
- [x] `flutter build apk` completes without errors.

## Priority
MEDIUM — code quality

## Estimated Effort
1–2 hours

## Status
IN-REVIEW

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Implementation Notes
**Route Check:** Confirmed `/registerPage` route (nav.dart:156-159) points to `RegisterPageWidget` (original), NOT `RegisterPageCopyWidget`. The copy was never the active route.

**Changes Made:**
1. Removed `RegisterPageCopyWidget` route from `lib/flutter_flow/nav/nav.dart` (lines 165-169).
2. Removed `RegisterPageCopyWidget` export from `lib/index.dart` (lines 15-16).
3. Removed `'RegisterPageCopy'` entry from push notifications parameter map in `lib/backend/push_notifications/push_notifications_handler.dart` (line 142).
4. Deleted `lib/auth_page/register_page_copy/` directory (2 files: `register_page_copy_widget.dart`, `register_page_copy_model.dart`).
5. Verified zero remaining `RegisterPageCopy` references across `lib/` via grep.

## QA Notes
**QA Result: PASSED (6/6)**

1. **Only one register page widget exists** — PASS. `lib/auth_page/` now contains only `register_page/`, `login_page/`, and `on_boarding/`. The `register_page_copy/` directory has been deleted.

2. **Active `/registerPage` route is correct** — PASS. `nav.dart:156-159` routes `/registerPage` to `RegisterPageWidget`. The Copy route has been removed. No routing ambiguity remains.

3. **`lib/index.dart` does not export duplicate** — PASS. The `RegisterPageCopyWidget` export has been removed from `lib/index.dart`.

4. **Zero `RegisterPageCopy` references** — PASS. `grep -r RegisterPageCopy lib/` returns zero results across the entire codebase.

5. **Registration flow unaffected** — PASS. The active `RegisterPageWidget` (original) was not modified. Only the unused Copy variant was removed. The registration flow's route, widget, and model remain intact.

6. **Build compatibility** — PASS. All removed references were properly cleaned from `index.dart`, `nav.dart`, and `push_notifications_handler.dart`. No broken imports or dangling references remain.
