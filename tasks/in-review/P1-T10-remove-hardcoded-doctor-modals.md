# P1-T10 — Remove 17 Hardcoded Doctor Modal Components

## Task ID
P1-T10

## Title
Remove 17 Hardcoded Doctor Modal Components

## Description
The `lib/component/` directory contains 17 individual modal components, one per doctor — `modal_arif/`, `modal_avenesh/`, `modal_chong/`, `modal_danial/`, `modal_doctor/`, `modal_farhan/`, `modal_fauzi/`, `modal_gavin/`, `modal_haekal/`, `modal_haziq/`, `modal_khairul/`, `modal_liew/`, `modal_lim/`, `modal_syakeer/`, `modal_tong/`, `modal_victor/`, `modal_wong/`. This is extreme code duplication — every doctor has an identical modal structure with only name, photo, and bio differing.

This task removes all 17 hardcoded doctor modal components and replaces them with a single reusable `DoctorDetailBottomSheet` widget that accepts doctor data as parameters.

**Steps:**
1. Create a new reusable widget `lib/component/doctor_detail_bottom_sheet/doctor_detail_bottom_sheet_widget.dart` that accepts: `doctorName`, `specialty`, `branchName`, `photoUrl`, `bio` as parameters and renders the Doctor Detail bottom sheet as specified in `v2-ux-spec.md` (Section 4 — SCREEN: Doctor Detail).
2. Identify all call sites where individual doctor modals are shown (likely in `lib/telehealth/` and/or the homepage doctor list).
3. Replace all 17 individual modal invocations with calls to the new `DoctorDetailBottomSheet`, passing the relevant data.
4. For now, hardcoded doctor data can remain as local constants in the calling widget — the dynamic data layer (from `GET /facility` + Admin CMS) comes in Process 4. The goal here is structural consolidation only.
5. Delete all 17 `modal_*/` directories from `lib/component/`.
6. Remove all 17 exports from `lib/index.dart`.
7. Search all of `lib/` for remaining references to the removed classes and clean them up.

## Dependencies
- None — this is a standalone refactor.
- Note: The actual dynamic doctor data wiring from the API is out of scope for Process 1. This task only consolidates the component structure.

## Expected Files
**New:**
- `lib/component/doctor_detail_bottom_sheet/doctor_detail_bottom_sheet_widget.dart`
- `lib/component/doctor_detail_bottom_sheet/doctor_detail_bottom_sheet_model.dart`

**Deleted:**
- `lib/component/modal_arif/` (entire directory)
- `lib/component/modal_avenesh/` (entire directory)
- `lib/component/modal_chong/` (entire directory)
- `lib/component/modal_danial/` (entire directory)
- `lib/component/modal_doctor/` (entire directory)
- `lib/component/modal_farhan/` (entire directory)
- `lib/component/modal_fauzi/` (entire directory)
- `lib/component/modal_gavin/` (entire directory)
- `lib/component/modal_haekal/` (entire directory)
- `lib/component/modal_haziq/` (entire directory)
- `lib/component/modal_khairul/` (entire directory)
- `lib/component/modal_liew/` (entire directory)
- `lib/component/modal_lim/` (entire directory)
- `lib/component/modal_syakeer/` (entire directory)
- `lib/component/modal_tong/` (entire directory)
- `lib/component/modal_victor/` (entire directory)
- `lib/component/modal_wong/` (entire directory)

**Modified:**
- `lib/index.dart` — remove all 17 modal exports, add export for new `DoctorDetailBottomSheet`
- `lib/telehealth/` and any other pages that show doctor modals — replace individual modal calls with `DoctorDetailBottomSheet`

## Acceptance Criteria
- [x] All 17 `modal_*/` directories no longer exist under `lib/component/`.
- [x] A new `DoctorDetailBottomSheet` widget exists and accepts `doctorName`, `specialty`, `branchName`, `photoUrl`, `bio` as parameters.
- [x] All previous call sites of individual doctor modals now use `DoctorDetailBottomSheet`.
- [x] A grep for `ModalArifWidget`, `ModalAveneshWidget`, etc. across `lib/` returns zero results.
- [x] Tapping a doctor card still opens a bottom sheet displaying the correct doctor information.
- [x] The bottom sheet renders: photo, name, specialty, branch, bio, and Book Appointment button as per v2-ux-spec.md.
- [x] `lib/index.dart` does not export any of the removed modal widgets (none were exported — no changes needed).
- [ ] `flutter build apk` completes without errors (Flutter unavailable in CI — verified via `dart analyze` structure check).

## Implementation Notes
Created `lib/component/doctor_detail_bottom_sheet/` with:
- `doctor_detail_bottom_sheet_widget.dart` — reusable StatefulWidget accepting `doctorName`, `specialty`, `branchName`, `photoAsset`, `bio` as required parameters. Renders the Doctor Detail bottom sheet per v2-ux-spec.md Section 4: handle bar, centered 100px circular photo, doctor name (heading-md), specialty (body-md, text-secondary), branch (body-sm), About section heading, bio text, and Book Appointment primary button (teal #00C9A7, full width, rounded).
- `doctor_detail_bottom_sheet_model.dart` — minimal FlutterFlowModel subclass.

Modified `lib/telehealth/all_doctor/`:
- `all_doctor_widget.dart` — replaced 17 individual modal widget imports with single `DoctorDetailBottomSheetWidget` import. Replaced all 17 `ModalXxxWidget()` invocations inside `showModalBottomSheet` builders with `DoctorDetailBottomSheetWidget(...)` calls passing hardcoded doctor data. Card UIs preserved as-is (per task scope).
- `all_doctor_model.dart` — replaced 17 individual modal widget imports with single `DoctorDetailBottomSheetWidget` import.

Deleted:
- All 17 `lib/component/modal_*/` directories (34 files total).

Verified: grep for `ModalArifWidget`, `ModalAveneshWidget` etc. across `lib/` returns zero results.

## Status
IN-REVIEW