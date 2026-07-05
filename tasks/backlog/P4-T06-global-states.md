# Apply Global Loading, Empty, and Error States

## Header

| Field | Value |
|-------|-------|
| Task ID | P4-T06 |
| Slug | global-states |
| Process | 4 — Mobile App: UI/UX Overhaul |
| Process Step | Step 6 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date |  |
| Status | BACKLOG |
| Parallel | NO |
| Depends On | P4-T01 |
| Blocked Reason | N/A |

---

## Description

Apply consistent loading states (skeleton loaders), empty states (illustration + title + subtitle + optional CTA), and error states (error icon + message + Try Again button) across all screens in the app per v2-ux-spec.md specifications. Create reusable state components that all screens can use. Apply to Home screen, Appointments tab, Health tab, Notifications tab, Profile screen, and any remaining screens with data loading. Never show a blank screen.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-ux-spec.md` — Sections 2 (Component Library: Skeleton Loaders, Empty States, Error States, Inline Spinner, Toast/Snackbar), Section 6 (Error and Feedback Patterns)
- `docs/CODEBASE.md` — Section 4 (App State), Section 19 (Known Issues #8 — No error handling)
- `docs/v2-decisions.md` — Section "PROCESS 4 — Mobile App: UI/UX Overhaul Step 6"
- `lib/components/` — Existing shared components directory for placement

---

## Scope

### In Scope
- Create reusable skeleton loader components:
  - `SkeletonListTile` — avatar circle + 2 text lines for list items
  - `SkeletonCard` — full card rectangle for single cards
  - `SkeletonSlider` — wide rectangle (180px height) for hero slider
  - `SkeletonGrid` — 2-column grid of card rectangles
  - `SkeletonTextBlock` — varied-width horizontal bars for paragraphs
- Create reusable empty state component (`EmptyStateWidget`):
  - Centered SVG illustration (~160px height)
  - heading-md title
  - body-md subtitle in text-secondary
  - Optional Primary button CTA
  - Support all empty state configurations from v2-ux-spec.md table
- Create reusable error state component (`ErrorStateWidget`):
  - Error icon (red, 40px)
  - "Something went wrong" heading-sm
  - Error description body-md, text-secondary
  - "Try Again" ghost button
- Create reusable inline spinner for button loading states
- Apply skeleton loaders to: Home screen (all sections), Appointments list, Health tabs (Records/Vitals/Documents), Notifications list, Profile screen
- Apply empty states to: Appointments (no upcoming), Notifications (all caught up), Health Records (no records), Health Documents (no documents), Articles list (no articles)
- Apply error states to: All screens that fetch data — never leave a blank screen on API failure
- Ensure shimmer animation uses `flutter_animate` package as specified

### Out of Scope
- Toast/snackbar infrastructure (may be handled by P3-T01 error interceptor already)
- Offline banner implementation (defer to future task)
- Form validation UI (not the focus of this task)
- Redesigning screen layouts (done in P4-T01 through P4-T05)

---

## Technical Spec

### Files to Create or Modify
- `lib/components/skeleton_loaders.dart` — All skeleton loader widget variants
- `lib/components/empty_state_widget.dart` — Reusable empty state with configurable illustration, title, subtitle, and optional CTA
- `lib/components/error_state_widget.dart` — Reusable error state with icon, message, and Try Again button
- `lib/components/inline_spinner.dart` — Button inline loading spinner
- `lib/front_page/homepage_new/` — Apply to Home screen sections
- `lib/booking_page/my_booking_page/` — Apply to Appointments list
- `lib/front_page/reports/` — Apply to Health tabs
- `lib/front_page/notification_page/` — Apply to Notifications
- `lib/front_page/profile/` — Apply to Profile
- `lib/article_page/` — Apply to Articles list

### API Endpoints
N/A

### Data / Schema
N/A

### UI Components
**Skeleton Loaders (v2-ux-spec.md section 2):**
| Variant | Layout | Colors (Light) | Colors (Dark) |
|---------|--------|----------------|---------------|
| ListTile | avatar circle (40px) + 2 text bars | #E5E7EB → #F3F4F6 | #1F2937 → #374151 |
| Card | Full card rectangle | #E5E7EB → #F3F4F6 | #1F2937 → #374151 |
| Slider | Wide rect (180px height) | #E5E7EB → #F3F4F6 | #1F2937 → #374151 |
| Grid | 2-column card rects | #E5E7EB → #F3F4F6 | #1F2937 → #374151 |
| TextBlock | Varied-width bars (100%, 80%, 60% width) | #E5E7EB → #F3F4F6 | #1F2937 → #374151 |

Animation: shimmer left-to-right, 1.5s loop, using `flutter_animate`.

**Empty States (v2-ux-spec.md section 2 table):**

| Screen | Title | Subtitle | CTA |
|--------|-------|----------|-----|
| No appointments | No appointments yet | Book your first visit today | Book Now |
| No notifications | You are all caught up | We will notify you when something is new | — |
| No documents | No documents yet | Your health records will appear here | — |
| No records | No records found | Your clinical notes will appear here | — |
| No articles | No articles yet | Check back soon for health tips and updates | — |
| No videos | No videos yet | Check back soon for our latest videos | — |

**Error States (v2-ux-spec.md section 2):**
- Error icon: 40px, red (#EF4444)
- Title: "Something went wrong" heading-sm
- Description: body-md, text-secondary
- "Try Again" ghost button
- NEVER show a blank screen

### Constraints
- All skeleton animation must use `flutter_animate` package (already in pubspec)
- Empty state illustrations should use simple SVG icons or Flutter built-in icons (no additional asset dependencies unless they exist)
- Error states must include a retry mechanism that calls the original data fetch function
- Components must be themable (respond to light/dark mode from P4-T01)

---

## Acceptance Criteria

- [ ] `SkeletonListTile`, `SkeletonCard`, `SkeletonSlider`, `SkeletonGrid`, and `SkeletonTextBlock` reusable widgets are available in `lib/components/`
- [ ] Skeleton loaders render with shimmer animation (left-to-right, 1.5s loop) when data is loading
- [ ] `EmptyStateWidget` accepts configurable title, subtitle, and optional CTA button; renders centered on screen
- [ ] `ErrorStateWidget` renders error icon, "Something went wrong" message, and "Try Again" button that triggers a provided retry callback
- [ ] Home screen shows skeleton loaders for each section while data loads, then transitions to content
- [ ] Appointments screen shows empty state "No appointments yet" with Book Now CTA when no appointments exist
- [ ] Notifications screen shows empty state "You are all caught up" when no notifications exist
- [ ] Health tabs show appropriate empty states when data is absent
- [ ] All screens that fetch data show error state (not blank) when an API call fails
- [ ] `InlineSpinner` replaces button label text correctly during loading operations
- [ ] App compiles and runs without errors; no screen renders blank under any data state

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

