# ArticleCard Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T03 |
| Slug | article-card |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `ArticleCard` reusable component for displaying health articles in list views. Used on Home screen (Health Articles section) and Articles list screen. Displays featured image, category chip overlay, title, excerpt, and author/date footer.

---

## Context

- `docs/ui-design-system.md` — §10 (Cards — Article Card)
- `docs/ui-migration-plan.md` — Phase 1, §1.3 (ArticleCard), Phase 3 (Home — Health Articles), Phase 10 (Content Screens)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/article_card.dart` — new file
- Featured image: full width, 140px height, `radiusLG` top corners
- Category chip: overlaid top-left on image (positioned with Stack)
- Title: `heading3`, 2 lines max (ellipsis overflow)
- Excerpt: `body2`, `textSecondary`, 2 lines max
- Footer: author name + date, `body2`, `textSecondary`
- Tap callback for navigation to article detail
- Skeleton loader: 140px image rect + 3 text bars

### Out of Scope
- Articles data fetching (data passed via constructor)
- Rich text rendering (handled by Article Detail screen)
- Category filter logic (handled by parent screen)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/article_card.dart` — new file

### Design Spec (from ui-design-system.md §10)
- Image: full width, 140px height, `AppRadius.lg` top corners (use `ClipRRect`)
- Category chip: `AppChip` filter variant, overlaid with `Positioned` top-left
- Title: heading3, maxLines 2, overflow ellipsis
- Excerpt: body2, textSecondary, maxLines 2
- Footer: author + formatted date, body2, textSecondary

### Constraints
- Use design tokens exclusively
- Dark mode support
- Skeleton loader defined

---

## Acceptance Criteria

- [ ] Featured image renders full width at 140px height with rounded top corners
- [ ] Category chip overlays top-left corner of image using Stack + Positioned
- [ ] Title displays in heading3 style with maximum 2 lines and ellipsis overflow
- [ ] Excerpt displays in body2/textSecondary with maximum 2 lines and ellipsis overflow
- [ ] Footer shows author name and formatted date in body2/textSecondary
- [ ] Tap callback fires correctly
- [ ] Skeleton loader renders shimmer with 140px rect + 3 text bars
- [ ] Dark mode renders with correct surface/divider colors
- [ ] No hardcoded design tokens
- [ ] `flutter analyze` returns zero errors
