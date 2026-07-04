# P1-T03 — Fix minSdkVersion from 35 to 23 in android/app/build.gradle

## Task ID
P1-T03

## Title
Fix minSdkVersion from 35 to 23 in android/app/build.gradle

## Description
The Android build configuration currently sets `minSdkVersion 35`, which means the app cannot be installed on any Android device running below API level 35 (Android 15). This excludes the vast majority of active Android devices in the market — most run between API 26–34.

The fix is a one-line change in `android/app/build.gradle`:
- Change `minSdkVersion 35` to `minSdkVersion 23`

API 23 (Android 6.0 Marshmallow) is the correct minimum baseline because:
- `local_auth` (biometric) requires minimum API 23.
- Firebase, GoRouter, and all other dependencies are compatible with API 23+.
- API 23+ covers >97% of active Android devices globally.

After the change, a clean build must be verified to ensure no dependency requires a higher minimum SDK.

## Dependencies
- None — this task is fully independent.

## Expected Files
- `android/app/build.gradle` — change `minSdkVersion 35` to `minSdkVersion 23`

## Acceptance Criteria
- [ ] `android/app/build.gradle` contains `minSdkVersion 23`.
- [ ] `flutter build apk` completes without errors.
- [ ] `flutter build appbundle` completes without errors.
- [ ] No dependency resolution error citing a minimum SDK version conflict.
- [ ] App installs and launches successfully on an Android API 23 emulator or physical device.
- [ ] App installs and launches successfully on an Android API 33+ emulator or physical device.
- [ ] Biometric login (`local_auth`) functions correctly on the test device.

## Priority
CRITICAL — app cannot be tested on most Android devices without this fix

## Estimated Effort
1 hour

## Assigned To
flutter-developer

## Assigned Date
2026-07-04

## Status
IN-PROGRESS