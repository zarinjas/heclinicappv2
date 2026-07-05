# Firestore Security Rules Audit and Tighten

## Header

| Field | Value |
|-------|-------|
| Task ID | T06 |
| Slug | firestore-security-rules |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 6 |
| Type | Both |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | N/A (Firestore rules are independent) |
| Blocked Reason | N/A |

---

## Description

Review and tighten the current Firestore security rules. The existing rules in `firebase/firestore.rules` allow unrestricted `create` and `read` access to all collections with no authentication checks. This task replaces the permissive rules with authentication-gated access: only authenticated users can read their own data, admin writes are restricted to server-side (Firebase Functions), and public collections (articles, videos) are read-only for authenticated users.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 6
- `docs/CODEBASE.md` — Firebase project `heclinicapps-8be27`, Firebase Auth providers
- Current rules: `firebase/firestore.rules` (74 lines, all collections allow `create: if true; read: if true`)
- Firebase Functions: `firebase/functions/index.js` — uses `firebase-admin` (bypasses rules)

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- Update ALL collection rules in `firebase/firestore.rules`:
  - `users/{document}` — authenticated users read/write own doc only; admin writes via server
  - `articles/{document}` — authenticated users read; server-only create/write
  - `videos/{document}` — authenticated users read; server-only create/write
  - `patients/{document}` — authenticated users read own patient data; server-only create/write
  - `otps/{document}` — server-only create; no client read (sensitive)
  - `branch/{document}` — authenticated users read; server-only create/write
  - `fcm/{document}` — authenticated users write own token; server read
  - `historynotif/{document}` — authenticated users read own notifications; server-only create/write
  - `biometric/{document}` — authenticated users read own; server-only create/write
  - `info/{document}` — authenticated users read; server-only create/write
- Add `request.auth != null` guard on all rules
- Add `request.auth.uid == userId` ownership checks where applicable
- Add data validation rules (e.g., required fields for writes)
- Test plan: verify mobile app still reads articles/videos/notifications after rules tighten

### Out of Scope
- Custom claims / admin role verification in Firestore rules (complex; use Firebase Functions for admin writes)
- Firestore indexes
- Firestore backup/restore configuration
- Storage rules (separate file)

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `firebase/firestore.rules` — REPLACE: tighten all collection rules

### Target Rule Design (Pseudocode)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Public read for authenticated users, server-only writes
    match /articles/{doc}      { allow read: if isAuthenticated(); allow write: if false; }
    match /videos/{doc}        { allow read: if isAuthenticated(); allow write: if false; }
    match /branch/{doc}        { allow read: if isAuthenticated(); allow write: if false; }
    match /info/{doc}          { allow read: if isAuthenticated(); allow write: if false; }

    // User-owned data
    match /users/{userId}      { allow read, write: if isOwner(userId); }
    match /fcm/{userId}        { allow read: if isOwner(userId); allow create: if isOwner(userId); }
    match /historynotif/{doc}  { allow read: if isOwner(resource.data.userId); allow write: if false; }
    match /biometric/{userId}  { allow read: if isOwner(userId); allow write: if false; }

    // Sensitive — server only
    match /patients/{doc}      { allow read: if isAuthenticated(); allow write: if false; }
    match /otps/{doc}          { allow read: if false; allow write: if false; }
  }
}
```

### Constraints
- Firebase Functions (admin SDK) bypasses all rules — admin writes are unaffected
- Mobile app Flutter code fetches `articles`, `videos`, `branch`, `historynotif` — all must still work after change
- Do NOT break existing production reads
- All writes from client are disabled — use Firebase Functions for mutations

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Unauthenticated user cannot read any Firestore collection (request fails with permission denied)
- [ ] Authenticated user can read `articles`, `videos`, `branch`, `info` collections
- [ ] Authenticated user can read and write only their own `users/{uid}` document
- [ ] Authenticated user cannot read another user's `users/{uid}` document
- [ ] `otps` collection is fully locked (no client read or write)
- [ ] `historynotif` — authenticated user can read own notifications (by userId match)
- [ ] `fcm` — authenticated user can read and create own FCM token
- [ ] Firebase Functions admin SDK writes are unaffected (bypass rules)
- [ ] Existing mobile app Flutter Firebase reads still function (no regression)

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Replaced permissive Firestore security rules (all collections allowed unrestricted create + read) with authentication-gated rules. Rules now require `request.auth != null` for all reads, disable all client-side writes (server/Firebase Functions only via admin SDK), and enforce ownership checks on user-scoped collections (`users`, `fcm`, `historynotif`).

### Files Changed
- `firebase/firestore.rules` — REPLACED: tightened all 10 collection rules with auth guards, ownership checks, and write restrictions

### Decisions Made During Implementation
- Used `id_patient` field (actual Firestore schema field name) instead of `userId` for `historynotif` and `fcm` ownership checks — matches the actual Dart record schemas
- `biometric` collection has no UID field — enforced authenticated read with no client writes (server creates via Firebase Functions)
- `fcm` collection uses field-level `id_patient` check rather than document ID matching (doc IDs are auto-generated, not Firebase UIDs)
- All client-side `create/update/delete` operations are disabled — writes must go through Firebase Functions (admin SDK bypasses rules)

### Known Limitations
- `biometric` collection cannot enforce per-user ownership at rule level without a `uid` field in documents — relies on Firebase Functions to scope writes correctly
- Custom claims (admin roles) are not implemented in Firestore rules — admin writes rely entirely on Firebase Functions server-side enforcement
- These rules require deployment to Firebase before taking effect (`firebase deploy --only firestore:rules`)

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] Unauthenticated denied — PENDING
- [ ] Auth user reads public — PENDING
- [ ] Own user doc read/write — PENDING
- [ ] Other user doc denied — PENDING
- [ ] OTPs locked — PENDING
- [ ] History notif by userId — PENDING
- [ ] FCM own token — PENDING
- [ ] Functions unaffected — PENDING
- [ ] Mobile app reads still work — PENDING

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
