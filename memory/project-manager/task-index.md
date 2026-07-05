# Task Index

Last Updated: 2026-07-05

| Task ID | Slug | Process | Step | Type | Assigned To | State | Done Date |
|---------|------|---------|------|------|-------------|-------|-----------|
| P1-T01 | add-laravel-proxy-env-token | 1 | Step 1 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P1-T02 | reroute-platome-api-calls-to-laravel-proxy | 1 | Step 2 | Flutter | flutter-developer | DONE | 2026-07-04 |
| P1-T03 | fix-minsdk-version | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-04 |
| P1-T04 | fix-hardcoded-appointment-id | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T05 | remove-test-page | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T06 | remove-duplicate-api-call-classes | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T07 | remove-duplicate-auth-pages | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T08 | remove-duplicate-profile-pages | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T09 | remove-duplicate-booking-pages | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P1-T10 | remove-hardcoded-doctor-modals | 1 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T01 | global-api-error-interceptor | 3 | Step 1 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T02 | pagination-helper | 3 | Step 2 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T03 | modified-since-strategy | 3 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T04 | exponential-backoff-429 | 3 | Step 4 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T05 | rate-limit-monitor | 3 | Step 5 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T06 | laravel-proxy-url-audit | 3 | Step 6 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T01 | apply-design-system | 4 | Step 1 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T02 | bottom-nav-5-tabs | 4 | Step 2 | Flutter | flutter-developer | IN-PROGRESS | — |
| P4-T03 | dynamic-doctor-list | 4 | Step 3 | Flutter | flutter-developer | BACKLOG | — |
| P4-T04 | home-screen-redesign | 4 | Step 4 | Flutter | flutter-developer | BACKLOG | — |
| P4-T05 | consolidate-profile-screen | 4 | Step 5 | Flutter | flutter-developer | BACKLOG | — |
| P4-T06 | global-states | 4 | Step 6 | Flutter | flutter-developer | BACKLOG | — |

**Parallel tracks:**
- Process 4 tasks have the following dependency chain:
  - P4-T01 (design system) — foundation for all subsequent UI tasks (no dependencies)
  - P4-T02 (nav 5 tabs) — depends on P4-T01 (needs design system for nav colors)
  - P4-T03 (doctor list) — depends on P4-T01 (needs design system for cards/sheets)
  - P4-T04 (home screen) — depends on P4-T01, P4-T02, P4-T03 (needs design, nav, and doctor components)
  - P4-T05 (profile) — depends on P4-T01, P4-T02 (needs design and nav)
  - P4-T06 (global states) — depends on P4-T01 (needs design tokens; applied across all screens)

**Note:** Agentic AI Director is now active via GitHub Actions + Telegram approval.
Bot URL: https://heclinic.cyberoket.cloud/bot/webhook
