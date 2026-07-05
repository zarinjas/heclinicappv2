# Remove Unused Firebase Functions Dependencies

## Header

| Field | Value |
|-------|-------|
| Task ID | T07 |
| Slug | remove-unused-firebase-deps |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 7 |
| Type | Both |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Remove 10 unused npm packages from the Firebase Functions `package.json` that were installed but never used in the codebase. These include payment SDKs (braintree, stripe, razorpay), AI/LLM libraries (langchain packages), and other unused packages (mux-node, onesignal). Also remove any stale import references in `index.js` and any related dead code. This is a cleanup task (LIGHTWEIGHT) — no new functionality.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 7
- `docs/CODEBASE.md` — Known Issue #12: Unused Firebase deps
- Current file: `firebase/functions/package.json`
- Current file: `firebase/functions/index.js` (check for stale imports)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Remove the following packages from `firebase/functions/package.json` `dependencies`:
  - `braintree` (payment — not used)
  - `stripe` (payment — not used)
  - `razorpay` (payment — not used)
  - `@langchain/core` (AI — not used)
  - `@langchain/langgraph` (AI — not used)
  - `@langchain/openai` (AI — not used)
  - `@langchain/google-genai` (AI — not used)
  - `@langchain/anthropic` (AI — not used)
  - `@mux/mux-node` (video — not used)
  - `@onesignal/node-onesignal` (push — not used; using FCM)
- Remove any stale `require()` or `import` statements referencing these packages in `index.js`
- Run `npm prune --production` or verify `package-lock.json` is regenerated
- Verify no runtime errors by checking that `firebase-admin`, `firebase-functions`, `axios`, `qs` remain intact

### Out of Scope
- Refactoring Firebase Functions logic
- Adding new dependencies
- Deploying Firebase Functions (deployment is separate)
- CI/CD changes

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `firebase/functions/package.json` — MODIFY: remove 10 unused packages from `dependencies`
- `firebase/functions/package-lock.json` — REGENERATE: run `npm install` to update lockfile
- `firebase/functions/index.js` — MODIFY: remove stale imports (if any found for above packages)

### Packages to Keep (Do NOT Remove)
- `firebase-admin` — core Firebase SDK
- `firebase-functions` — Cloud Functions framework
- `axios` — HTTP client for Plato API calls
- `qs` — query string serialization

### Verification
```bash
cd firebase/functions
npm install  # regenerates package-lock.json without removed deps
node -e "require('./index.js')"  # verify no import errors
```

### Constraints
- Do NOT break the `addFcmToken`, `sendPushNotificationsTrigger`, or `onUserDeleted` functions
- Do NOT remove any package that IS used in imports
- Check `index.js` exhaustively before removing any package

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] All 10 unused packages removed from `package.json` dependencies
- [ ] `firebase-admin`, `firebase-functions`, `axios`, `qs` still present
- [ ] `npm install` succeeds without errors in `firebase/functions/`
- [ ] `index.js` has no stale `require()` calls to removed packages
- [ ] No packages were removed that are actively imported in `index.js`

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled}

### Files Changed
{To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] 10 packages removed — PENDING
- [ ] Core packages kept — PENDING
- [ ] npm install succeeds — PENDING
- [ ] No stale imports — PENDING
- [ ] No active imports removed — PENDING

### Failure Details
{N/A}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: PENDING

### Alignment Check
- v2-decisions.md alignment: PENDING
- v2-ux-spec.md alignment: PENDING

### Rejection Reason
{N/A}
