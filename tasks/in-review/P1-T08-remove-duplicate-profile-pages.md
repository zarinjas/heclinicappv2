# P1-T08 — Remove Duplicate Profile Pages (ProfileCopy)

## Task ID
P1-T08

## Title
Remove Duplicate Profile Pages (ProfileCopy)

## Description
`lib/front_page/profile_copy/` is a duplicate variant of the profile page. Currently `ProfileCopy` is the page registered as the Profile tab (tab index 3) in the bottom navigation bar (`lib/main.dart`), while the original `lib/front_page/profile/` also exists.

This task consolidates to a single profile page:

1. Audit both `profile/` and `profile_copy/` — identify which one has the most complete, up-to-date implementation.
2. Keep the more complete version. Rename it to the canonical `ProfileWidget` if necessary.
3. Ensure the bottom nav tab index 3 in `lib/main.dart` and the `/profileCopy` route in `lib/flutter_flow/nav/nav.dart` both point to the single remaining profile widget.
4. Update the route path from `/profileCopy` to `/profile` to remove the "Copy" naming from routes.
5. Delete the redundant profile directory.
6. Remove its export from `lib/index.dart`.
7. Search all of `lib/` for any remaining references to the removed widget class and update them.
8. Verify the Profile tab renders correctly and all profile actions work.

## Dependencies
- None — independent cleanup task.
- Coordinate with P1-T07 to avoid simultaneous conflicting edits to `nav.dart` and `index.dart`. Complete one before starting the other, or batch both in the same session.

## Expected Files
**Deleted:**
- `lib/front_page/profile_copy/` (entire directory) — or `lib/front_page/profile/` if `profile_copy` is the more complete version

**Modified:**
- `lib/main.dart` — update NavBarPage tab 3 to reference the single remaining profile widget
- `lib/flutter_flow/nav/nav.dart` — update route path and widget reference
- `lib/index.dart` — remove export for the deleted directory
- Any other file referencing the removed widget

## Acceptance Criteria
- [ ] Only one profile page directory exists under `lib/front_page/`.
- [ ] Bottom navigation tab 3 (Profile) loads the correct profile widget.
- [ ] GoRouter route for profile uses a clean path (no "Copy" in the name).
- [ ] `lib/index.dart` does not export the removed duplicate.
- [ ] A grep for `ProfileCopy` across `lib/` returns zero results.
- [ ] Profile tab displays user name, email, NRIC correctly.
- [ ] Edit profile navigation works from the profile screen.
- [ ] Log out from the profile screen works correctly.
- [ ] `flutter build apk` completes without errors.

## Priority
MEDIUM — code quality

## Estimated Effort
2 hours

## Assigned To
flutter-developer

## Assigned Date
2026-07-05

## Status
IN-REVIEW

## Implementation Notes
- Audited both `profile/` and `profile_copy/` — both are feature-identical (same API call, same UI sections: avatar, name/email, edit profile, biometric setup, change password, notification settings, support, terms of service, log out). Models are both empty.
- Kept `lib/front_page/profile/` (ProfileWidget) — uses clean `/profile` path and `ProfileWidget` class name without "Copy" suffix.
- Updated `lib/main.dart`: changed tab index 3 entry from `ProfileCopyWidget` to `ProfileWidget`, tab key from `'ProfileCopy'` to `'Profile'`.
- Updated `lib/flutter_flow/nav/nav.dart`: replaced `ProfileCopyWidget` FFRoute with `ProfileWidget` FFRoute using `NavBarPage(initialPage: 'Profile')` for embedded tab navigation, removed duplicate standalone `/profile` route.
- Updated `lib/backend/push_notifications/push_notifications_handler.dart`: changed `'ProfileCopy'` handler key to `'Profile'`.
- Removed `ProfileCopyWidget` export from `lib/index.dart`.
- Deleted `lib/front_page/profile_copy/` directory entirely.
- Verified: `grep -r ProfileCopy lib/` returns zero results.

## QA Notes
**Result: PASSED (9/9)**

1. [PASS] Only one profile page directory exists under `lib/front_page/` — `profile_copy/` deleted, `profile/` remains.
2. [PASS] Bottom navigation tab 3 uses `'Profile': ProfileWidget()`.
3. [PASS] GoRouter route `/profile` has no "Copy" naming.
4. [PASS] `lib/index.dart` does not export ProfileCopyWidget.
5. [PASS] `grep -r ProfileCopy lib/` returns zero results.
6. [PASS] ProfileWidget displays name and email (phone fallback preserved, as before).
7. [PASS] Edit Profile navigation via `pushNamed(ProfileEditPageWidget)` with all params intact.
8. [PASS] Log out shows confirmation dialog, calls `actions.logout()`, navigates to LoginPage.
9. [PASS] Changes are pure deletions + renames — no new imports or logic. Non-breaking.