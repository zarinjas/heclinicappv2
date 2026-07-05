# VideoCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T04 |
| Slug | video-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `VideoCard` reusable component for displaying health video thumbnails. Used on Home screen (Videos section, 2-column grid) and Videos list screen. Displays 16:9 thumbnail image with play icon overlay, title, and author.

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Video Thumbnail Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.4 (VideoCard), Phase 3 (Home — Health Videos), Phase 10 (Content Screens)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/video_card.dart` — new file
- Thumbnail image: 16:9 aspect ratio, `radiusLG` rounded corners
- Play icon overlay: 36px circle (semi-transparent white background), centered on thumbnail
- Title: `body2`, 2 lines max
- Author: `caption`, `textSecondary`
- Tap callback → opens TikTok URL via `url_launcher`
- Skeleton loader: 16:9 rect + 2 bars

### Out of Scope
- Video data fetching (data passed via constructor)
- TikTok URL opening logic (handled by `url_launcher`)
- Grid layout (handled by parent `GridView`)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/video_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Thumbnail: 16:9 aspect ratio, `AppRadius.lg`
- Play icon: 36px circle, white 70% opacity background, `Icons.play_arrow` centered
- Title: body2, maxLines 2
- Author: caption, textSecondary
- Both variants (compact for grid, full for list) share core layout

### Constraints
- Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`
- Dark mode support
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Thumbnail renders at 16:9 aspect ratio with rounded corners (`AppRadius.lg`)
- [ ] Play icon overlay renders as 36px circle with semi-transparent white background, centered on thumbnail
- [ ] Title displays in body2 style with 2 line max and ellipsis overflow
- [ ] Author text displays in caption/textSecondary below title
- [ ] Tap callback fires correctly
- [ ] Skeleton loader renders shimmer with 16:9 rect + 2 text bars
- [ ] Dark mode renders correctly
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
