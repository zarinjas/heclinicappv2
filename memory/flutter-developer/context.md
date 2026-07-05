# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Tasks
UI-P0-T16 — AppNavBar (IN-REVIEW): Created `lib/core/widgets/app_nav_bar.dart` with 5-tab bottom navigation, AppColors.primary background, Accent/accent active, 50% white inactive, shadowNav, notification badge, SafeArea-aware height

## Recent Work
- UI-P0-T16 — AppNavBar (IN-REVIEW): Created `lib/core/widgets/app_nav_bar.dart` with 5-tab bottom navigation (Home/Appointments/Health/Notifications/Profile), AppColors.primary background, AppColors.accent active color, 50% white inactive, AppTextStyles.caption labels, AppShadows.shadowNav elevation, notification badge on Notifications tab when notificationCount > 0. Uses Container with BoxDecoration for custom shadow. Height: 64px + bottomSafeArea.
- P6-T05 — Health Tab Pagination + modified_since (IN-REVIEW): Upgraded GetReportCall, GetVitalsGraphingCall, GetPatientDocumentsCall with PaginationHelper.fetchAllPages() and ModifiedSinceHelper patterns matching LetterCall reference. Added `forceRefresh` parameter to all three. Modified _loadRecords(), _loadVitals(), _loadDocuments() to skip skeleton during forceRefresh (stale-while-revalidate). Added RefreshIndicator to all three Health sub-tab list views with AppColors accent/primary styling.
- P6-T03 — Vitals Tab (IN-REVIEW): Added fl_chart dependency, GetVitalsGraphingCall API call class (GET /patient/{id}/graphing), VitalDataPoint/VitalType data models, vitals state fields in ReportsModel, _loadVitals() method with dynamic JSON key parsing and unit inference, _buildVitalChartCard() with LineChart rendering using V2 design tokens, _buildVitalsTab() with loading/empty/error/data states, lazy-load on Vitals tab switch. Replaced skeleton placeholder with real implementation.
- P6-T02 — Records Tab (DONE): Implemented Records inner tab with filter chips (All/Notes/Letters/MC), data fetching from GetReportCall, LetterCall, GetMedicalCertificateCall APIs, record cards with type-specific icons, loading/empty/error states, detail views (AlertReportWidget, HTML bottom sheet, WebViewX+). Updated reports_model.dart with RecordType/FilterType enums and HealthRecord data class.
- P6-T01 — Health Tab Scaffold (DONE): Rewrote `lib/front_page/reports/reports_widget.dart` with V2 design system. Replaced old Visit/MyLabs/MyDocuments tabs with Records/Vitals/Documents using V2 tokens (AppColors, AppSpacing, AppRadius). AppBar: "My Health", no back arrow, primary background. TabBar: accent indicator, white text, Plus Jakarta Sans 14px w600. Tab bodies: 4× SkeletonListTile placeholders.
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
- `lib/front_page/reports/reports_widget.dart` — UPDATED: _loadVitals(), _inferUnit(), _buildVitalChartCard(), _buildVitalsTab(), tab change listener
- `lib/front_page/reports/reports_model.dart` — UPDATED: VitalDataPoint, VitalType classes, vitals state fields
- `lib/backend/api_requests/api_calls.dart` — UPDATED: GetVitalsGraphingCall class
- `pubspec.yaml` — UPDATED: fl_chart 0.68.0 dependency
- `lib/backend/push_notifications/push_notifications_handler.dart` — UPDATED: appointment_confirmed type handling, badge increment, MyBookingPage navigation
- `lib/custom_code/actions/setup_f_c_m_foreground_handler.dart` — UPDATED: appointment foreground notification, badge increment, tap navigation
- `lib/app_state.dart` — UPDATED: added incrementNotifCount(), resetNotifCount() helpers
- `lib/utils/whatsapp_helper.dart` — NEW: WhatsApp deep-link building utilities
- `lib/pages/booking/confirmation_screen.dart` — UPDATED: real WhatsApp redirect implementation
- `lib/pages/booking/booking_flow_model.dart` — UPDATED: added selectedBranchWhatsApp field
- `lib/pages/booking/branch_selection_screen.dart` — UPDATED: added phone field to BranchItem
- `lib/backend/api_requests/api_calls.dart` — UPDATED: added telephone extractor to GetproviderCall
- `lib/pages/booking/doctor_selection_screen.dart` — uses GetDoctorsCall with branch/visible params
