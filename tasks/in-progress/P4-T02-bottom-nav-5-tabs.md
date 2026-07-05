# Replace Bottom Navigation: 4 Tabs to 5 Tabs

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T02 |
| Slug | bottom-nav-5-tabs |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P4-T01 |
| Blocked Reason | N/A |

---

## Description

Replace the existing 4-tab bottom navigation (Home, BranchLocation, Booking, Profile) with the new 5-tab layout specified in v2-ux-spec.md: Home, Appointments, Health, Notifications, Profile. Update `main.dart` NavBarPage, GoRouter route definitions in `nav.dart`, and create placeholder screen widgets for Health and Notifications tabs if they do not already exist. Wire active/inactive styling using V2 theme colors.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Section 3 (Navigation), specifically Bottom Navigation Bar specs
- `docs/CODEBASE.md` — Section 6 (Routing), Section 3 (Directory Structure)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul" (lines 63-70)
- `lib/main.dart` — Current NavBarPage implementation
- `lib/flutter_flow/nav/nav.dart` — Current GoRouter route definitions

---

## Scope

### In Scope
- Update `main.dart` `NavBarPage` from 4 tabs to 5 tabs: Home, Appointments, Health, Notifications, Profile
- Update GoRouter routes in `nav.dart` — add new routes for Health tab, Notifications tab
- Map existing pages to new tab structure:
  - Tab 0 (Home): `HomepageNewWidget`
  - Tab 1 (Appointments): Reuse `MyBookingPageWidget` / `BookingPageWidget`
  - Tab 2 (Health): New placeholder or reuse `ReportsWidget`
  - Tab 3 (Notifications): Reuse `NotificationPageWidget`
  - Tab 4 (Profile): Reuse `ProfileWidget` (consolidated in P4-T05)
- Apply V2 theme styling: primary (#0F1B3D) nav bar background, accent (#00C9A7) for active tab, white 50% opacity for inactive tabs
- Notification badge on Notifications tab (red dot with unread count from `FFAppState().coutnnotif`)
- Nav bar height: 64px + safe area bottom inset

### Out of Scope
- Redesigning any individual tab screen content (P4-T04 for Home, P4-T05 for Profile, future processes for Health/Appointments)
- Doctor list replacement (P4-T03)
- Global states (P4-T06)
- Changing tab bar behavior beyond the 5-tab layout and styling

---

## Technical Spec

### Files to Create or Modify
- `lib/main.dart` — Update `NavBarPage` widget: 5 tabs, new icons, new labels, V2 styling
- `lib/flutter_flow/nav/nav.dart` — Add GoRouter routes for Health and Notifications screens; update initial tab mapping
- `lib/index.dart` — Export any new placeholder widgets if created

### API Endpoints
N/A

### Data / Schema
- `FFAppState().coutnnotif` (string) — unread notification count for badge

### UI Components
Tab Bar styling per v2-ux-spec.md section 3:

| Property | Value |
|----------|-------|
| Background | `#0F1B3D` (primary) |
| Active icon + label | `#00C9A7` (accent) |
| Inactive icon + label | `rgba(255,255,255,0.5)` |
| Label style | body-sm, 11px |
| Badge | Red dot with unread count on Notifications tab |
| Height | 64px + safe area bottom inset |

Tab icon references:
- Home: `Icons.home` / `Icons.home_outlined`
- Appointments: `Icons.calendar_today` / `Icons.calendar_today_outlined`
- Health: `Icons.favorite` / `Icons.favorite_outline`
- Notifications: `Icons.notifications` / `Icons.notifications_outlined`
- Profile: `Icons.person` / `Icons.person_outline`

### Constraints
- Preserve existing `persistentFooterButtons` behavior and GoRouter integration
- Tab switching must use fade transition (200ms per v2-ux-spec.md section 7)
- Bottom nav must use BottomNavigationBar or equivalent with identical behavior to existing

---

## Acceptance Criteria

- [ ] Bottom navigation bar shows exactly 5 tabs in the correct order: Home, Appointments, Health, Notifications, Profile
- [ ] Each tab icon + label is visible with correct active (accent green) and inactive (white 50%) colors
- [ ] Nav bar background is primary color (#0F1B3D)
- [ ] Tapping each tab navigates to the correct screen without errors
- [ ] Notifications tab shows a red badge when `FFAppState().coutnnotif` is non-zero
- [ ] Health tab displays the Reports screen or a placeholder with "Health" title
- [ ] Appointments tab displays MyBookingPage screen
- [ ] App compiles and runs without crash on tab switch

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {Criterion 1} — PASS / FAIL — {note if fail}
- [ ] {Criterion 2} — PASS / FAIL — {note if fail}
- [ ] {Criterion 3} — PASS / FAIL — {note if fail}

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason

