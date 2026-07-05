# QA — Context

Last Updated: 2026-07-05

## Active Verification
None.

## Last Result
P1-T06 (remove-duplicate-api-call-classes) — QA PASSED (9/9). Verified: GetPatientbyidCopyCall deleted, LetterCopyCall renamed to GetInvoiceCall, all 16 call sites in reports_widget.dart and visits_widget.dart updated, zero remaining references to old class names. Implementation is a safe pure rename — no logic changes.

## Notes
Check known-issues.md before starting each verification — watch for recurring patterns.
