# Health Tab Scaffold with 3 Inner Tabs

## Header

| Field | Value |
|-------|-------|
| Task ID | P6-T01 |
| Slug | health-tab-scaffold |
| Process | 6 — Health Tab |
| Process Step | Step 1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Rebuild the existing `ReportsWidget` (`lib/front_page/reports/reports_widget.dart`) into a production-quality Health Tab that serves as the `health` route in the bottom navigation (currently at tab index 2). The scaffold must use V2 design system tokens and display 3 inner tabs: **Records**, **Vitals**, and **Documents** — matching the spec in `docs/v2-decisions.md` Process 6 Step 1 and `docs/v2-ux-spec.md` Health Tab screen.

The existing widget already has a 3-tab structure with a `TabController` (Visit, My Labs, My Documents). This task replaces those tabs and styling with the V2 design while keeping the widget integrated with the bottom nav at `lib/main.dart:231`.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 6 Step 1 (Health tab scaffold section at line 86)
- `docs/v2-ux-spec.md` — SCREEN: Health Tab section (line 573), Design System section (line 9)
- `docs/CODEBASE.md` — Section 3: Struktur Direktori, existing ReportsWidget path
- `docs/v2-decisions.md` — Health Tab Inner Tabs table (line 331)

---

## Scope

> Exact deliverables for this task. Be specific.

### In Scope
- Redesign the Health tab scaffold UI using V2 design system (AppColors, AppSpacing, AppRadius)
- Replace "Visit / My Labs / My Documents" tabs with "Records / Vitals / Documents"
- Apply brand-appropriate tab styling: primary background, accent indicator, Plus Jakarta Sans labels
- Apply consistent padding and layout matching other V2 screens (HomepageNew, AppointmentsScreen)
- Ensure the widget remains connected to the existing bottom navigation at `lib/main.dart:231` (`'health': ReportsWidget(id: null)`)
- App bar: solid primary background, white title "My Health", no back arrow (since it's a nav tab)
- TabBar styling: primary background, accent color indicator, white text for selected tab, white 60% opacity for unselected
- Each inner tab body is a placeholder with skeleton loader structure (actual content deferred to P6-T02, P6-T03, P6-T04)

### Out of Scope
- Implementing data fetching for any tab (deferred to P6-T02, P6-T03, P6-T04)
- Filter chips, graph rendering, PDF viewer
- Changing the bottom navigation itself
- Any API call integration

---

## Technical Spec

> Key implementation details.

### Files to Modify
- `lib/front_page/reports/reports_widget.dart` — Redesign scaffold, replace tabs, update AppBar
- `lib/front_page/reports/reports_model.dart` — Update tab names and any model state if needed

### UI Components
- AppBar: primary background (`AppColors.primary`), white title "My Health", centerTitle, no leading back arrow
- TabBar: isScrollable=false (exactly 3 tabs, no scrolling), `AppColors.primary` background, `AppColors.accent` indicator, labels use GoogleFonts.plusJakartaSans 14px weight 600
- Tab 1: "Records" icon: `Icons.article_outlined`
- Tab 2: "Vitals" icon: `Icons.monitor_heart_outlined`
- Tab 3: "Documents" icon: `Icons.folder_outlined`
- Each tab body: `SkeletonListTile` × 4 for placeholder (actual content from later tasks)
- Loading state: Skeleton loader pattern matching the content shape
- Empty state: use `EmptyStateWidget` (already at `lib/components/empty_state_widget.dart`)
- Error state: use `ErrorStateWidget` (already at `lib/components/error_state_widget.dart`)

### Constraints
- Must use existing design system tokens from `lib/theme/app_theme.dart` (AppColors, AppSpacing, AppRadius)
- Must use GoogleFonts.plusJakartaSans for all text (matching rest of V2)
- Do NOT break the `'health': ReportsWidget(id: null)` mapping in `lib/main.dart:231`
- The widget must still accept `final String? id` in constructor (used by routing)

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Health tab appears in bottom navigation at index 2 with heart icon, navigates to the redesigned scaffold
- [ ] AppBar displays "My Health" in white on primary background, centered, with no back arrow
- [ ] TabBar shows 3 tabs: Records, Vitals, Documents — each with icon and label
- [ ] Tab indicator uses accent color (#00C9A7), selected tab text is white, unselected is white at 60% opacity
- [ ] Switching tabs via TabBarView works correctly (three distinct tab bodies)
- [ ] All text uses Plus Jakarta Sans font (GoogleFonts.plusJakartaSans)
- [ ] No compile errors — `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled by Developer after implementation.

### What Was Done
{to be filled}

### Files Changed
{to be filled}

### Decisions Made During Implementation
{to be filled}

### Known Limitations
{to be filled}

---

## QA Notes

> Filled by QA after verification.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] Health tab appears correctly — {PASS / FAIL} — {note}
- [ ] AppBar styling correct — {PASS / FAIL} — {note}
- [ ] TabBar shows 3 tabs with icons — {PASS / FAIL} — {note}
- [ ] Tab indicator and text colors correct — {PASS / FAIL} — {note}
- [ ] Tab switching works — {PASS / FAIL} — {note}
- [ ] Plus Jakarta Sans font used — {PASS / FAIL} — {note}
- [ ] flutter analyze zero errors — {PASS / FAIL} — {note}

### Failure Details
{to be filled if failed}

---

## Reviewer Notes

> Filled by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}

### Rejection Reason
{to be filled if rejected}
