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
| P2-T01 | laravel-auth-role-setup | 2 | Step 1 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P2-T02 | mysql-schema | 2 | Step 2 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P2-T03 | branch-management-crud | 2 | Step 3 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P2-T04 | doctor-management-crud | 2 | Step 4 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P2-T05 | plato-api-proxy-layer | 2 | Step 5 | Laravel | laravel-developer | DONE | 2026-07-05 |
| P2-T06 | calendar-setup-systemsetup | 2 | Step 6 | Laravel | laravel-developer | IN-REVIEW | |
| P3-T01 | global-api-error-interceptor | 3 | Step 1 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T02 | pagination-helper | 3 | Step 2 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T03 | modified-since-strategy | 3 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T04 | exponential-backoff-429 | 3 | Step 4 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T05 | rate-limit-monitor | 3 | Step 5 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P3-T06 | laravel-proxy-url-audit | 3 | Step 6 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T01 | apply-design-system | 4 | Step 1 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T02 | bottom-nav-5-tabs | 4 | Step 2 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T03 | dynamic-doctor-list | 4 | Step 3 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T04 | home-screen-redesign | 4 | Step 4 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T05 | consolidate-profile-screen | 4 | Step 5 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P4-T06 | global-states | 4 | Step 6 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P5-T01 | verify-booking-flow-prerequisites | 5 | Step 1 | Both | laravel-developer | DONE | 2026-07-05 |
| P5-T02 | branch-selection-screen | 5 | Step 2 | Flutter | flutter-developer | DONE | 2026-07-05 |
| P5-T03 | doctor-selection-screen | 5 | Step 3 | Flutter | flutter-developer | BLOCKED | |
| P5-T04 | date-time-slot-selection | 5 | Step 4 | Flutter | flutter-developer | BACKLOG | |
| P5-T05 | booking-confirmation-screen | 5 | Step 5 | Flutter | flutter-developer | BACKLOG | |
| P5-T06 | whatsapp-redirect-after-booking | 5 | Step 6 | Flutter | flutter-developer | BACKLOG | |
| P5-T07 | admin-appointment-creation | 5 | Step 7 | Laravel | laravel-developer | BACKLOG | |
| P5-T08 | appointment-confirmation-notification | 5 | Step 8 | Both | flutter-developer | BACKLOG | |
| P5-T09 | appointments-tab-display | 5 | Step 9 | Flutter | flutter-developer | BACKLOG | |

**Parallel tracks:**
- Process 5 tasks have the following dependency chain:
  - P5-T01 (verify prerequisites) — validation task, blocks all subsequent P5 tasks
  - P5-T02 (branch selection) — depends on P5-T01
  - P5-T03 (doctor selection) — depends on P5-T02
  - P5-T04 (date/time slots) — depends on P5-T03
  - P5-T05 (confirmation) — depends on P5-T04
  - P5-T06 (WhatsApp redirect) — depends on P5-T05
  - P5-T07 (admin appointment creation) — depends on P5-T06
  - P5-T08 (confirmation notification) — depends on P5-T07
  - P5-T09 (appointments tab) — depends on P5-T08
- Process 4 tasks have the following dependency chain:
  - P4-T01 (design system) — foundation for all subsequent UI tasks (no dependencies)
  - P4-T02 (nav 5 tabs) — depends on P4-T01 (needs design system for nav colors)
  - P4-T03 (doctor list) — depends on P4-T01 (needs design system for cards/sheets)
  - P4-T04 (home screen) — depends on P4-T01, P4-T02, P4-T03 (needs design, nav, and doctor components)
  - P4-T05 (profile) — depends on P4-T01, P4-T02 (needs design and nav)
  - P4-T06 (global states) — depends on P4-T01 (needs design tokens; applied across all screens)

**Note:** Agentic AI Director is now active via GitHub Actions + Telegram approval.
Bot URL: https://heclinic.cyberoket.cloud/bot/webhook
