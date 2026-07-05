# Health Videos Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T08 |
| Slug | health-videos-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.8 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the health videos section on the home screen using the `VideoCard` component (Phase 1). Fetch published videos from CMS API (`GET /api/v2/config/videos`), limited to max 4 for the home screen. Display as a 2-column `GridView` of `VideoCard` components. Tap a video opens TikTok via `url_launcher`. Show `AppSkeleton` while loading. Hide section if 0 published videos. "See All" navigates to Videos List screen (Phase 10). Replace all hardcoded video content.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §10 (AppCard), §15 (Skeleton), §16 (EmptyState)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 122
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Video card UX
- `docs/CODEBASE.md` — existing content_media/ code

---

## Scope

### In Scope
- Integrate `VideoCard` grid into home screen videos section
- Fetch published videos from `GET /api/v2/config/videos` (filter status = published, limit 4)
- Display as 2-column `GridView` of `VideoCard` components
- Show `AppSkeleton` shimmer (4 card placeholders) while loading
- Hide entire section if 0 published videos
- "See All" navigates to Videos List screen (Phase 10)
- Tap video card opens TikTok link via `url_launcher`
- Remove references to hardcoded video data from old code

### Out of Scope
- VideoCard component itself (Phase 1 — UI-P1-T04)
- Videos List screen (Phase 10)
- Videos CMS management (Process 9)
- Home screen shell (UI-P3-T01)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add videos section slot
- `lib/core/widgets/video_card.dart` — Use existing Phase 1 component

### API Endpoints
- `GET /api/v2/config/videos` — fetch published videos (via Laravel proxy)

### Data / Schema
- Video: `id`, `title`, `tiktok_url`, `thumbnail_url`, `status`, `sort_order`

### UI Components
- `VideoCard` — Phase 1 reusable
- `AppSkeleton` — shimmer video card placeholders
- `SectionHeader` — "Health Videos" + "See All"

### Constraints
- All styling must use design tokens
- Dark mode support
- No hardcoded video data in codebase
- Max 4 videos shown on home
- TikTok URLs open via `url_launcher`

---

## Acceptance Criteria

- [ ] Videos section displays up to 4 published videos in a 2-column `GridView`
- [ ] `AppSkeleton` shimmer (4 card placeholders) is displayed while loading
- [ ] Section is hidden when 0 published videos exist
- [ ] "See All" tap navigates to Videos List screen
- [ ] Tapping a video card opens TikTok URL via `url_launcher`
- [ ] No hardcoded video data remains in Flutter code
- [ ] `flutter analyze` passes with zero errors

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

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason

