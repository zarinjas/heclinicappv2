# He Clinic V2 — Task Index

> **Last Updated:** July 2026
> **Active Process:** Process 1 — Security and Foundation

---

## Process 1 — Security and Foundation (Blocking Everything)

| Task ID | Title | Priority | Effort | Status | Dependencies |
|---------|-------|----------|--------|--------|--------------|
| P1-T01 | Add Plato API Token to Laravel .env and Proxy Route Foundation | CRITICAL | 3–4 hrs | Backlog | None |
| P1-T02 | Reroute All PlatomeApiGroup Calls in Flutter to Laravel Proxy | CRITICAL | 3–4 hrs | Backlog | P1-T01 |
| P1-T03 | Fix minSdkVersion from 35 to 23 in android/app/build.gradle | CRITICAL | 1 hr | Backlog | None |
| P1-T04 | Fix GetAppointmentDetailsCall: Replace Hardcoded Appointment ID with Dynamic Parameter | HIGH | 2–3 hrs | Backlog | None |
| P1-T05 | Remove test_page/ from Production Codebase | MEDIUM | 1 hr | Backlog | None |
| P1-T06 | Remove Duplicate API Call Classes from api_calls.dart | MEDIUM | 1–2 hrs | Backlog | None |
| P1-T07 | Remove Duplicate Auth Pages (RegisterPageCopy) | MEDIUM | 1–2 hrs | Backlog | None |
| P1-T08 | Remove Duplicate Profile Pages (ProfileCopy) | MEDIUM | 2 hrs | Backlog | None |
| P1-T09 | Remove Duplicate Booking Pages (BookingPagecasse, SelectDatecase, SelectDateReshecedule) | MEDIUM | 2–3 hrs | Backlog | None |
| P1-T10 | Remove 17 Hardcoded Doctor Modal Components | MEDIUM | 3–4 hrs | Backlog | None |

---

## Execution Order — Process 1

```
Parallel track A (Critical — Security):     Parallel track B (Independent fixes):
  P1-T01  (Laravel proxy foundation)           P1-T03  (minSdkVersion fix)
     ↓                                          P1-T04  (hardcoded appointment ID)
  P1-T02  (Flutter reroute to proxy)            P1-T05  (remove test_page)
                                                P1-T06  (duplicate API classes)
                                                P1-T07  (duplicate auth pages)
                                                P1-T08  (duplicate profile pages)
                                                P1-T09  (duplicate booking pages)
                                                P1-T10  (hardcoded doctor modals)
```

**Rule:** P1-T02 cannot start until P1-T01 is complete and the Laravel proxy is live.
All other tasks in Process 1 are independent and can run in parallel.
P1-T07, P1-T08, and P1-T09 share edits to `nav.dart` and `index.dart` — do not run simultaneously.

---

## Process Status

| Process | Title | Status |
|---------|-------|--------|
| Process 1 | Security and Foundation | 🔵 In Progress |
| Process 2 | Laravel Admin Panel Scaffold | ⏳ Pending Process 1 |
| Process 3 | Mobile App: Data Layer Refactor | ⏳ Pending Process 1 |
| Process 4 | Mobile App: UI/UX Overhaul | ⏳ Pending Process 3 |
| Process 5 | Booking Flow | ⏳ Pending Process 2 + Process 4 |
| Process 6 | Health Tab | ⏳ Pending Process 3 |
| Process 7 | Admin Panel: Patient and Appointment Management | ⏳ Pending Process 2 |
| Process 8 | Notifications Module | ⏳ Pending Process 7 |
| Process 9 | CMS Module | ⏳ Pending Process 2 |
| Process 10 | Polish and Remaining Features | ⏳ Pending Process 3–9 |
| Process 11 | Loyalty Points System | ⏳ Pending Process 7 |

---

## Task Files

| Task ID | File |
|---------|------|
| P1-T01 | `tasks/backlog/P1-T01-add-laravel-proxy-env-token.md` |
| P1-T02 | `tasks/backlog/P1-T02-reroute-platome-api-calls-to-laravel-proxy.md` |
| P1-T03 | `tasks/backlog/P1-T03-fix-minsdk-version.md` |
| P1-T04 | `tasks/backlog/P1-T04-fix-hardcoded-appointment-id.md` |
| P1-T05 | `tasks/backlog/P1-T05-remove-test-page.md` |
| P1-T06 | `tasks/backlog/P1-T06-remove-duplicate-api-call-classes.md` |
| P1-T07 | `tasks/backlog/P1-T07-remove-duplicate-auth-pages.md` |
| P1-T08 | `tasks/backlog/P1-T08-remove-duplicate-profile-pages.md` |
| P1-T09 | `tasks/backlog/P1-T09-remove-duplicate-booking-pages.md` |
| P1-T10 | `tasks/backlog/P1-T10-remove-hardcoded-doctor-modals.md` |
