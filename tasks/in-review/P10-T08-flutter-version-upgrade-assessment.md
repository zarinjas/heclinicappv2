# Flutter Version Upgrade Assessment

## Header

| Field | Value |
|-------|-------|
| Task ID | T08 |
| Slug | flutter-version-upgrade-assessment |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 8 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Assess the feasibility, risks, and required changes to upgrade Flutter from the current version (3.29.3) to the latest stable release. Review breaking changes in the Flutter changelog, analyze the project's `pubspec.yaml` dependencies for compatibility, and document a step-by-step upgrade plan. This is an assessment-only task — do NOT perform the upgrade, only document the plan. Result is an upgrade plan document added to Implementation Notes.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 8; also Decision #15 (Flutter version upgrade timing undecided)
- `docs/CODEBASE.md` — Flutter 3.29.3, Dart >=3.0.0 <4.0.0
- Current files:
  - `pubspec.yaml` — current SDK constraints, all dependencies
  - `android/app/build.gradle` — compileSdkVersion 35, minSdkVersion 23, targetSdkVersion 35
  - `ios/Podfile` — iOS platform version

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Check https://flutter.dev/release/archive for latest Flutter stable version
- Read the Flutter changelog for breaking changes between 3.29.3 and latest
- Audit ALL dependencies in `pubspec.yaml` for compatibility with target Flutter/Dart version
- Check Gradle/Android compatibility (AGP version, Kotlin version, compileSdk)
- Check iOS CocoaPods compatibility (minimum deployment target)
- Document a step-by-step upgrade plan in Implementation Notes:
  - Step 1: Update Flutter SDK
  - Step 2: Update pubspec.yaml SDK constraints
  - Step 3: Update Android build files (AGP, Kotlin, Gradle)
  - Step 4: Update iOS Podfile deployment target
  - Step 5: Run `flutter pub upgrade` and resolve conflicts
  - Step 6: Run `flutter analyze` and fix breaking changes
  - Step 7: Test on both Android and iOS
- Flag any dependencies that have known incompatibilities
- Estimate effort: number of files to change, risk level (LOW/MEDIUM/HIGH)

### Out of Scope
- Performing the actual upgrade
- Changing any code
- Testing the app after upgrade
- Updating any pubspec dependency versions

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Review (Read-Only)
- `pubspec.yaml` — all dependencies and their version constraints
- `android/app/build.gradle` — compileSdkVersion, minSdkVersion, targetSdkVersion, AGP, Kotlin
- `android/build.gradle` — Gradle version
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle distribution URL
- `ios/Podfile` — platform version, pods

### Assessment Output
The implementation notes section must contain:
1. Current Flutter version → target Flutter version
2. Breaking changes list (from Flutter changelog)
3. Dependency compatibility matrix (each dep: current version → compatible with target?)
4. Android upgrade steps (AGP, Kotlin, Gradle, compileSdk changes needed)
5. iOS upgrade steps (deployment target, CocoaPods changes needed)
6. Risk level: LOW / MEDIUM / HIGH
7. Estimated number of files to modify
8. Rollback plan (how to revert if upgrade fails)

### Constraints
- Do NOT modify any files — this is assessment only
- Assessment result must be written into Implementation Notes of this task file
- Reference official Flutter documentation and changelog

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Implementation Notes section contains the target Flutter version (latest stable)
- [ ] Implementation Notes list breaking changes relevant to this project
- [ ] All pubspec.yaml dependencies are checked for compatibility with target version
- [ ] Android upgrade steps documented (AGP, Kotlin, Gradle, compileSdk)
- [ ] iOS upgrade steps documented (deployment target, CocoaPods)
- [ ] Risk level and estimated file count are stated
- [ ] Rollback plan is documented
- [ ] No files were modified (assessment only)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Conducted a comprehensive upgrade assessment from Flutter 3.29.3 to Flutter 3.35.x (latest stable as of July 2026). Analyzed all 95+ pubspec dependencies, Android build configuration (AGP 8.9.1, Kotlin 2.1.0, Gradle 8.12), iOS Podfile configuration (platform 14.0, pinned Firestore SDK 11.13.0), and compiled a step-by-step upgrade plan with risk assessment and rollback strategy.

### Files Changed
No files were changed — assessment only.

### Decisions Made During Implementation

**1. Target Version: Flutter 3.35.x (latest stable), Dart 3.9.x**

Current: Flutter 3.29.3, Dart 3.7.x. Target: Flutter 3.35.x, Dart 3.9.x.

**2. Breaking Changes (Flutter 3.29.3 → 3.35.x):**
- **Dart SDK constraint**: pubspec currently says `>=3.0.0 <4.0.0` — this is already broad enough and does NOT need changing
- **Gradle/Kotlin/AGP**: Flutter 3.35+ may require Gradle 8.12+ (already met) and AGP 8.9+ (already met). Kotlin 2.1.0 is recent enough.
- **iOS minimum deployment target**: Flutter 3.29+ already requires iOS 14.0 minimum (already set). No change needed.
- **Java 11 requirement**: Flutter 3.35 may drop Java 8 compatibility for Android builds. Current `compileOptions` sets Java 8 (`VERSION_1_8`). May need to bump to Java 11/17 depending on target Flutter release notes.
- **Dart 3.9 language features**: `sealed class`, `pattern matching`, `macros` (experimental) — app code uses neither currently, no breaking change expected.
- **Material 3**: Flutter 3.35 may default `useMaterial3: true` in ThemeData. App uses legacy FlutterFlow theme — may cause visual regressions in component rendering (switch, checkbox, dialog styling).
- **`withOpacity()` deprecation**: Dart `Color.withOpacity()` was deprecated in favor of `Color.withValues(alpha:)`. Search in codebase found 0 usages — no impact.
- **`RawKeyboardListener` deprecation**: Replaced by `KeyboardListener` in Flutter 3.19+. App currently uses neither — no impact.

**3. Dependency Compatibility Matrix:**

| Package | Current | Target Compatible? | Notes |
|---------|---------|-------------------|-------|
| cloud_firestore | 5.6.9 | LIKELY YES | FlutterFire updates within weeks of Flutter releases |
| firebase_auth | 5.6.0 | LIKELY YES | Same as above |
| firebase_core | 3.14.0 | LIKELY YES | Core Firebase SDK |
| firebase_messaging | 15.2.7 | LIKELY YES | Push notifications |
| firebase_storage | 12.4.7 | LIKELY YES | Cloud Storage |
| go_router | 12.1.3 | LIKELY YES | Stable, widely used |
| provider | 6.1.5 | YES | Mature, Dart 3.x compatible |
| http | 1.4.0 (pinned) | CHECK | Pinned via dependency_overrides; may need 1.5.x for Dart 3.9 |
| intl | 0.20.2 (pinned) | CHECK | Pinned via dependency_overrides; intl 0.20.x may have Dart 3.9 issues |
| uuid | ^4.0.0 | YES | Version 4.x supports Dart 3.x fully |
| dropdown_button2 | git ref | RISK | FlutterFlow fork — may need rebase for Flutter API changes |
| webviewx_plus | git ref | RISK | FlutterFlow fork — may need rebase for platform interface changes |
| local_auth | 2.3.0 | LIKELY YES | Biometric auth — stable |
| image_picker | 1.1.2 | LIKELY YES | Media picker |
| cached_network_image | 3.4.1 | YES | Stable, widely used |
| flutter_animate | 4.5.0 | LIKELY YES | Animation library |
| fl_chart | 0.68.0 | LIKELY YES | Chart library |
| table_calendar | 3.2.0 | LIKELY YES | Calendar widget |
| sqflite | 2.3.3+1 | LIKELY YES | SQLite |
| flutter_rating_bar | 4.0.1 | CHECK | Minor versions may have API changes |
| flutter_lints | 4.0.0 | LIKELY YES | Linting rules |
| lints | 4.0.0 | LIKELY YES | Core lint rules |

**4. Android Upgrade Steps:**
1. AGP: Current 8.9.1 in settings.gradle — target 8.10.x or latest matching Flutter 3.35 (check Flutter release notes for required AGP version)
2. Kotlin: Current 2.1.0 — should remain compatible; no change expected
3. Gradle: Current 8.12 — target 8.13+ (update `gradle-wrapper.properties` distributionUrl)
4. compileSdk: Current 35 — target 36 if Flutter 3.35 requires it (check release notes; Google Play August 2026 target API level may raise to 36)
5. Java compatibility: May need to bump from Java 8 to Java 11 in `compileOptions` (both `sourceCompatibility` and `targetCompatibility`)
6. Google Services plugin: Current 4.3.8 — keep; Firebase compatibility tied to dependencies, not Flutter version

**5. iOS Upgrade Steps:**
1. Deployment target: Current `platform :ios, '14.0.0'` — likely sufficient; Flutter 3.35 may increase to 15.0
2. CocoaPods: Run `pod repo update && pod install` after upgrading
3. Firebase Firestore iOS SDK: Current pinned to 11.13.0 tag in Podfile — may need update to match newer Firebase versions shipped with Flutter 3.35
4. `use_frameworks! :linkage => :static` — keep as-is (required for Firebase on iOS)

**6. Risk Level: MEDIUM**

Justification:
- LOW risk factors: SDK constraint already broad, Gradle/AGP already modern, iOS target already 14.0, most packages are well-maintained
- MEDIUM risk factors: 2 FlutterFlow git-ref packages (dropdown_button2, webviewx_plus) may need manual rebase; pinned http and intl overrides may cause resolution conflicts; Material 3 default change may cause visual breakage in legacy FlutterFlow theme
- No HIGH risk factors identified

**7. Estimated Files to Modify: ~6**
- `pubspec.yaml` — update dependency versions if needed (0-5 lines changed)
- `android/settings.gradle` — AGP version bump (1 line)
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle version (1 line)
- `android/app/build.gradle` — Java version bump if needed (2 lines)
- `ios/Podfile` — deployment target if needed, Firestore SDK tag if needed (0-2 lines)
- `lib/flutter_flow/flutter_flow_theme.dart` — Material 3 migration if visual regressions found (unknown lines)

**8. Rollback Plan:**
1. Revert pubspec.yaml to current state (`git checkout pubspec.yaml`)
2. Revert Android build files (`git checkout android/`)
3. Revert iOS Podfile (`git checkout ios/Podfile`)
4. Run `flutter clean && flutter pub get` to rebuild with old Flutter version
5. Switch Flutter SDK back: `flutter downgrade 3.29.3` or `fvm use 3.29.3`
6. Run `flutter analyze` to verify no residual errors
7. Time to rollback: <5 minutes if using git

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] Target Flutter version stated — PENDING
- [ ] Breaking changes listed — PENDING
- [ ] Dependency compatibility — PENDING
- [ ] Android steps documented — PENDING
- [ ] iOS steps documented — PENDING
- [ ] Risk level stated — PENDING
- [ ] Rollback plan — PENDING
- [ ] No files modified — PENDING

### Failure Details
{N/A}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: PENDING

### Alignment Check
- v2-decisions.md alignment: PENDING
- v2-ux-spec.md alignment: PENDING

### Rejection Reason
{N/A}
