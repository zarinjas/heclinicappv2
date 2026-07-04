# Task Template

> Copy this template when creating a new task file.
> Fill in every section. Do not leave sections blank — write N/A if not applicable.
> File naming: see `ai-workflow/conventions.md`.

---

```markdown
# {Task Title}

## Header

| Field | Value |
|-------|-------|
| Task ID | T{NNN} |
| Slug | {short-hyphenated-description} |
| Process | {N} — {Process Name from v2-decisions.md} |
| Process Step | Step {N} |
| Type | Flutter / Laravel / Both |
| Assigned To | flutter-developer / laravel-developer |
| Assigned Date | {YYYY-MM-DD} |
| Status | BACKLOG / IN-PROGRESS / IN-REVIEW / DONE / BLOCKED |
| Parallel | YES / NO |
| Depends On | {Task ID} or N/A |
| Blocked Reason | {reason} or N/A |

---

## Description

{1–3 sentences describing what this task does and why it exists.
Ground it in the relevant section of v2-decisions.md or v2-ux-spec.md.}

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — {relevant section}
- `docs/v2-ux-spec.md` — {relevant screen or component section}
- `docs/CODEBASE.md` — {relevant existing code section}
- `docs/api-guidelines.md` — {relevant endpoint section, or N/A}

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- {specific file, feature, or behavior to implement}
- {specific file, feature, or behavior to implement}

### Out of Scope
- {what this task explicitly does NOT cover}
- {what this task explicitly does NOT cover}

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints,
> and schema fields from the project docs.

### Files to Create or Modify
- `{file path}` — {what to do}
- `{file path}` — {what to do}

### API Endpoints
- `{METHOD} {endpoint}` — {purpose}

### Data / Schema
{Relevant MySQL table columns, Firestore fields, or FFAppState variables.
Copy from v2-decisions.md if a schema is defined there.}

### UI Components (Flutter tasks only)
{Reference component names and states from v2-ux-spec.md.
List: loading state, empty state, error state, if applicable.}

### Constraints
- {Any hard constraint from v2-decisions.md that must be respected}
- {Example: All Plato calls must route through Laravel proxy}

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.
> Write them so a verifier who did not write the code can check them independently.

- [ ] {Criterion 1 — specific and testable}
- [ ] {Criterion 2 — specific and testable}
- [ ] {Criterion 3 — specific and testable}

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
{Brief summary of what was implemented.}

### Files Changed
- `{file path}` — {what changed}

### Decisions Made During Implementation
{Any implementation-level decision that was not specified in the task.
Flag anything that might conflict with v2-decisions.md.}

### Known Limitations
{Anything left incomplete or deferred. Be honest.}

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {Criterion 1} — PASS / FAIL — {note if fail}
- [ ] {Criterion 2} — PASS / FAIL — {note if fail}
- [ ] {Criterion 3} — PASS / FAIL — {note if fail}

### Failure Details
{If FAILED: describe what was wrong and what needs to be fixed.
Be specific enough that the developer can fix without asking questions.}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason
{If REJECTED: describe the specific deviation from v2-decisions.md or v2-ux-spec.md.
Reference the exact decision number or screen name.}
```