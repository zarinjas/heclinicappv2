# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
None.

## Last Completed Task
P5-T01 — Verify Booking Flow Prerequisites (verified proxy ready, moved to IN-REVIEW)

## Known Constraints
- Plato API token lives in .env only — never exposed in any API response, log, or mobile code
- All Plato list endpoints must implement pagination: current_page loop until empty response
- HTTP 429 handling: exponential backoff 1s → 2s → 4s → 8s, then fail gracefully with clear message
- Monitor x-ratelimit-remaining header — pause calls when near limit
- MySQL schemas in v2-decisions.md are authoritative — do not alter column names
- Tech stack: Laravel + Inertia.js + Vue 3 + Tailwind CSS + Alpine.js
- Admin Panel timeout: 10s per Plato request, retry once, then fail with message

## Pending Items
None.