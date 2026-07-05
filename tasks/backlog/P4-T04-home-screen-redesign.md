# Home Screen Redesign

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T04 |
| Slug | home-screen-redesign |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date |  |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P4-T01, P4-T02, P4-T03 |
| Blocked Reason | N/A |

---

## Description

Redesign the Home screen (`HomepageNewWidget`) to match the v2-ux-spec.md Home screen layout. The new Home screen includes: app bar with logo and notification bell, greeting header, hero slider (dynamic from CMS sliders API), quick action grid (2x2 cards: Book Appointment, My Records, Health, Packages), loyalty points widget (conditional), upcoming appointment card, horizontal doctor list (from P4-T03), health tips (article cards), and video thumbnail grid. Content is scrollable. Hero slider auto-scrolls every 4 seconds.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Section 4 "SCREEN: Home" (lines 307-378), including all subsections: Hero Slider, Quick Actions, Loyalty Points Widget, Upcoming Appointment Card, Doctor Cards, Health Tips, Videos
- `docs/CODEBASE.md` — Section 6 (Routing — HomepageNew), Section 10 (Medical Apps API — Sliders, ServicePackages), Section 12 (WordPress API), Section 4 (App State)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul Step 4"
- `lib/front_page/homepage_new/` — Existing Home screen source
- `lib/backend/api_requests/api_calls.dart` — `SlidersCall`, `ServicesPackagesCall`

---

## Scope

### In Scope
- Rewrite `HomepageNewWidget` with the V2 layout described in v2-ux-spec.md section 4
- **App bar**: He Clinic logo (left), Notifications bell icon (right, with unread badge from `FFAppState().coutnnotif`)
- **Greeting**: "Good morning/afternoon/evening, {Name}" — heading-md, primary color
- **Hero Slider**: Dynamic from `GET /api/v2/plato/sliders` via CMS or existing `SlidersCall`. Auto-scroll 4s, dot indicators. Tap opens article or URL
- **Quick Actions**: 2x2 grid of cards: Book Appointment, My Records, Health, Packages. Each with teal icon (28px) + label. Tap navigates to respective screen
- **Loyalty Points Widget**: Gradient card (primary to accent). Shows tier badge, points balance, "Patient Appreciation Points" label, Redeem Points + View History buttons. Hidden if no loyalty account
- **Upcoming Appointment Card**: Doctor photo + name, date + time, branch, status chip (Confirmed/Pending), View Details ghost button. Data from `GetAppointmentUpcomingCall`
- **Our Doctors section**: Horizontal scroll of `DoctorCardWidget` from P4-T03, section header + See All link
- **Health Tips section**: Article cards from WordPress API (`GET /posts?per_page=4`), section header + See All link
- **Videos section**: 2-column grid, max 4 thumbnails, from CMS videos API (or hide section if 0 videos). Each: thumbnail (16:9, lg radius), play icon overlay, title below
- **Skeleton loaders**: Every data section shows skeleton while loading, matching actual content layout
- **Empty states**: Sections hide or show empty state per v2-ux-spec.md

### Out of Scope
- Full articles list screen (Process 9 — CMS)
- Full videos list screen (Process 9 — CMS)
- Loyalty points full screen (My Points screen — Process 10 or future)
- Booking flow (Process 5)
- Health tab content (Process 6)
- CMS data sources for sliders, articles, videos (use existing APIs for now; CMS in Process 9)

---

## Technical Spec

### Files to Create or Modify
- `lib/front_page/homepage_new/homepage_new_widget.dart` — Rewrite with V2 layout
- `lib/front_page/homepage_new/homepage_new_model.dart` — Update page model for new data flows
- `lib/components/hero_slider_widget.dart` — Create reusable hero slider component
- `lib/components/quick_action_card.dart` — Create reusable quick action card
- `lib/components/loyalty_points_widget.dart` — Create loyalty points balance card
- `lib/components/upcoming_appointment_card.dart` — Create appointment summary card
- `lib/components/section_header.dart` — Create reusable section header with optional "See All" link

### API Endpoints
- `GET /sliders` — `MedicalAppsApiGroup.SlidersCall` — Fetch hero slider images
- `GET /servicepackages` — `MedicalAppsApiGroup.ServicesPackagesCall` — For quick action data?
- `GET /appointment` — `PlatomeApiGroup.GetAppointmentUpcomingCall` — Upcoming appointment
- `GET /facility` — `PlatomeApiGroup.GetproviderCall` — Doctor list (via P4-T03 component)
- `GET /posts?per_page=4` — WordPress API — Latest 4 articles for Health Tips

### Data / Schema
**Loyalty widget data** (preliminary — full schema in Process 10):
| Field | Type |
|-------|------|
| `balance` | int |
| `lifetime_points` | int |
| `tier` | "Standard" / "Silver" / "Gold" |

**Hero slider data:**
| Field | Type |
|-------|------|
| `image_url` | String |
| `link_url` | String? |
| `link_type` | "article" / "url" / null |

### UI Components
Full layout scroll order (v2-ux-spec.md lines 307-378):
1. App Bar (logo left, bell right with badge)
2. Greeting: "Good morning, {Name}" — heading-md
3. Hero Slider — 180px height, auto-scroll 4s
4. Quick Actions — 2x2 grid: [Book Appointment] [My Records] / [Health] [Packages]
5. Loyalty Points Widget — gradient card (hidden if no loyalty)
6. Upcoming Appointment — section header + card or empty state
7. Our Doctors — section header + horizontal scroll + See All
8. Health Tips — section header + 2 article cards + See All
9. Videos — section header + 2x2 thumbnail grid + See All

### Constraints
- All data sections must handle loading (skeleton), empty (hide or empty state message), and error (error icon + try again) states
- Hero slider must use `flutter_animate` for auto-scroll (or `PageView` with `Timer`)
- Quick action cards must use V2 theme card style (lg radius, low shadow, surface bg)
- Loyalty widget hidden entirely if patient has no loyalty account

---

## Acceptance Criteria

- [ ] Home screen renders with app bar showing logo (left) and notification bell with unread badge (right)
- [ ] Greeting text shows "Good morning/afternoon/evening, {Name}" based on time of day
- [ ] Hero slider displays images from the sliders API, auto-scrolls every 4 seconds, and shows dot indicators
- [ ] Quick action grid displays exactly 4 cards in 2x2 layout: Book Appointment, My Records, Health, Packages
- [ ] Each quick action card navigates to the correct screen on tap
- [ ] Upcoming appointment section shows appointment card when data exists, empty state "No upcoming appointments" with Book Now CTA when none
- [ ] Our Doctors section renders horizontal scroll of doctor cards from the dynamic doctor list (P4-T03)
- [ ] Health Tips section renders article cards from WordPress API
- [ ] Videos section renders 2-column thumbnail grid or hides entirely if no videos exist
- [ ] Loyalty Points widget renders as gradient card with points balance and tier badge when loyalty data exists
- [ ] Skeleton loaders display for each data section while fetching
- [ ] Error state with "Try Again" button displays when any section's API call fails
- [ ] App compiles and runs without crashes; Home screen scrolls smoothly

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

