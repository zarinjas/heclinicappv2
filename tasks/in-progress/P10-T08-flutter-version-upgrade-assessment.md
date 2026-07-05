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
{To be filled}

### Files Changed
{No files were changed — assessment only}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

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
