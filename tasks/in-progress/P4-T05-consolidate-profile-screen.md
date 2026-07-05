# Consolidate Profile Screen

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T05 |
| Slug | consolidate-profile-screen |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P4-T01, P4-T02 |
| Blocked Reason | N/A |

---

## Description

Consolidate the Profile screen by removing the `ProfileCopy` duplicate page and redesigning the primary `ProfileWidget` to match the V2 spec. The new Profile screen shows: avatar, full name, email, NRIC; sections for My Details (edit arrow), Settings (Biometric Login toggle, Notification Preferences, Change Password), About (He Clinic Info, Privacy Policy, Terms of Service), and a Log Out destructive button. The existing `ProfileCopy` route in `nav.dart` must be redirected to the consolidated Profile page.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Section 4 "SCREEN: Profile Tab" (lines 621-641), "SCREEN: Profile Edit" (lines 644-650)
- `docs/CODEBASE.md` — Section 4 (App State — user data fields), Section 6 (Routing — Profile, ProfileCopy, ProfileEditPage routes), Section 19 (Known Issues — Copy pages)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul Step 5"
- `lib/front_page/profile/` — Existing Profile page
- `lib/front_page/profile_copy/` — Duplicate Profile page to be removed
- `lib/flutter_flow/nav/nav.dart` — Route definitions for /profile and /profileCopy

---

## Scope

### In Scope
- Redesign `ProfileWidget` (`lib/front_page/profile/`) to the V2 layout:
  - **Header**: Avatar (80px circle), Full Name (`FFAppState().name`), Email (`FFAppState().userEmail`), NRIC (`FFAppState().nationalman`)
  - **My Details section**: Tappable row with "My Details" label and edit arrow icon → navigates to `ProfileEditPage`
  - **Settings section**:
    - Biometric Login row with toggle switch (reads `FFAppState().fingerprint` / `FFAppState().faceid`)
    - Notification Preferences row with arrow → navigates to notification settings
    - Change Password row with arrow → navigates to `changePassword` route
  - **About section**:
    - He Clinic Info row with arrow → navigates to `hemedInfo` route
    - Privacy Policy row with arrow → opens external link or page
    - Terms of Service row with arrow → opens external link or page
  - **Log Out button**: Destructive style (red), full width, triggers logout flow with confirmation modal
- Remove all references to `ProfileCopy`:
  - Delete or deprecate `lib/front_page/profile_copy/` directory
  - Update GoRouter routes in `nav.dart`: redirect `/profileCopy` to `/profile`
  - Ensure bottom nav tab 4 points to consolidated Profile
- Apply V2 theme styling throughout (colors, typography, spacing, card styles)
- Handle loading state while user data loads
- Handle error state if profile data fetch fails

### Out of Scope
- Redesigning ProfileEditPage content (defer to future task)
- Biometric setup page changes (uses existing `biometricSetupPage` route)
- Notification preferences page content (Process 8 or future)
- Privacy Policy / Terms of Service page content creation
- Dark mode specifics beyond what the theme from P4-T01 provides

---

## Technical Spec

### Files to Create or Modify
- `lib/front_page/profile/profile_widget.dart` — Rewrite with V2 layout
- `lib/front_page/profile/profile_model.dart` — Update page model
- `lib/front_page/profile_copy/` — Mark as deprecated or delete (remove route)
- `lib/flutter_flow/nav/nav.dart` — Remove `/profileCopy` route or redirect to `/profile`
- `lib/index.dart` — Remove ProfileCopy export if present

### API Endpoints
- `GET /profile` — `MedicalAppsApiGroup.ProfileCall` — Fetch user profile data if not in app state

### Data / Schema
User data from `FFAppState`:
| Variable | Type | Usage |
|----------|------|------|
| `name` | String | Full name in header |
| `userEmail` | String | Email in header |
| `nationalman` | String | NRIC in header |
| `fingerprint` | bool | Biometric login toggle state |
| `faceid` | bool | Face ID toggle state |

### UI Components
**Profile screen layout (scrollable):**
```
[Avatar 80px]  {Full Name}        ← heading-md
               {Email}            ← body-md, text-secondary
               {NRIC}             ← body-sm, text-secondary

--- Section Card ---
My Details                              [>]  ← heading-sm, tappable

--- Section Card ---
Settings                                ← section label
  Biometric Login                [toggle]  ← row with Switch
  Notification Preferences             [>]  ← tappable row
  Change Password                      [>]  ← tappable row

--- Section Card ---
About                                   ← section label
  He Clinic Info                      [>]
  Privacy Policy                      [>]
  Terms of Service                    [>]

--- Log Out Button ---
[Log Out]  ← destructive (red, full width)
```

**Log Out confirmation modal:**
Per v2-ux-spec.md section 5 Confirmation Modal:
- Warning icon (48px)
- "Are you sure?" heading-md centered
- "This action cannot be undone." body-md text-secondary centered
- Cancel (ghost) + Log Out (destructive) buttons

### Constraints
- ProfileCopy route must NOT remain active — all ProfileCopy references must point to consolidated Profile
- Must not break existing ProfileEditPage navigation
- Must use existing `logout()` custom action from `lib/custom_code/actions/logout.dart`
- All section rows must use V2 card style (surface bg, lg radius, low shadow)

---

## Acceptance Criteria

- [ ] Profile screen displays avatar (with initials fallback), full name, email, and NRIC in the header
- [ ] My Details section is tappable and navigates to ProfileEditPage without errors
- [ ] Settings section shows Biometric Login with functional toggle, Notification Preferences arrow, and Change Password arrow
- [ ] About section shows He Clinic Info, Privacy Policy, and Terms of Service as tappable rows
- [ ] Log Out button (destructive style) triggers confirmation modal with Cancel and Log Out options
- [ ] Log Out confirmation drains session and navigates to login screen
- [ ] Bottom nav tab 4 (Profile) points to the new consolidated Profile page, NOT ProfileCopy
- [ ] GoRouter has no active `/profileCopy` route (removed or redirects to `/profile`)
- [ ] `lib/front_page/profile_copy/` directory is deleted or no longer imported
- [ ] App compiles and runs without errors; profile screen loads and scrolls correctly

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

