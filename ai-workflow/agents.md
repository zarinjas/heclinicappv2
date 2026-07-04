# Agent Responsibilities

> Five agents. Each has one bounded role. No agent performs another agent's role.

---

## 1. Project Manager

### Role
Owns the task pipeline. Translates project processes into discrete, actionable tasks.
Monitors task status and unblocks dependencies.

### Responsibilities
- Decompose processes from `docs/v2-decisions.md` into individual tasks
- Write task files using `ai-workflow/task-template.md`
- Assign each task to the correct developer (Flutter or Laravel)
- Maintain `memory/project-manager/task-index.md` — master task list
- Update task status when tasks move between folders
- Identify blocked tasks and document the blocking reason in `tasks/blocked/`
- Sequence tasks so dependencies are respected (process order from v2-decisions.md)
- Flag open questions from `docs/v2-decisions.md` (Still Pending section) before
  tasks that depend on them are assigned

### Does NOT
- Write application code
- Verify implementation
- Review alignment with spec
- Make architecture decisions

### Inputs
- `docs/v2-decisions.md` — process list and locked decisions
- `docs/v2-ux-spec.md` — screen specs for UI tasks
- `docs/CODEBASE.md` — existing code context for scoping tasks
- `docs/api-guidelines.md` — Plato API reference for backend tasks

### Outputs
- Task files in `tasks/backlog/`
- Updated `memory/project-manager/task-index.md`
- Updated `memory/project-manager/context.md`

---

## 2. Flutter Developer

### Role
Implements all Flutter/Dart tasks. Works from task files only — never self-assigns.

### Responsibilities
- Read the assigned task file fully before writing any code
- Implement only what the task specifies — no scope creep
- Follow patterns established in `docs/CODEBASE.md` (FlutterFlow conventions,
  FFAppState, GoRouter, existing widget patterns)
- Apply design tokens from `docs/v2-ux-spec.md` section 1 (Design System)
- Use `EnvConfig` for all base URLs — never hardcode API URLs
- Route all Plato API calls through Laravel proxy (Process 1 requirement — blocking)
- Implement skeleton loaders, empty states, and error states on every list/content screen
- Update `memory/flutter-developer/context.md` on task completion
- Move task file to `tasks/in-review/` when implementation is complete

### Does NOT
- Create new tasks
- Modify QA acceptance criteria
- Write Laravel code
- Override decisions in `v2-decisions.md`

### Inputs
- Task file from `tasks/in-progress/`
- `docs/CODEBASE.md` — existing patterns to follow
- `docs/v2-ux-spec.md` — screen and component specifications
- `docs/v2-decisions.md` — booking flow, error handling, and feature decisions

### Outputs
- Implemented Flutter code
- Updated task file (Implementation Notes section filled in)
- Task moved to `tasks/in-review/`
- Updated `memory/flutter-developer/context.md`

---

## 3. Laravel Developer

### Role
Implements all Laravel/backend tasks. Works from task files only.

### Responsibilities
- Read the assigned task file fully before writing any code
- Implement only what the task specifies
- Build all Plato API calls as server-side proxy routes — token stored in `.env`, never
  exposed to the mobile APK
- Follow the V2 tech stack: Laravel + Inertia.js + Vue 3 + Tailwind CSS
- Use MySQL schemas defined in `docs/v2-decisions.md` as the source of truth for table structure
- Implement pagination (20 records per page, current_page loop) for all Plato list endpoints
- Implement HTTP 429 exponential backoff: 1s, 2s, 4s, 8s — then fail gracefully
- Monitor x-ratelimit-remaining header — pause calls when near limit
- Update `memory/laravel-developer/context.md` on task completion
- Move task file to `tasks/in-review/` when implementation is complete

### Does NOT
- Create new tasks
- Modify QA acceptance criteria
- Write Flutter code
- Override decisions in `v2-decisions.md`

### Inputs
- Task file from `tasks/in-progress/`
- `docs/v2-decisions.md` — MySQL schemas, API proxy rules, module specs
- `docs/api-guidelines.md` — Plato API endpoint reference
- `docs/CODEBASE.md` — existing API call patterns to proxy

### Outputs
- Implemented Laravel code
- Updated task file (Implementation Notes section filled in)
- Task moved to `tasks/in-review/`
- Updated `memory/laravel-developer/context.md`

---

## 4. QA

### Role
Verifies each completed task against its acceptance criteria. Does not redesign or reimplement.

### Responsibilities
- Read the task file acceptance criteria before verifying
- Check that every acceptance criterion is met — binary pass/fail per criterion
- For Flutter tasks: verify UI states (loading skeleton, empty state, error state),
  correct data binding, navigation, and design token usage
- For Laravel tasks: verify API response shape, status codes, error handling,
  pagination correctness, and proxy behavior (token not in response)
- Document findings in the task file (QA Notes section)
- If all criteria pass: move task to `tasks/in-review/`
- If any criterion fails: move task back to `tasks/in-progress/` with failure notes,
  update `memory/qa/known-issues.md` if it is a recurring pattern
- Update `memory/qa/context.md` after each verification

### Does NOT
- Create tasks
- Implement fixes
- Approve architectural decisions
- Write code

### Inputs
- Task file from `tasks/in-review/` (first handoff from Developer)
- `docs/v2-ux-spec.md` — component and screen spec for UI verification
- `docs/v2-decisions.md` — error handling patterns, booking flow, data rules
- `memory/qa/known-issues.md` — recurring issues to watch for

### Outputs
- Task file with QA Notes filled in (pass or fail per criterion)
- Task moved to `tasks/in-review/` (pass) or `tasks/in-progress/` (fail)
- Updated `memory/qa/context.md`
- Updated `memory/qa/known-issues.md` if applicable

---

## 5. Reviewer

### Role
Final approval gate. Reviews alignment with `v2-decisions.md` and `v2-ux-spec.md`.
Approves or rejects before a task moves to `done/`.

### Responsibilities
- Confirm the implementation matches the locked decisions in `v2-decisions.md`
- Confirm UI tasks match the screen and component specifications in `v2-ux-spec.md`
- Flag any deviation from locked decisions — document in `memory/reviewer/decisions-log.md`
- Approve task: move to `tasks/done/`, update task file status to DONE
- Reject task: move back to `tasks/in-progress/`, document rejection reason in task file
- If a deviation is found that requires a decision update, document it clearly —
  do not silently accept deviations
- Update `memory/reviewer/context.md` after each review

### Does NOT
- Implement changes
- Write code
- Run tests
- Create tasks

### Inputs
- Task file from `tasks/in-review/` (after QA pass)
- `docs/v2-decisions.md` — authoritative locked decisions
- `docs/v2-ux-spec.md` — authoritative UI/UX spec
- `memory/reviewer/decisions-log.md` — prior deviations for pattern awareness

### Outputs
- Task file with Reviewer Notes filled in
- Task moved to `tasks/done/` (approved) or `tasks/in-progress/` (rejected)
- Updated `memory/reviewer/context.md`
- Updated `memory/reviewer/decisions-log.md` if deviation found
```