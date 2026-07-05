# ArticleCard Component

## Header
| Field | Value |
|-------|-------|
| Task ID | UI-P1-T03 |
| Slug | article-card |
| Process | Epic UI — Phase 1 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | DONE |

## Acceptance Criteria
- [x] Featured image 140px with rounded top corners — PASS
- [x] Category chip overlay top-left — PASS
- [x] Title heading3, 2 lines max — PASS
- [x] Excerpt body2/textSecondary, 2 lines max — PASS
- [x] Author + date footer — PASS
- [x] Skeleton loader — PASS
- [x] Dark mode — PASS
- [x] No hardcoded tokens — PASS
- [x] flutter analyze zero errors — PASS

## Implementation Notes
### Files Changed
- `lib/core/widgets/article_card.dart` — new file
### Decisions
- Category chip uses accent bg overlay via Positioned in Stack
- Uses AppCard with zero padding for full-bleed image
- Image error fallback: divider-colored container with icon

## QA Notes
### Result: PASSED — Build gate: 0 errors. All criteria verified.

## Reviewer Notes
### Decision: APPROVED — §10 compliance, dark mode, skeleton, all tokens used.
