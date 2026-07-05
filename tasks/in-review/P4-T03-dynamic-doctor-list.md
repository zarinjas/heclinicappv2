# Replace 17 Hardcoded Doctor Modals with Dynamic Doctor List

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T03 |
| Slug | dynamic-doctor-list |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P4-T01 |
| Blocked Reason | N/A |

---

## Description

Eliminate the 17 hardcoded doctor modal widgets (`lib/component/modal_*/`) by replacing them with a single dynamic doctor list component that fetches doctor data from the Plato API via the Laravel proxy (`GET /facility`). The new component should display all active doctors (filtered by `is_visible_in_app = true` from future CMS data, or all for now) in a horizontal scroll on the Home screen and as a vertical list in a full doctor list screen. Tapping a doctor opens a single dynamic `DoctorDetailSheet` bottom sheet.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Sections 2 (Component Library: Cards, Bottom Sheet), Section 4 (Screen: Home — Doctor Cards, Screen: Doctor Detail)
- `docs/CODEBASE.md` — Section 11 (Plato API — Facility endpoint), Section 19 (Known Issues #13 — 17 hardcoded doctor modals), Section 3 (component/ directory)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul Step 3"
- `lib/backend/api_requests/api_calls.dart` — `GetproviderCall` (GET /facility)
- `lib/component/modal_arif/` through `lib/component/modal_wong/` — 17 existing hardcoded modals to examine for data patterns

---

## Scope

### In Scope
- Build a `DoctorListWidget` component that fetches from `GET /facility` via `GetproviderCall` (already exists in `api_calls.dart`)
- Build a `DoctorCardWidget` component showing: circle avatar (80px), doctor name, specialty — styled per V2 theme card spec
- Build a `DoctorDetailSheet` bottom sheet component showing: doctor photo (100px circle), name, specialty, branch, bio text, and Book Appointment button — per v2-ux-spec.md section 4 "SCREEN: Doctor Detail"
- Display doctor list as horizontal scroll on Home screen (max 6-8 doctors, "See All" link to full list)
- Wire into current `telehealth/` page (or replace it) with a full vertical doctor list
- Support `is_visible_in_app` filtering: filter doctors client-side if the API response includes a visibility field, otherwise show all for now
- Handle loading state: skeleton cards while fetching
- Handle error state: error icon + try again button
- Handle empty state: "No doctors available" message

### Out of Scope
- CMS doctor profile management (Process 9)
- Booking flow integration from Doctor Detail Sheet (that wiring is Process 5)
- Deleting the old `component/modal_*` directories (defer to P4-T06 global cleanup or a future dedup task)
- Branch filtering (future: filter doctors by selected branch)

---

## Technical Spec

### Files to Create or Modify
- `lib/components/doctor_list_widget.dart` — Dynamic doctor list component with horizontal scroll and full list variants
- `lib/components/doctor_card_widget.dart` — Individual doctor card with avatar, name, specialty
- `lib/components/doctor_detail_sheet.dart` — Bottom sheet with doctor full details + Book Appointment CTA
- `lib/telehealth/` — Refactor existing telehealth page to use new `DoctorListWidget`
- `lib/front_page/homepage_new/` — Embed horizontal doctor scroll (or prepare for P4-T04 which will do this)
- `lib/backend/api_requests/api_calls.dart` — Review `GetproviderCall` response parsing, add `is_visible_in_app` field parsing if needed

### API Endpoints
- `GET /facility` — via `PlatomeApiGroup.GetproviderCall.call()` (already exists in `api_calls.dart`)
  - Response contains: provider_id, name, specialty, facilities, etc.
  - Rate-limited: max 20 per request; implement pagination if facility count exceeds 20

### Data / Schema
Doctor data model (from Plato facility endpoint):
| Field | Type | Usage |
|-------|------|-------|
| `id` | String | Doctor unique ID |
| `name` | String | Display name |
| `specialty` | String | Specialty / designation |
| `facilities` | List | Linked branches/facilities |
| `photo_url` | String? | Doctor photo (if available from Plato or CMS) |
| `bio` | String? | Doctor biography (from Plato or CMS) |
| `is_visible_in_app` | bool? | Visibility toggle (CMS field, default true if absent) |

### UI Components
**DoctorCardWidget:**
- Card with V2 card style (surface bg, lg radius, low shadow, border)
- Circle avatar 80px (use doctor photo or initials fallback)
- Doctor name (heading-sm, text-primary)
- Specialty (body-sm, text-secondary)
- Press animation: scale 0.97, 150ms

**DoctorDetailSheet (Bottom Sheet):**
- Handle bar (4px x 36px, divider color, centered)
- Doctor photo 100px circle, centered
- Name (heading-md, centered)
- Specialty (body-md, text-secondary, centered)
- Branch (body-sm, text-secondary, centered)
- About section with heading-sm label
- Bio text (body-md)
- Book Appointment primary button (full width, fixed at bottom)

### Constraints
- Must use `EnvConfig.platomBaseUrl` for all API calls (Laravel proxy)
- Must implement pagination loop if facility list exceeds 20 records
- Bottom sheet must use V2 theme from P4-T01

---

## Acceptance Criteria

- [ ] `DoctorListWidget` fetches doctors from `GET /facility` and renders as a horizontally scrollable list of `DoctorCardWidget` components
- [ ] `DoctorDetailSheet` opens when tapping a doctor card, showing photo, name, specialty, branch, bio, and Book Appointment button
- [ ] The bottom sheet can be dismissed by tapping the backdrop or dragging down
- [ ] All 17 hardcoded doctor modals (`lib/component/modal_*/`) are no longer referenced in the active navigation flow (telehealth page uses dynamic list instead)
- [ ] Doctor list handles loading state with skeleton cards matching doctor card layout
- [ ] Doctor list handles empty state when no doctors are returned from the API
- [ ] Doctor list handles error state with a "Try Again" button that re-fetches
- [ ] Doctor list uses API pagination if facility count exceeds 20 records

---

## Implementation Notes

### What Was Done

- Created `DoctorCardWidget` — supports compact (list) and full (horizontal scroll) layouts with avatar (photo or initials fallback), name, specialty, branch. Uses V2 design tokens for cards (border radius 16px, border, shadow sm).
- Created `DoctorDetailSheet` — bottom sheet modal with handle bar, 100px avatar, doctor info, bio, and Book Appointment button. Dismissible via backdrop or drag-down. Uses static `.show()` method for convenient invocation.
- Created `DoctorListWidget` — fetches doctors from `GET /facility` via `GetproviderCall`, supports horizontal and vertical layouts, loading skeleton (4 placeholder cards), error state (error icon + Try Again button), and empty state (icon + "No doctors available" message). Filters by `is_visible_in_app` client-side.
- Refactored `AllDoctorWidget` (telehealth page) — replaced all 17 hardcoded doctor card blocks with a single `DoctorListWidget(layout: DoctorListLayout.vertical)`. Removed redundant imports (flutter_rating_bar, webviewx_plus, doctor_detail_bottom_sheet). Cleaned up model file to remove 17 rating bar value fields.

### Files Changed

- `lib/components/doctor_card_widget.dart` — NEW
- `lib/components/doctor_detail_sheet.dart` — NEW
- `lib/components/doctor_list_widget.dart` — NEW
- `lib/telehealth/all_doctor/all_doctor_widget.dart` — REWRITE (3434 → 85 lines)
- `lib/telehealth/all_doctor/all_doctor_model.dart` — REWRITE (56 → 16 lines)

### Decisions Made During Implementation

- Doctor photos are not available from Plato /facility (only _id, name, nric, dob, email). Used initials-based avatar fallback. Photo and bio fields will come from CMS data (Process 9).
- Specialty and branch fields are not in current Plato /facility response. Components handle optional fields gracefully — hide sections when data unavailable.
- `is_visible_in_app` filtering is client-side (defaults to true if field absent), preparing for CMS-managed visibility in Process 9.
- Did not delete `lib/component/modal_*/` directories per task scope (deferred to P4-T06 global cleanup).
- Book Appointment button on doctor detail sheet currently pops back; actual booking flow wiring is Process 5 scope.

### Known Limitations

- Doctor list shows only what Plato /facility returns — no bio, photo, or specialty until CMS data is integrated (Process 9).
- Horizontal doctor list on Home screen is prepared but not yet embedded — that is P4-T04 scope.


---

## QA Notes

### Result: PASSED

### Criteria Results
- [x] DoctorListWidget fetches from GET /facility and renders horizontally — PASS — Uses GetproviderCall.call() with PaginationHelper.fetchAllPages(); _buildHorizontalList() produces scrollable DoctorCardWidget list
- [x] DoctorDetailSheet opens on tapping doctor card — PASS — _showDoctorDetail() calls DoctorDetailSheet.show() via showModalBottomSheet with photo/initials, name, specialty, branch, bio, Book Appointment
- [x] Bottom sheet dismissable via backdrop/drag — PASS — showModalBottomSheet defaults enable both
- [x] 17 hardcoded modals no longer referenced — PASS — all_doctor_widget.dart reduced 3434→85 lines; no modal_* imports; no flutter_rating_bar or webviewx_plus
- [x] Loading state skeleton cards — PASS — 4 skeleton cards in both layouts match doctor card shape (avatar circle + text bars)
- [x] Empty state when no doctors — PASS — people_outline icon + "No doctors available" heading + subtitle
- [x] Error state with Try Again — PASS — error icon + "Something went wrong" + error text + Try Again button calls _fetchDoctors()
- [x] API pagination for >20 records — PASS — GetproviderCall uses PaginationHelper.fetchAllPages() which loops current_page until empty

### Failure Details

N/A — All criteria PASS.


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason

