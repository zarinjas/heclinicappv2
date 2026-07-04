# Task Workflow

> Defines the lifecycle of every task from creation to completion.

> **Single entry point:** The AI Director (`ai-workflow/director.md`) is the only
> entity that initiates workflow steps. No agent self-activates. All state transitions
> are triggered and validated by the Director before the next step begins.

---

## Task States

```
BACKLOG → IN-PROGRESS → IN-REVIEW → IN-REVIEW (Reviewer) → DONE
                ↑              |
                └──── FAIL ────┘ (QA returns to IN-PROGRESS)

Any state → BLOCKED (when external dependency prevents progress)
BLOCKED → BACKLOG (when dependency is resolved)
```

| State | Folder | Owned By |
|-------|--------|----------|
| BACKLOG | `tasks/backlog/` | Project Manager |
| IN-PROGRESS | `tasks/in-progress/` | Developer (Flutter or Laravel) |
| IN-REVIEW | `tasks/in-review/` | QA (first), then Reviewer |
| DONE | `tasks/done/` | Reviewer |
| BLOCKED | `tasks/blocked/` | Project Manager |

---

## Step-by-Step Lifecycle

> Each step below is triggered by the AI Director. Agents act only when called.

### Step 0 — Director: Scan and Select

1. Read all task folders and `memory/project-manager/task-index.md`
2. Identify the highest-priority actionable task using the Selection Rules in `director.md`
3. Determine which agent to call based on the task's current state
4. Proceed to the relevant step below
5. After agent completes work, validate output before advancing state
6. If task reaches DONE, present summary to user and wait for approval before looping

### Step 1 — Project Manager: Task Creation

1. Identify the next task from the current process in `docs/v2-decisions.md`
2. Check `memory/project-manager/task-index.md` — confirm no duplicate exists
3. Check dependencies — is the preceding task in `tasks/done/`? If not, do not create this task yet
4. Create task file using `ai-workflow/task-template.md`
5. Save to `tasks/backlog/{task-id}_{slug}.md`
6. Add entry to `memory/project-manager/task-index.md`
7. Update `memory/project-manager/context.md`

### Step 2 — Project Manager: Task Assignment

1. Confirm the developer's `memory/{developer}/context.md` shows no active task
2. Move task file from `tasks/backlog/` to `tasks/in-progress/`
3. Set `Assigned To` and `Assigned Date` in task file header
4. Update `memory/project-manager/task-index.md`

### Step 3 — Developer: Implementation

1. Read the full task file
2. Read referenced documents (listed in task Context section)
3. Implement only the scope defined in the task
4. Fill in the `Implementation Notes` section of the task file
5. Move task file from `tasks/in-progress/` to `tasks/in-review/`
6. Update `memory/{developer}/context.md` — clear active task, note completion

### Step 4 — QA: Verification

1. Read the task file — focus on Acceptance Criteria
2. Verify each criterion — record PASS or FAIL per item in `QA Notes`
3. All criteria PASS:
   - Mark QA status as PASSED in task file
   - Keep file in `tasks/in-review/` (Reviewer picks it up next)
   - Update `memory/qa/context.md`
4. Any criterion FAIL:
   - Mark QA status as FAILED in task file
   - Document each failure clearly in `QA Notes`
   - Move file back to `tasks/in-progress/`
   - Update `memory/qa/context.md` and `memory/qa/known-issues.md` if recurring

### Step 5 — Reviewer: Final Review

1. Read the full task file including Implementation Notes and QA Notes
2. Verify alignment with `docs/v2-decisions.md` and `docs/v2-ux-spec.md`
3. APPROVED:
   - Set status to DONE in task file
   - Move file to `tasks/done/`
   - Update `memory/reviewer/context.md`
   - Update `memory/project-manager/task-index.md` (PM is notified via index)
4. REJECTED:
   - Document rejection reason in `Reviewer Notes` section of task file
   - Move file back to `tasks/in-progress/`
   - Update `memory/reviewer/context.md`
   - Log deviation in `memory/reviewer/decisions-log.md` if a spec conflict is found

---

## Blocked Task Protocol

A task becomes BLOCKED when it cannot proceed due to an external dependency.

1. Developer or PM signals the block to the Director
2. Director instructs PM to move task file to `tasks/blocked/`
3. PM documents the block in the `Blocked Reason` field of the task file
4. PM notes the block in `memory/project-manager/context.md`
5. When block is resolved: PM moves task back to `tasks/backlog/`, clears the block reason

Common block triggers:
- Open question from `docs/v2-decisions.md` (Still Pending section) not yet resolved
- Dependency task not yet in `tasks/done/`
- External API access not available (e.g., Plato GET /systemsetup access unconfirmed)
- Design mockup not yet approved by client

---

## Human Approval Gate

After every task reaches DONE, the Director pauses the loop and presents a summary
to the user. The summary includes: task ID, what was built, QA result, Reviewer
decision, and any deviations logged in `memory/reviewer/decisions-log.md`.

The Director does not start the next task until the user explicitly approves.

If the user rejects the completed task:
- Director routes the task back to `tasks/in-progress/`
- Rejection reason is recorded in the task file under Reviewer Notes
- Developer is re-assigned on the next loop iteration

---

## Process Gate Rule

Before Project Manager creates tasks for Process N+1:
- Every task belonging to Process N must be in `tasks/done/`
- If any Process N task is blocked, the gate does not open until the block is resolved

This enforces the dependency order defined in `docs/v2-decisions.md`.

---

## Parallel Tasks Rule

Tasks within the same process may run in parallel if:
- They are assigned to different developers (one Flutter, one Laravel)
- They have no direct dependency on each other

Project Manager marks parallel tasks with `Parallel: YES` in the task header.
If one parallel task fails QA and the other depends on it, PM must move the
dependent task to BLOCKED.
```