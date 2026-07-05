# He Clinic V2 — UI Migration Plan

> **Purpose:** Complete inventory of every screen and reusable component that must be redesigned for V2.
> **Reference:** `docs/ui-design-system.md` (design tokens), `docs/design-system-v2.png` (visual reference), `docs/v2-ux-spec.md` (screen specs)
> **Last Updated:** July 2026
> **Scope:** Flutter mobile app UI only. Business logic, API calls, and state management are unchanged.

---

## MIGRATION RULES

1. Build the design system (`core/theme/` + `core/widgets/`) **before** touching any screen.
2. Every screen must use shared components — no one-off styling in screen files.
3. Migrate screen-by-screen, not feature-by-feature.
4. Each migrated screen must pass the checklist: correct colors, correct typography, skeleton loader, empty state, error state, dark mode.
5. The old FlutterFlow-style widgets (`FFButtonWidget`, `FlutterFlowTheme`, inline styles) are removed from each screen as it is migrated — not before.
6. Do not delete old screens until the new version is confirmed working.

---

## PHASE 0 — DESIGN SYSTEM FOUNDATION
> Must be 100% complete before any screen migration begins.

### Shared Components to Build

| # | Component | File | Description |
|---|-----------|------|-------------|
| 0.1 | Color tokens | `lib/core/theme/app_colors.dart` | All color constants from design system |
| 0.2 | Text styles | `lib/core/theme/app_text_styles.dart` | Plus Jakarta Sans scale |
| 0.3 | Spacing + radius + shadows | `lib/core/theme/app_spacing.dart`, `app_radius.dart`, `app_shadows.dart` | All dimensional constants |
| 0.4 | App theme | `lib/core/theme/app_theme.dart` | `ThemeData` light + dark, registered font, input decoration theme |
| 0.5 | AppButton | `lib/core/widgets/app_button.dart` | Primary, Secondary, Ghost, Destructive, WhatsApp, Disabled, Loading states |
| 0.6 | AppInput | `lib/core/widgets/app_input.dart` | Text field with label, error, focus, password toggle, helper text |
| 0.7 | AppCard | `lib/core/widgets/app_card.dart` | Base card with surface bg, radius, shadow, border |
| 0.8 | AppChip | `lib/core/widgets/app_chip.dart` | Status chips (Confirmed/Pending/Cancelled/Completed), Filter chips |
| 0.9 | AppSkeleton | `lib/core/widgets/app_skeleton.dart` | Shimmer base + list item, card, slider, doctor, video presets |
| 0.10 | AppBottomSheet | `lib/core/widgets/app_bottom_sheet.dart` | Standard bottom sheet wrapper with handle bar, spring animation |
| 0.11 | AppDialog | `lib/core/widgets/app_dialog.dart` | Confirmation, Success, Loading, Redemption code modal variants |
| 0.12 | AppToast | `lib/core/widgets/app_toast.dart` | Success, Error, Warning, Info toast with auto-dismiss |
| 0.13 | AppEmptyState | `lib/core/widgets/app_empty_state.dart` | Illustration + title + subtitle + optional CTA |
| 0.14 | AppErrorState | `lib/core/widgets/app_error_state.dart` | Error icon + message + Try Again button |
| 0.15 | AppBar variants | `lib/core/widgets/app_app_bar.dart` | Main tab app bar (logo + bell), Sub-page app bar (back + title) |
| 0.16 | AppNavBar | `lib/core/widgets/app_nav_bar.dart` | 5-tab bottom nav (Home, Appointments, Health, Notifications, Profile) |

---

## PHASE 1 — REUSABLE FEATURE COMPONENTS
> Build after Phase 0. These are domain-specific but shared across multiple screens.

| # | Component | File | Used By |
|---|-----------|------|---------|
| 1.1 | AppointmentCard | `lib/core/widgets/appointment_card.dart` | Appointments tab, Home (upcoming), Appointment Detail |
| 1.2 | DoctorCard | `lib/core/widgets/doctor_card.dart` | Home (horizontal scroll), Doctor list, Booking Step 2 |
| 1.3 | ArticleCard | `lib/core/widgets/article_card.dart` | Home (health tips), Articles list |
| 1.4 | VideoCard | `lib/core/widgets/video_card.dart` | Home (videos grid), Videos list |
| 1.5 | LoyaltyCard | `lib/core/widgets/loyalty_card.dart` | Home (points widget), My Points screen |
| 1.6 | HealthRecordCard | `lib/core/widgets/health_record_card.dart` | Health tab — Records, Letters, Lab results |
| 1.7 | HeroSlider | `lib/core/widgets/hero_slider.dart` | Home screen banner |
| 1.8 | QuickActionGrid | `lib/core/widgets/quick_action_grid.dart` | Home screen 2×2 grid |
| 1.9 | StepIndicator | `lib/core/widgets/step_indicator.dart` | Booking flow (4 steps), Register (2 steps) |
| 1.10 | OtpInputRow | `lib/core/widgets/otp_input_row.dart` | Forgot Password step 2 |
| 1.11 | SectionHeader | `lib/core/widgets/section_header.dart` | \"Section Title\" + \"See All\" row used across Home |
| 1.12 | NotificationItem | `lib/core/widgets/notification_item.dart` | Notifications tab list |
| 1.13 | TransactionItem | `lib/core/widgets/transaction_item.dart` | My Points — transaction history list |
| 1.14 | BranchCard | `lib/core/widgets/branch_card.dart` | Booking Step 1 — branch selection |
| 1.15 | TimeSlotChip | `lib/core/widgets/time_slot_chip.dart` | Booking Step 3 — time selection |
| 1.16 | VitalsChart | `lib/core/widgets/vitals_chart.dart` | Health tab — Vitals inner tab |
| 1.17 | DocumentItem | `lib/core/widgets/document_item.dart` | Health tab — Documents inner tab |
| 1.18 | OfflineBanner | `lib/core/widgets/offline_banner.dart` | Global top banner when no internet |

---

## PHASE 2 — AUTH SCREENS

| # | Screen | Current File(s) | New File | Priority |
|---|--------|----------------|----------|----------|
| 2.1 | Splash | `front_page/splash_page/` | `lib/features/auth/splash_screen.dart` | High |
| 2.2 | Onboarding | `on_boarding_new/` | `lib/features/auth/onboarding_screen.dart` | High |
| 2.3 | Welcome / Landing | `auth_page/` (entry) | `lib/features/auth/welcome_screen.dart` | High |
| 2.4 | Login | `auth_page/login*/` | `lib/features/auth/login_screen.dart` | High |
| 2.5 | Register — Step 1 | `auth_page/register*/` | `lib/features/auth/register_step1_screen.dart` | High |
| 2.6 | Register — Step 2 | `auth_page/register*/` | `lib/features/auth/register_step2_screen.dart` | High |
| 2.7 | Forgot Password — Step 1 | `auth_page/forgot*/` | `lib/features/auth/forgot_email_screen.dart` | High |
| 2.8 | Forgot Password — Step 2 (OTP) | `auth_page/forgot*/` | `lib/features/auth/forgot_otp_screen.dart` | High |
| 2.9 | Forgot Password — Step 3 (New PW) | `auth_page/forgot*/` | `lib/features/auth/forgot_newpassword_screen.dart` | High |
| 2.10 | First-time Password Change | `auth_page/` | `lib/features/auth/first_change_password_screen.dart` | Medium |

### Auth Screen Migration Notes

- **Splash:** Remove FlutterFlow animation library dependency. Use `flutter_animate` fade-in on He Clinic logo. Background: primary (#131C3C). No skip button.
- **Onboarding:** 3 slides, `PageView`, dot indicator, Skip + Next + Get Started. Replace all hardcoded colors with tokens.
- **Login:** Add biometric auto-prompt on load (existing `local_auth` logic preserved). Replace `FFButtonWidget` with `AppButton`. Replace styled `TextField` with `AppInput`.
- **Register:** 2-step flow with `StepIndicator` component. Preserve existing multipart API call logic. Replace all form widgets with `AppInput`.
- **Forgot Password:** 3-step flow. OTP step uses new `OtpInputRow` component. Countdown timer preserved.

---

## PHASE 3 — HOME SCREEN

| # | Screen / Section | Current File | New File | Priority |
|---|-----------------|-------------|----------|----------|
| 3.1 | Home Screen (shell) | `front_page/homepage_new/` | `lib/features/home/home_screen.dart` | Critical |
| 3.2 | Hero Slider section | inline in homepage | `HeroSlider` component (Phase 1) | Critical |
| 3.3 | Quick Actions section | inline in homepage | `QuickActionGrid` component (Phase 1) | Critical |
| 3.4 | Upcoming Appointment section | inline in homepage | `AppointmentCard` component (Phase 1) | Critical |
| 3.5 | Loyalty Points section | — new feature — | `LoyaltyCard` component (Phase 1) | High |
| 3.6 | Our Doctors section | inline in homepage | `DoctorCard` component (Phase 1) | High |
| 3.7 | Health Articles section | inline in homepage | `ArticleCard` component (Phase 1) | High |
| 3.8 | Health Videos section | inline in homepage | `VideoCard` component (Phase 1) | High |

### Home Screen Migration Notes

- Greeting text: \"Good morning/evening, {Name}\" — use `heading1` + `primary` color.
- Section headers use `SectionHeader` component (title + \"See All\" tap).
- Hero slider: dynamic from CMS API. Skeleton while loading. Hidden if 0 sliders.
- Doctors section: horizontal `ListView`, `is_visible_in_app = true` only.
- Videos section: 2-column grid, max 4 shown on home. Hidden entirely if 0 videos.
- Loyalty card: hidden if patient has no loyalty account yet.
- Remove all hardcoded doctor modals (24 components in `component/` directory). Replace with single `DoctorDetailBottomSheet`.

---

## PHASE 4 — BOOKING FLOW SCREENS

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 4.1 | Booking Entry / Select Branch | `booking_page/booking_page/` | `lib/features/booking/booking_branch_screen.dart` | High |
| 4.2 | Select Doctor | `booking_page/` (partial) | `lib/features/booking/booking_doctor_screen.dart` | High |
| 4.3 | Select Date & Time | `booking_page/select_date*/` | `lib/features/booking/booking_datetime_screen.dart` | High |
| 4.4 | Confirm & WhatsApp | `booking_page/` | `lib/features/booking/booking_confirm_screen.dart` | High |
| 4.5 | My Bookings / Appointments List | `booking_page/my_booking*/` | `lib/features/booking/my_bookings_screen.dart` | High |
| 4.6 | Appointment Detail | `booking_page/` | `lib/features/booking/appointment_detail_screen.dart` | High |

### Booking Flow Migration Notes

- Step indicator at top of each step screen — use `StepIndicator` component.
- Step 1 (Branch): vertical `ListView` of `BranchCard`, accent border on selected. Skeleton while loading.
- Step 2 (Doctor): \"No Preference\" card always first. Remaining cards from API, `is_visible_in_app = true` only. Doctor photos from Admin Panel CMS.
- Step 3 (Date/Time): Calendar grid + `TimeSlotChip` grid below. Skeleton while fetching slots. Only future months selectable. Continue button disabled until slot selected.
- Step 4 (Confirm): Summary card + mandatory disclaimer banner (teal bg). WhatsApp `AppButton` opens deep link.
- Appointment Detail: Replace hardcoded appointment ID logic. Show Cancel Appointment `AppDialog` confirmation before action.

---

## PHASE 5 — APPOINTMENTS TAB

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 5.1 | Appointments Tab shell | `booking_page/` | `lib/features/appointments/appointments_screen.dart` | High |
| 5.2 | Upcoming tab | inline | inner tab in appointments_screen | High |
| 5.3 | Past tab | inline | inner tab in appointments_screen | High |
| 5.4 | Appointment Detail (shared) | — | `lib/features/appointments/appointment_detail_screen.dart` | High |

### Appointments Tab Notes

- Tab switcher: Upcoming / Past — use `AppChip`-style tab buttons, not default `TabBar`.
- Each list uses `AppointmentCard` component with appropriate status chip.
- Upcoming: \"X days to go\" badge top-right corner.
- Empty state: `AppEmptyState` with calendar illustration + \"Book Now\" CTA.
- Paginated list. Skeleton on initial load.

---

## PHASE 6 — HEALTH TAB

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 6.1 | Health Tab shell | `front_page/` (reports/letters) | `lib/features/health/health_screen.dart` | High |
| 6.2 | Records inner tab | `front_page/reports*/` | inner tab — records | High |
| 6.3 | Vitals inner tab | — new feature — | inner tab — vitals | Medium |
| 6.4 | Documents inner tab | — new feature — | inner tab — documents | Medium |
| 6.5 | Record Detail / Viewer | `front_page/` | `lib/features/health/record_detail_screen.dart` | High |

### Health Tab Migration Notes

- 3 inner tabs: Records / Vitals / Documents.
- Records: filter chips (All / Notes / Letters / Lab / MC). `HealthRecordCard` per item. Paginated.
- Vitals: `VitalsChart` component per vital type. Render dynamically from API response. Empty state if no data.
- Documents: `DocumentItem` list. Tap opens PDF viewer (`webview`). Skeleton while loading.
- All tabs: `AppEmptyState` and `AppErrorState` defined.

---

## PHASE 7 — NOTIFICATIONS TAB

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 7.1 | Notifications Tab | `front_page/` (notif) | `lib/features/notifications/notifications_screen.dart` | High |

### Notifications Tab Notes

- `NotificationItem` component per row.
- Unread items: subtle tinted background + blue dot indicator.
- Mark all read button in app bar trailing.
- Swipe-to-dismiss gesture on individual notifications.
- Tap notification → mark as read + navigate to deep link if present.
- `AppEmptyState`: \"You're all caught up\" with bell illustration.

---

## PHASE 8 — PROFILE TAB & SETTINGS

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 8.1 | Profile Tab | `front_page/profile_copy/` | `lib/features/profile/profile_screen.dart` | High |
| 8.2 | Edit Profile | `front_page/` | `lib/features/profile/edit_profile_screen.dart` | High |
| 8.3 | Change Password | `auth_page/` | `lib/features/profile/change_password_screen.dart` | Medium |
| 8.4 | Biometric Settings | `front_page/biometric*/` | `lib/features/profile/biometric_screen.dart` | Medium |
| 8.5 | Notification Preferences | — | `lib/features/profile/notification_prefs_screen.dart` | Medium |
| 8.6 | He Clinic Info | `info_page/hemed_info*/` | `lib/features/profile/clinic_info_screen.dart` | Low |
| 8.7 | Privacy Policy | `info_page/` | `lib/features/profile/privacy_screen.dart` | Low |
| 8.8 | Terms of Service | `info_page/` | `lib/features/profile/terms_screen.dart` | Low |

### Profile Migration Notes

- Consolidate `ProfileCopy` and any other profile variants into a single screen.
- Avatar with \"Change Photo\" overlay tap.
- Biometric toggle: preserve existing `local_auth` logic. Only replace UI.
- Log Out: `AppButton` destructive variant → `AppDialog` confirmation before action.
- Unsaved changes prompt on back navigation in Edit Profile.

---

## PHASE 9 — LOYALTY POINTS SCREENS

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 9.1 | My Points | — new feature — | `lib/features/loyalty/my_points_screen.dart` | Medium |
| 9.2 | Redeem Points (Bottom Sheet) | — new feature — | `lib/features/loyalty/redeem_points_sheet.dart` | Medium |
| 9.3 | Redemption Code Modal | — new feature — | `AppDialog` redemption variant (Phase 0.11) | Medium |

### Loyalty Notes

- `LoyaltyCard` (full-width variant on My Points, compact on Home).
- Tier progress bar: `LinearProgressIndicator` with accent color.
- Transaction history: filter chips (All / Earned / Redeemed / Expired), `TransactionItem` per row.
- Redeem bottom sheet: stepper input (100pt increments), real-time RM discount preview.
- Points balance refreshed after successful redemption.

---

## PHASE 10 — CONTENT SCREENS

| # | Screen | Current File | New File | Priority |
|---|--------|-------------|----------|----------|
| 10.1 | Articles List | `article_page/` | `lib/features/content/articles_list_screen.dart` | Medium |
| 10.2 | Article Detail | `article_page/` | `lib/features/content/article_detail_screen.dart` | Medium |
| 10.3 | Videos List | `content_media/` | `lib/features/content/videos_list_screen.dart` | Medium |
| 10.4 | Service Packages | `service_package/` | `lib/features/content/packages_screen.dart` | Medium |
| 10.5 | Doctor Profile Detail (bottom sheet) | `telehealth/` | `lib/features/doctors/doctor_detail_sheet.dart` | High |
| 10.6 | All Doctors List | `telehealth/` | `lib/features/doctors/doctors_list_screen.dart` | Medium |
| 10.7 | Branch Detail | `front_page/` (branch) | `lib/features/branch/branch_detail_screen.dart` | Medium |

### Content Screen Notes

- Articles: `ArticleCard` list. Paginated (10/page). Skeleton. Empty + Error states.
- Article Detail: featured image hero, rich text renderer for HTML body content.
- Videos: 2-column `GridView` of `VideoCard`. Tap → `url_launcher` opens TikTok.
- Service Packages: Replace 4 hardcoded static images with dynamic CMS-driven cards.
- Doctor Detail: `AppBottomSheet` variant — photo, name, specialty, bio, Book Appointment button.
- All Doctors: searchable `ListView` of `DoctorCard` (vertical variant).

---

## PHASE 11 — DIALOGS, PROMPTS & MODALS (CONSOLIDATION)

> The existing `component/` directory contains 24 one-off modal widgets named after individual developers (e.g., `ArifComponent`, `AveneshComponent`). These are all replaced by the shared `AppDialog` variants built in Phase 0.

| Current Component | Replacement |
|-------------------|-------------|
| Confirm booking dialogs (×6) | `AppDialog` — confirmation variant |
| Cancel appointment dialogs (×4) | `AppDialog` — confirmation variant (destructive) |
| Success dialogs (×5) | `AppDialog` — success variant |
| Loading overlays (×4) | `AppDialog` — loading variant |
| Reference/info modals (×3) | `AppBottomSheet` with custom content |
| Tag components (×2) | `AppChip` component |

**Rule: The `component/` and `components/` directories are emptied as part of this migration. No new one-off components are created.**

---

## PHASE 12 — NAVIGATION MIGRATION

| Task | Current | Target |
|------|---------|--------|
| Bottom nav | 4 tabs (Home, Branch, Booking, Profile) | 5 tabs (Home, Appointments, Health, Notifications, Profile) |
| Nav component | FlutterFlow `NavBarPage` in `main.dart` | `AppNavBar` component with `IndexedStack` |
| Route count | 27 routes in `nav.dart` | Consolidated — remove Copy/duplicate routes |
| Routing | `FFRoute` wrapper over GoRouter | Standard GoRouter (incremental — keep existing routes working) |
| Deep links | Basic | Notification deep links to specific screens |

### Tab Mapping (Old → New)

| Old Tab | New Tab |
|---------|---------|
| Home (HomepageNew) | Home |
| BranchLocationNewCopy | Removed from nav — Branch detail accessible from Booking flow |
| BookingPage | Appointments (shows list; booking flow started from Home quick action) |
| ProfileCopy | Profile |
| — | Health (new tab) |
| — | Notifications (new tab) |

---

## PHASE 13 — LEGACY CLEANUP

> Execute each item only after the replacement screen is confirmed working.

| Item | Action |
|------|--------|
| `component/` — 24 one-off modals | Delete after AppDialog rollout |
| `components/` — 3 widgets | Merge useful logic into shared components, delete files |
| `ProfileCopy` | Delete after profile_screen.dart confirmed |
| `RegisterPageCopy` | Delete after register_step1/2 confirmed |
| `HemedInfoCopy` | Delete after clinic_info_screen confirmed |
| `SelectDatecase` | Delete after booking_datetime_screen confirmed |
| `GetPatientbyidCopyCall` | Delete duplicate API class (keep original) |
| `LetterCopyCall` misnamed | Rename to `GetInvoicesCall` |
| `flutter_flow_theme.dart` usages | Replace all `FlutterFlowTheme.of(context).X` with `AppColors.X` / `AppTextStyles.X` per screen |
| `flutter_flow_widgets.dart` usages | Replace all `FFButtonWidget` with `AppButton` per screen |
| Poppins font asset | Remove from `assets/fonts/` and `pubspec.yaml` after full migration |

---

## SCREEN COVERAGE MATRIX

| Screen | Phase | Status | Design Reference |
|--------|-------|--------|-----------------|
| Splash | 2.1 | ⬜ Pending | v2-ux-spec §4 + design image |
| Onboarding (3 slides) | 2.2 | ⬜ Pending | v2-ux-spec §4 |
| Welcome / Landing | 2.3 | ⬜ Pending | design image |
| Login | 2.4 | ⬜ Pending | design image §6 |
| Register Step 1 | 2.5 | ⬜ Pending | v2-ux-spec §4 |
| Register Step 2 | 2.6 | ⬜ Pending | v2-ux-spec §4 |
| Forgot Password (3 steps) | 2.7-2.9 | ⬜ Pending | v2-ux-spec §4 |
| Home | 3.1 | ⬜ Pending | design image (main screen) |
| Booking — Branch | 4.1 | ⬜ Pending | design image §2 |
| Booking — Doctor | 4.2 | ⬜ Pending | design image §2 |
| Booking — Date & Time | 4.3 | ⬜ Pending | design image §5 |
| Booking — Confirm | 4.4 | ⬜ Pending | design image §5 |
| My Bookings | 4.5 | ⬜ Pending | design image §2 |
| Appointment Detail | 4.6 | ⬜ Pending | design image §2 |
| Appointments Tab | 5.1-5.3 | ⬜ Pending | design image §2 |
| Health Tab (3 inner tabs) | 6.1-6.5 | ⬜ Pending | design image §2 |
| Notifications Tab | 7.1 | ⬜ Pending | design image §2 |
| Profile Tab | 8.1 | ⬜ Pending | v2-ux-spec §4 |
| Edit Profile | 8.2 | ⬜ Pending | v2-ux-spec §4 |
| Change Password | 8.3 | ⬜ Pending | v2-ux-spec §4 |
| Biometric Settings | 8.4 | ⬜ Pending | v2-ux-spec §4 |
| Notification Prefs | 8.5 | ⬜ Pending | v2-ux-spec §4 |
| He Clinic Info | 8.6 | ⬜ Pending | same visual language |
| Privacy Policy | 8.7 | ⬜ Pending | same visual language |
| Terms of Service | 8.8 | ⬜ Pending | same visual language |
| My Points | 9.1 | ⬜ Pending | v2-ux-spec §4 |
| Redeem Points (sheet) | 9.2 | ⬜ Pending | v2-ux-spec §4 |
| Redemption Code Modal | 9.3 | ⬜ Pending | v2-ux-spec §4 |
| Articles List | 10.1 | ⬜ Pending | design image |
| Article Detail | 10.2 | ⬜ Pending | v2-ux-spec §4 |
| Videos List | 10.3 | ⬜ Pending | design image |
| Service Packages | 10.4 | ⬜ Pending | same visual language |
| Doctor Profile (sheet) | 10.5 | ⬜ Pending | design image §2 |
| All Doctors List | 10.6 | ⬜ Pending | same visual language |
| Branch Detail | 10.7 | ⬜ Pending | same visual language |

**Total screens: 37** (including multi-step flows counted individually)

---

## DEPENDENCY ORDER

```
Phase 0 (Design System)
    └── Phase 1 (Feature Components)
            ├── Phase 2 (Auth Screens)
            ├── Phase 3 (Home Screen)
            ├── Phase 4 (Booking Flow)
            ├── Phase 5 (Appointments Tab)
            ├── Phase 6 (Health Tab)
            ├── Phase 7 (Notifications Tab)
            ├── Phase 8 (Profile Tab)
            ├── Phase 9 (Loyalty Screens)
            └── Phase 10 (Content Screens)
                    └── Phase 11 (Dialog Consolidation)
                            └── Phase 12 (Navigation Migration)
                                    └── Phase 13 (Legacy Cleanup)
```

Phases 2–10 can proceed in parallel once Phase 0 and Phase 1 are complete.

---

## RELATED DOCUMENTS

| Document | Purpose |
|----------|---------|
| docs/ui-design-system.md | Design tokens, component specs, rules |
| docs/ui-implementation-tasks.md | Granular 2–4 hour implementation tasks |
| docs/v2-ux-spec.md | Screen-level UX specification |
| docs/v2-decisions.md | Locked product decisions |
