# NotificationItem Component

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P1-T12 |
| Slug | notification-item |
| Process | Epic UI — Phase 1: Feature Components |
| Process Step | Step 12 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the `NotificationItem` reusable component for the Notifications tab list. Displays notification icon, title, body preview, timestamp, and unread indicator. Supports tap (mark as read + navigate deep link) and swipe-to-dismiss.

---

## Context

- `docs/ui-design-system.md` — §7 (Icons — Notification type icons), §11 (Notification Badge), §10 (Cards)
- `docs/ui-migration-plan.md` — Phase 1, §1.12 (NotificationItem), Phase 7 (Notifications Tab)
- `docs/ui-epic.md` — Phase 1 compliance rules
- `docs/design-system-v2.png` — visual target

---

## Scope

### In Scope
- `lib/core/widgets/notification_item.dart` — new file
- Leading: 24px notification type icon (Material Icons, varies by type)
- Title: `heading3` style, primary color
- Body preview: `body2`, `textSecondary`, 2 lines max
- Trailing: timestamp in `caption`, `textSecondary`
- Unread state: subtle tinted background (color based on theme) + blue dot indicator (6px, accent color, positioned top-right of leading icon area)
- Read state: normal background, no dot
- Tap callback: marks as read + navigates to deep link if present
- Dismissible wrapper: `Dismissible` with swipe end-to-start, red background with delete icon

### Out of Scope
- Notifications data fetching (data passed via constructor)
- Mark-all-read logic (handled by parent)
- Firestore sync (handled by parent)

---

## Technical Spec

### Files to Create or Modify
- `lib/core/widgets/notification_item.dart` — new file

### Design Spec
- Leading icon: 24px, type-dependent Material icon
- Unread bg: tinted with ~5% accent opacity (light) / ~10% (dark)
- Blue dot: 6px circle, accent color
- Title: heading3
- Body: body2, textSecondary, maxLines 2
- Timestamp: caption, textSecondary
- Swipe: Dismissible, confirmDismiss callback

### Constraints
- Design tokens only
- Dark mode support
- Swipe gesture must work on both platforms

---

## Implementation Notes

- Created `lib/core/widgets/notification_item.dart`
- StatelessWidget with constructor params: title, body, createdAt, isRead, type, deepLink, reference, onTap, onDismiss
- Leading icon: 24px Material icon mapped by type (calendar/appointment/document/alarm/campaign/default)
- Title: `AppTextStyles.heading3` with `AppColors.primary` (light) / `AppColors.textPrimaryDark` (dark)
- Body: `AppTextStyles.body2` with `AppColors.textSecondary`, maxLines 2
- Timestamp: `AppTextStyles.caption` with relative formatting (m/h/d ago)
- Unread: accented tinted bg + 6px blue dot on icon; Read: transparent bg, no dot
- Dismissible: swipe end-to-start with red delete background, confirmDismiss fires onDismiss
- Dark mode: all text colors adapt
- `flutter analyze`: zero errors

---

## Acceptance Criteria

- [x] Leading icon renders at 24px with type-appropriate Material icon (e.g., calendar for appointment, description for general)
- [x] Title displays in heading3 style, primary color
- [x] Body preview displays in body2/textSecondary, max 2 lines with ellipsis
- [x] Timestamp displays in caption/textSecondary, trailing position
- [x] Unread items show tinted background (subtle accent opacity) with blue 6px dot indicator
- [x] Read items show normal background with no blue dot
- [x] Tap callback fires, item marks as read and navigates to deep link if present
- [x] Swipe-to-dismiss (end-to-start) reveals red delete background; confirm callback fires
- [x] Dark mode: unread tint adapts, all text colors correct
- [x] No hardcoded design tokens
- [x] `flutter analyze` returns zero errors

---
## QA Notes

**Build Gate:** `flutter analyze` — PASSED (zero errors)

| # | Criterion | Result |
|---|-----------|--------|
| 1 | Type-appropriate 24px Material icon | PASS |
| 2 | Title heading3 + primary color | PASS |
| 3 | Body body2/textSecondary, maxLines 2 | PASS |
| 4 | Timestamp caption/textSecondary, trailing | PASS |
| 5 | Unread: tinted bg + 6px blue dot | PASS |
| 6 | Read: normal bg, no dot | PASS |
| 7 | Tap fires onTap callback | PASS |
| 8 | Swipe-to-dismiss: red bg + confirm fires onDismiss | PASS |
| 9 | Dark mode adapts (text colors, tint) | PASS |
| 10 | No hardcoded tokens | PASS |
| 11 | flutter analyze zero errors | PASS |

**QA Verdict: PASSED**
