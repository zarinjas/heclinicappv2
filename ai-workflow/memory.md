# Memory Structure

> Defines what each agent remembers between sessions.
> Memory files must be updated after every handoff — not just at task completion.

---

## Overview

Each agent has a dedicated memory folder under `memory/`.
Memory files are plain markdown. They are short, current, and actionable.
They do not store historical logs — that is what completed task files are for.

```
memory/
  project-manager/
    context.md         # Active sprint, current process, open decisions
    task-index.md      # Master list of all tasks and their current state

  flutter-developer/
    context.md         # Active task, last completed task, known constraints

  laravel-developer/
    context.md         # Active task, last completed task, known constraints

  qa/
    context.md         # Task currently under verification, last result
    known-issues.md    # Patterns of recurring failures across tasks

  reviewer/
    context.md         # Task currently under review, last decision
    decisions-log.md   # Deviations from v2-decisions.md found during review
```

---

## memory/project-manager/context.md

Purpose: PM's current working state. Updated after every task creation or status change.

```markdown
# Project Manager — Context

Last Updated: {date}

## Current Process
Process {N} — {Process Name}

## Active Tasks
- {task-id} — {slug} — {state} — assigned to {agent}
- {task-id} — {slug} — {state} — assigned to {agent}

## Blocked Tasks
- {task-id} — {slug} — Blocked by: {reason}

## Open Decisions (from v2-decisions.md — Still Pending)
- Email provider not resolved — blocks Process 8
- GET /systemsetup access unconfirmed — blocks Process 2 step 6

## Next Task to Create
Process {N}, Step {N} — {description}

## Notes
{any short-term context PM needs to remember}
```

---

## memory/project-manager/task-index.md

Purpose: Master registry of all tasks ever created. One row per task.

```markdown
# Task Index

Last Updated: {date}

| Task ID | Slug | Process | Step | Type | Assigned To | State | Done Date |
|---------|------|---------|------|------|-------------|-------|-----------|
| T001 | fix-minsdk-version | 1 | 3 | Flutter | flutter-developer | DONE | 2026-07-15 |
| T002 | plato-token-proxy | 1 | 1 | Laravel | laravel-developer | IN-PROGRESS | — |
| T003 | remove-test-page | 1 | 5 | Flutter | flutter-developer | BACKLOG | — |
```

---

## memory/flutter-developer/context.md

Purpose: Flutter Developer's current working state.

```markdown
# Flutter Developer — Context

Last Updated: {date}

## Active Task
Task ID: {task-id}
Slug: {slug}
Started: {date}
Current status: {what I am working on right now}

## Last Completed Task
Task ID: {task-id}
Slug: {slug}
Completed: {date}

## Known Constraints
- All Plato API calls must route through Laravel proxy — not direct to Plato
- EnvConfig must be used for all base URLs
- flutter_animate is available for skeleton/transition animations
- FlutterFlow naming conventions apply (FFAppState, *Widget, *Model, *Call)
- GoRouter is the router — no Navigator.push directly

## Pending Items
- {anything left incomplete or to revisit}
```

---

## memory/laravel-developer/context.md

Purpose: Laravel Developer's current working state.

```markdown
# Laravel Developer — Context

Last Updated: {date}

## Active Task
Task ID: {task-id}
Slug: {slug}
Started: {date}
Current status: {what I am working on right now}

## Last Completed Task
Task ID: {task-id}
Slug: {slug}
Completed: {date}

## Known Constraints
- Plato API token lives in .env only — never in any response or log
- Pagination: always loop with current_page until empty response
- HTTP 429: exponential backoff 1s, 2s, 4s, 8s — then fail gracefully
- MySQL schemas in v2-decisions.md are authoritative — do not alter column names
- Tech stack: Laravel + Inertia.js + Vue 3 + Tailwind CSS

## Pending Items
- {anything left incomplete or to revisit}
```

---

## memory/qa/context.md

Purpose: QA's current verification state.

```markdown
# QA — Context

Last Updated: {date}

## Active Verification
Task ID: {task-id}
Slug: {slug}
Started: {date}
Progress: {criteria checked so far}

## Last Result
Task ID: {task-id}
Slug: {slug}
Result: PASSED / FAILED
Failed Criteria: {list if failed}

## Notes
{anything QA needs to carry forward — e.g. a pattern to watch for}
```

---

## memory/qa/known-issues.md

Purpose: Running log of recurring failure patterns found across tasks.
QA updates this when the same type of failure appears more than once.

```markdown
# QA — Known Issues

Last Updated: {date}

## Recurring Patterns

### [KI-001] Missing error state on list screens
Seen in: T003, T007
Pattern: Developer implements loading and empty states but omits the error state.
Check: Every list screen must have all three states — loading (skeleton), empty, error.

### [KI-002] Plato API called directly from Flutter
Seen in: T005
Pattern: Developer calls Plato endpoint directly instead of routing through Laravel proxy.
Check: All PlatomeApiGroup calls in Flutter must point to Laravel proxy URL via EnvConfig.

### [KI-003] Pagination not implemented
Seen in: T008, T009
Pattern: List screen loads first 20 records only — no current_page loop.
Check: Confirm infinite scroll or Load More triggers pagination.
```

---

## memory/reviewer/context.md

Purpose: Reviewer's current review state.

```markdown
# Reviewer — Context

Last Updated: {date}

## Active Review
Task ID: {task-id}
Slug: {slug}
Started: {date}

## Last Decision
Task ID: {task-id}
Slug: {slug}
Decision: APPROVED / REJECTED
Reason: {brief note}

## Notes
{anything reviewer needs to carry forward}
```

---

## memory/reviewer/decisions-log.md

Purpose: Log of all deviations from `v2-decisions.md` found during review.
This is the audit trail for architecture and design decisions.

```markdown
# Reviewer — Decisions Log

Last Updated: {date}

## Log

### [DL-001] Booking flow used in-app confirmation instead of WhatsApp redirect
Date: 2026-07-18
Task: T012 — booking-flow-confirmation-screen
Finding: Implementation showed an in-app confirm button. v2-decisions.md Decision #2
  states the booking model is WhatsApp redirect — intentional business decision.
Action: REJECTED. Returned to in-progress with note to implement WhatsApp deep link.
Resolution: T012 re-implemented correctly on 2026-07-20. APPROVED.

### [DL-002] Doctor list fetched from Firestore instead of GET /facility
Date: 2026-07-22
Task: T015 — doctor-list-screen
Finding: Developer used Firestore as the data source. Locked decision #10 states
  admin explicitly selects visible doctors via Admin Panel — source is Laravel API.
Action: REJECTED. Returned to in-progress.
Resolution: Pending.
```