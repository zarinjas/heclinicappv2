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
| P3-T06 | laravel-proxy-url-audit | 3 | Step 6 | Flutter | flutter-developer | BACKLOG | — |

**Parallel tracks:**
- Process 3 all tasks are sequential (each depends on the previous):
  - P3-T01 → P3-T02 → P3-T03 → P3-T04 → P3-T05 → P3-T06
- P3-T01 (error interceptor) — foundation for all subsequent tasks
- P3-T02 (pagination) — depends on interceptor
- P3-T03 (modified_since) — depends on pagination helper
- P3-T04 (429 backoff) — depends on interceptor
- P3-T05 (rate limit monitor) — depends on interceptor + backoff
- P3-T06 (proxy URL audit) — verification after all refactoring done

**Note:** Agentic AI Director is now active via GitHub Actions + Telegram approval.
Bot URL: https://heclinic.cyberoket.cloud/bot/webhook
