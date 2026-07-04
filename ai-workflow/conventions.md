# File Naming Conventions

> Applies to all files under `tasks/`, `memory/`, and `ai-workflow/`.

---

## Task Files

### Format

```
{task-id}_{slug}.md
```

### Rules

- Task ID: `T` followed by a zero-padded 3-digit number — `T001`, `T002`, `T003`
- Slug: lowercase, hyphenated, max 5 words, describes the task in plain English
- No spaces, no uppercase, no special characters except hyphens
- IDs are sequential and never reused — even if a task is deleted

### Examples

```
T001_fix-minsdk-version.md
T002_plato-token-to-proxy.md
T003_remove-test-page.md
T004_laravel-project-scaffold.md
T005_branch-management-crud.md
T012_booking-confirmation-screen.md
T023_article-list-screen.md
```

---

## Memory Files

Memory files have fixed names — they do not use task IDs or slugs.

```
memory/
  project-manager/
    context.md
    task-index.md
  flutter-developer/
    context.md
  laravel-developer/
    context.md
  qa/
    context.md
    known-issues.md
  reviewer/
    context.md
    decisions-log.md
```

Memory files are never renamed. They are updated in place.

---

## Task Folder Names

Fixed names — do not rename.

```
tasks/
  backlog/
  in-progress/
  in-review/
  done/
  blocked/
```

---

## IDs in Memory Files

### Task Index (`memory/project-manager/task-index.md`)

References task files by Task ID only — `T001`, `T002`, etc.

### Known Issues (`memory/qa/known-issues.md`)

Format: `KI-{NNN}` — `KI-001`, `KI-002`
Sequential, never reused.

### Decisions Log (`memory/reviewer/decisions-log.md`)

Format: `DL-{NNN}` — `DL-001`, `DL-002`
Sequential, never reused.

---

## Process-to-Task Mapping

When naming a task, prefix the slug with the domain if helpful for clarity.
This is optional but recommended for large processes.

| Process | Slug Prefix | Example |
|---------|-------------|---------|
| 1 — Security | (no prefix needed, tasks are specific) | `T001_fix-minsdk-version.md` |
| 2 — Laravel Scaffold | `laravel-` | `T004_laravel-project-scaffold.md` |
| 3 — Data Layer | `data-` | `T010_data-pagination-helper.md` |
| 4 — UI Overhaul | `ui-` | `T015_ui-home-screen.md` |
| 5 — Booking | `booking-` | `T020_booking-branch-select.md` |
| 6 — Health Tab | `health-` | `T025_health-records-tab.md` |
| 7 — Admin Patient | `admin-` | `T030_admin-patient-list.md` |
| 8 — Notifications | `notif-` | `T035_notif-composer-ui.md` |
| 9 — CMS | `cms-` | `T040_cms-articles-module.md` |
| 10 — Polish | `polish-` | `T045_polish-dark-mode.md` |
| 11 — Loyalty | `loyalty-` | `T050_loyalty-earn-logic.md` |

---

## Status Labels (used inside task files)

Exact strings — no variations.

```
BACKLOG
IN-PROGRESS
IN-REVIEW
DONE
BLOCKED
```

---

## Date Format

All dates in memory files and task files use `YYYY-MM-DD`.

Example: `2026-07-15`