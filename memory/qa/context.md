# QA — Context

Last Updated: 2026-07-05

## Active Verification
None.

## Last Result
P1-T04 (fix-hardcoded-appointment-id) — QA PASSED (7/7). Hardcoded ID removed from api_calls.dart, `appointmentId` dynamic parameter added, mock server route `GET /platom/appointment/:id` added. No local call sites (FlutterFlow-managed). No regression on sibling API calls.

## Notes
Check known-issues.md before starting each verification — watch for recurring patterns.