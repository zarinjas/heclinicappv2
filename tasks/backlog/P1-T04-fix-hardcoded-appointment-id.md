# P1-T04 — Fix GetAppointmentDetailsCall: Replace Hardcoded Appointment ID with Dynamic Parameter

## Task ID
P1-T04

## Title
Fix GetAppointmentDetailsCall: Replace Hardcoded Appointment ID with Dynamic Parameter

## Description
`GetAppointmentDetailsCall` in `lib/backend/api_requests/api_calls.dart` has a hardcoded appointment ID (`a052e78b3a5547bba54ddbbc83619e93`) embedded directly in the URL. This means the endpoint always fetches the same appointment regardless of which appointment the user is viewing — the Appointment Detail screen is effectively broken for all users.

This task fixes the call class to accept a dynamic `appointmentId` parameter:

1. Update `GetAppointmentDetailsCall.call()` to accept an `appointmentId` String parameter.
2. Replace the hardcoded ID in the URL with the dynamic parameter.
3. Find all call sites where `GetAppointmentDetailsCall.call()` is invoked and update them to pass the correct appointment ID from context (from the appointment list response, from `FFAppState`, or from a route parameter).
4. Update the mock server (`mock_server/index.js`) to handle `GET /platom/appointment/:id` with a dynamic ID and return appropriate mock data.

## Dependencies
- None — this is an isolated fix in `api_calls.dart` and its call sites. Can be done in parallel with P1-T01 and P1-T02.
- After P1-T02 is complete, verify this call still works through the Laravel proxy.

## Expected Files
**Flutter (this repo):**
- `lib/backend/api_requests/api_calls.dart` — update `GetAppointmentDetailsCall` to use dynamic `appointmentId` parameter
- Any page/widget file that calls `GetAppointmentDetailsCall.call()` — update to pass correct appointment ID

**Mock server:**
- `mock_server/index.js` — update or add route `GET /platom/appointment/:id` to return mock appointment detail by ID

## Acceptance Criteria
- [ ] The string `a052e78b3a5547bba54ddbbc83619e93` does NOT appear anywhere in the codebase after this change.
- [ ] `GetAppointmentDetailsCall.call()` accepts an `appointmentId` String parameter.
- [ ] The constructed URL uses the dynamic `appointmentId` parameter: `/{db}/appointment/{appointmentId}`.
- [ ] All call sites pass a real appointment ID from the appointment list data.
- [ ] Tapping an appointment in the appointment list navigates to the detail screen and loads the correct appointment data.
- [ ] Mock server returns appointment detail correctly for any appointment ID passed.
- [ ] No regression in `GetAppointmentCall` or `GetAppointmentUpcomingCall`.

## Priority
HIGH — appointment detail screen is completely non-functional without this fix

## Estimated Effort
2–3 hours

## Status
Backlog