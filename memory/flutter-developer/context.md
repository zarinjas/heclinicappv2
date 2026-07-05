# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P6-T01 — Health Tab Scaffold (IN-REVIEW)

## Recent Work
- P6-T01 — Health Tab Scaffold (IN-REVIEW): Rewrote `lib/front_page/reports/reports_widget.dart` with V2 design system. Replaced old Visit/MyLabs/MyDocuments tabs with Records/Vitals/Documents using V2 tokens (AppColors, AppSpacing, AppRadius). AppBar: "My Health", no back arrow, primary background. TabBar: accent indicator, white text, Plus Jakarta Sans 14px w600. Tab bodies: 4× SkeletonListTile placeholders.
- P5-T09 — Appointments Tab Display (DONE): Created `lib/pages/appointments/appointments_screen.dart` with Upcoming/Past tabs, appointment cards with 4px color bar, status chips, skeleton loading, pull-to-refresh, empty/error states. Added `title`, `doctorCode`, `locationCode` parsers to `GetAppointmentCall`. Wired `AppointmentsScreenWidget` into NavBarPage and GoRouter replacing `MyBookingPageWidget`.
- P5-T08 — Appointment Confirmation Notification (DONE): Updated `push_notifications_handler.dart` to detect `type: "appointment_confirmed"` in FCM payload, navigate to MyBookingPage, increment `coutnnotif`. Rewrote `setup_f_c_m_foreground_handler.dart` for appointment notification handling in foreground with dedicated channel, badge increment, and tap-to-navigate. Added `incrementNotifCount()` and `resetNotifCount()` to `app_state.dart`. Handles cold start, background, and foreground notification scenarios.
- P5-T06 — WhatsApp Redirect After Booking (IN-REVIEW): Created `lib/utils/whatsapp_helper.dart` with `buildPreFilledMessage()`, `buildDeepLink()`, and `getWhatsAppInstallUrl()` utilities. Added `selectedBranchWhatsApp` to `BookingFlowModel`, `phone` field to `BranchItem`, `telephone` extractor to `GetproviderCall`. Replaced stub `_onBookViaWhatsApp` with real WhatsApp deep-link redirect using `url_launcher`. Error dialog when WhatsApp not installed.
- P5-T05 — Booking Confirmation Screen (DONE): Created BookingConfirmationScreenWidget (StatelessWidget) with summary card (Branch/Doctor/Date/Time/Patient), step indicator, teal info disclaimer banner, "Book via WhatsApp" primary button. Patient data from FFAppState (name, nationalman).
- P5-T03 — Doctor Selection Screen (DONE): Re-implemented with new GetDoctorsCall (Laravel `/api/v2/config/doctors`) for branch_id + visible=true filtering.
- P5-T02 — Branch Selection Screen (DONE): Created BranchSelectionScreenWidget with step indicator, API-driven branch list from GET /facility.
- P4-T06 — Global States (DONE): Created skeleton_loaders, empty_state_widget, error_state_widget, inline_spinner
- P4-T05 — Consolidate Profile Screen (DONE): Rewrote profile_widget.dart with V2 layout
- P4-T04 — Home Screen Redesign (DONE): Rewrote HomepageNewWidget with V2 design system
- P4-T03 — Dynamic Doctor List (DONE): Created DoctorCardWidget, DoctorDetailSheet, DoctorListWidget

## Key Files
- `lib/backend/push_notifications/push_notifications_handler.dart` — UPDATED: appointment_confirmed type handling, badge increment, MyBookingPage navigation
- `lib/custom_code/actions/setup_f_c_m_foreground_handler.dart` — UPDATED: appointment foreground notification, badge increment, tap navigation
- `lib/app_state.dart` — UPDATED: added incrementNotifCount(), resetNotifCount() helpers
- `lib/utils/whatsapp_helper.dart` — NEW: WhatsApp deep-link building utilities
- `lib/pages/booking/confirmation_screen.dart` — UPDATED: real WhatsApp redirect implementation
- `lib/pages/booking/booking_flow_model.dart` — UPDATED: added selectedBranchWhatsApp field
- `lib/pages/booking/branch_selection_screen.dart` — UPDATED: added phone field to BranchItem
- `lib/backend/api_requests/api_calls.dart` — UPDATED: added telephone extractor to GetproviderCall
- `lib/pages/booking/doctor_selection_screen.dart` — uses GetDoctorsCall with branch/visible params
