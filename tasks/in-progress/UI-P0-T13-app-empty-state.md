# AppEmptyState — Empty State Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P0-T13 |
| Slug | app-empty-state |
| Process | Epic — UI Migration — Phase 0 |
| Process Step | Step 13 of 16 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | UI-P0-T04 |
| Blocked Reason | N/A |

---

## Description

Create `lib/core/widgets/app_empty_state.dart` — the empty state component used when lists/content have no data. Every screen must define an empty state. This component provides a reusable layout: illustration icon + title + subtitle + optional CTA button.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §16 Empty States (lines 458–472)
- `docs/ui-migration-plan.md` — Phase 0 item 0.13 (line 40)
- `docs/ui-epic.md` — Phase 0 table entry UI-P0-T13, Compliance Check: §16

---

## Scope

### In Scope
- Create `lib/core/widgets/app_empty_state.dart` with `AppEmptyState` widget
- Layout: centered column, icon ~160px, title (`heading3`), subtitle (`body1`, `textSecondary`), optional primary button
- Icon: configurable `IconData` + color
- Title and subtitle text: configurable
- Optional CTA button: label + onPressed callback
- 8 preset configurations matching the design system:
  - No appointments: calendar icon, "No appointments yet", "Book your first visit today", "Book Now" button
  - No notifications: bell icon, "You're all caught up", "We'll notify you when something's new"
  - No documents: file icon, "No documents yet", "Your health records will appear here"
  - No records: clipboard icon, "No records found", "Your clinical notes will appear here"
  - No articles: article icon, "No articles yet", "Check back soon for health tips"
  - No videos: play icon, "No videos yet", "Check back soon for our latest videos"
  - No doctors: person icon, "No doctors available", "Please contact the clinic directly"
  - No search results: search icon, "No results found", "Try a different search term"

### Out of Scope
- Screen-level decision of when to show empty state (each screen manages its own state)
- Error state (UI-P0-T14 handles that separately)

---

## Technical Spec

### Files to Create
- `lib/core/widgets/app_empty_state.dart` — AppEmptyState widget

### Empty State Presets (§16)
| Context | Icon | Title | Subtitle | CTA |
|---------|------|-------|---------|-----|
| Appointments | calendar | No appointments yet | Book your first visit today | Book Now |
| Notifications | bell | You're all caught up | We'll notify you when something's new | — |
| Documents | file | No documents yet | Your health records will appear here | — |
| Records | clipboard | No records found | Your clinical notes will appear here | — |
| Articles | article | No articles yet | Check back soon for health tips | — |
| Videos | play | No videos yet | Check back soon for our latest videos | — |
| Doctors | person | No doctors available | Please contact the clinic directly | — |
| Search | search | No results found | Try a different search term | — |

### Widget API
```dart
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
}
```

### Constraints
- Use `AppColors` and `AppTextStyles` tokens
- Use Material Icons only (no SVG assets)
- Icon size: ~160px (logical pixels), use `size: 160` on Icon widget
- Center the entire layout vertically and horizontally

---

## Acceptance Criteria

- [ ] `lib/core/widgets/app_empty_state.dart` exists with `AppEmptyState` widget
- [ ] Renders icon (configurable), title, subtitle, and optional CTA in centered column
- [ ] Icon is configurable via `IconData` parameter
- [ ] Title uses `AppTextStyles.heading3`
- [ ] Subtitle uses `AppTextStyles.body1` with `AppColors.textSecondary`
- [ ] CTA button renders as primary button when `ctaLabel` provided
- [ ] CTA button hidden when `ctaLabel` is null
- [ ] All 8 preset configurations match the spec table
- [ ] Dark mode: text and icon colors adapt correctly
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{}

### Files Changed
- `lib/core/widgets/app_empty_state.dart`

### Decisions Made During Implementation
{}

### Known Limitations
{}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PENDING

### Criteria Results
- [ ] AppEmptyState widget exists — PENDING
- [ ] Icon + title + subtitle + optional CTA layout — PENDING
- [ ] Icon configurable — PENDING
- [ ] Title uses heading3 — PENDING
- [ ] Subtitle uses body1 + textSecondary — PENDING
- [ ] CTA renders/hides correctly — PENDING
- [ ] All 8 presets match spec — PENDING
- [ ] Dark mode adapts — PENDING
- [ ] flutter analyze passes — PENDING

### Failure Details
{}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: PENDING

### Alignment Check
- ui-design-system.md §16 alignment: PENDING
- ui-migration-plan.md alignment: PENDING
- Dark mode works — PENDING
- No hardcoded colors — PENDING

### Rejection Reason
{}
