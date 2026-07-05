# Project Manager — Context

Last Updated: 2026-07-04

## Current Process
Process 1 — Security and Foundation

## Active Tasks
P1-T07 — Remove Duplicate Auth Pages (RegisterPageCopy) — flutter-developer

## Blocked Tasks
None currently.

## Open Decisions (from v2-decisions.md — Still Pending)
- Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — blocks Process 8 Notifications
- GET /systemsetup access for He Clinic Plato account unconfirmed — blocks Process 2 Step 6
- Design mockup approval from client pending — blocks Process 4 UI Overhaul
- Flutter version upgrade timing undecided — blocks Process 4 UI Overhaul

## Next Task to Create
Process 1 Step 1 is fully defined (10 tasks). Next process creation: Process 2 — Laravel Admin Scaffold (after all Process 1 DONE).

## Agentic AI Setup
- AI Director workflow: `.github/workflows/agent-director.yml`
- Approval via Telegram: https://t.me/CyberocketBot
- Laravel proxy controller: `laravel/app/Http/Controllers/Api/PlatoProxyController.php`
- VPS bot server: `/var/www/heclinic-bot/` (PM2)

## Notes
Process 1 Track A (P1-T01, P1-T02) requires Laravel repo on VPS.
Process 1 Track B (P1-T03–P1-T10) are all Flutter tasks — ready to run immediately.
