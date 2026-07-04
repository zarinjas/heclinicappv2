# He Clinic V2 — Agentic AI Workflow

> Source of truth: `docs/v2-decisions.md`. All agents must treat it as authoritative.
> Never contradict decisions locked in `v2-decisions.md`.

---

## Purpose

This folder defines the AI agent workflow for He Clinic V2 development.
It governs how tasks are created, assigned, implemented, verified, and reviewed
across five specialized agents.

---

## Folder Structure

```
ai-workflow/
  README.md            # This file — overview and folder map
  agents.md            # Agent roles and responsibilities
  workflow.md          # Task lifecycle and state machine
  memory.md            # Memory structure per agent
  task-template.md     # Standard task file template
  conventions.md       # File naming conventions

tasks/
  backlog/             # Tasks not yet started
  in-progress/         # Tasks currently being worked on
  in-review/           # Tasks submitted for QA or Reviewer
  done/                # Completed and approved tasks
  blocked/             # Tasks that cannot proceed — reason documented

memory/
  project-manager/
    context.md         # Current sprint focus, open decisions
    task-index.md      # Master list of all tasks and their status
  flutter-developer/
    context.md         # Current task, last known state, pending items
  laravel-developer/
    context.md         # Current task, last known state, pending items
  qa/
    context.md         # Active verification notes
    known-issues.md    # Recurring issues found across tasks
  reviewer/
    context.md         # Current review notes
    decisions-log.md   # Deviations flagged and decisions made
```

---

## Guiding Principles

1. One task, one file. Each task lives in exactly one file under `tasks/`.
2. Tasks move forward, never backward (except Blocked).
3. Agents do not overlap. Each agent has a clearly bounded role.
4. All implementation decisions that deviate from `v2-decisions.md` must be
   flagged by Reviewer and escalated before proceeding.
5. Memory files are updated after every agent handoff — not after the final step.
6. QA verifies against acceptance criteria only. QA does not redesign.
7. Reviewer checks alignment with `v2-decisions.md` and `v2-ux-spec.md` only.
   Reviewer does not re-implement.

---

## Process Map (Processes 1–11 from v2-decisions.md)

The processes defined in `docs/v2-decisions.md` map directly to task groups.
Project Manager uses them as the primary task decomposition source.

| Process | Label | Type |
|---------|-------|------|
| 1 | Security and Foundation | Flutter + Laravel |
| 2 | Laravel Admin Panel Scaffold | Laravel |
| 3 | Mobile App Data Layer Refactor | Flutter |
| 4 | Mobile App UI/UX Overhaul | Flutter |
| 5 | Booking Flow | Flutter + Laravel |
| 6 | Health Tab | Flutter + Laravel |
| 7 | Admin Panel Patient and Appointment Management | Laravel |
| 8 | Notifications Module | Flutter + Laravel |
| 9 | CMS Module | Laravel + Flutter |
| 10 | Polish and Remaining Features | Flutter + Laravel |
| 11 | Loyalty Points System | Flutter + Laravel |

Processes must be completed in order. Process N cannot start until Process N-1
has all tasks in `done/`.
```