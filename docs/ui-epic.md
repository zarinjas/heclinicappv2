# Epic: Full UI Migration — He Clinic V2

> **Status:** Scheduled — starts after all active Processes complete
> **Source of Truth:** `docs/ui-design-system.md` + `docs/ui-migration-plan.md` + `docs/design-system-v2.png`
> **Scope:** Flutter mobile app only. Admin panel excluded.
> **Last Updated:** July 2026

---

## Epic Rule

This Epic is executed by the AI Director **after all active Processes (7–10) are complete**. It does not interrupt any running workflow.

---

## Compliance Rule

> **Reuse existing work only if it fully complies with `docs/ui-design-system.md`.**
> If an existing component does not match the spec — wrong colors, wrong font, wrong spacing, wrong structure — **replace it. Do not patch.**
> Preserve business logic. Replace UI only.
> The design system is the permanent source of truth. Backwards compatibility is not a goal.

---

## Design References (All Flutter Tasks Must Read These)

| Document | Purpose |
|----------|---------|
| `docs/ui-design-system.md` | Tokens, components, rules — primary spec |
| `docs/ui-migration-plan.md` | Phase-by-phase screen migration plan |
| `docs/design-system-v2.png` | Visual target — match this exactly |
| `docs/v2-ux-spec.md` | Screen-level UX specification |

---

## Execution Order

```
Epic Phase 0 → Phase 1 → Phases 2-10 (parallel once 0+1 done) → Phase 11 → Phase 12 → Phase 13
```

### Phase 0 — Design System Foundation
**Must be 100% complete before any screen migration begins.**

| Task ID | Component | File | Compliance Check |
|---------|-----------|------|-----------------|
| UI-P0-T01 | AppColors | `lib/core/theme/app_colors.dart` | All tokens from §2 |
| UI-P0-T02 | AppTextStyles | `lib/core/theme/app_text_styles.dart` | Plus Jakarta Sans, all 8 styles from §3 |
| UI-P0-T03 | AppSpacing + AppRadius + AppShadows | `lib/core/theme/app_spacing.dart`, `app_radius.dart`, `app_shadows.dart` | §4 §5 §6 |
| UI-P0-T04 | AppTheme (light + dark) | `lib/core/theme/app_theme.dart` | §24 dark mode tokens |
| UI-P0-T05 | AppButton | `lib/core/widgets/app_button.dart` | §8 — 6 variants, loading state, press scale |
| UI-P0-T06 | AppInput | `lib/core/widgets/app_input.dart` | §9 — all validation states |
| UI-P0-T07 | AppCard | `lib/core/widgets/app_card.dart` | §10 base card |
| UI-P0-T08 | AppChip | `lib/core/widgets/app_chip.dart` | §11 status + filter chips |
| UI-P0-T09 | AppSkeleton | `lib/core/widgets/app_skeleton.dart` | §15 shimmer presets |
| UI-P0-T10 | AppBottomSheet | `lib/core/widgets/app_bottom_sheet.dart` | §19 |
| UI-P0-T11 | AppDialog | `lib/core/widgets/app_dialog.dart` | §20 — 4 variants |
| UI-P0-T12 | AppToast | `lib/core/widgets/app_toast.dart` | §18 — 4 types |
| UI-P0-T13 | AppEmptyState | `lib/core/widgets/app_empty_state.dart` | §16 |
| UI-P0-T14 | AppErrorState | `lib/core/widgets/app_error_state.dart` | §17 |
| UI-P0-T15 | AppAppBar | `lib/core/widgets/app_app_bar.dart` | §13 — 2 variants |
| UI-P0-T16 | AppNavBar | `lib/core/widgets/app_nav_bar.dart` | §12 — 5 tabs |

### Phase 1 — Feature Components
**Build after Phase 0.**

| Task ID | Component | File |
|---------|-----------|------|
| UI-P1-T01 | AppointmentCard | `lib/core/widgets/appointment_card.dart` |
| UI-P1-T02 | DoctorCard | `lib/core/widgets/doctor_card.dart` |
| UI-P1-T03 | ArticleCard | `lib/core/widgets/article_card.dart` |
| UI-P1-T04 | VideoCard | `lib/core/widgets/video_card.dart` |
| UI-P1-T05 | LoyaltyCard | `lib/core/widgets/loyalty_card.dart` |
| UI-P1-T06 | HealthRecordCard | `lib/core/widgets/health_record_card.dart` |
| UI-P1-T07 | HeroSlider | `lib/core/widgets/hero_slider.dart` |
| UI-P1-T08 | QuickActionGrid | `lib/core/widgets/quick_action_grid.dart` |
| UI-P1-T09 | StepIndicator | `lib/core/widgets/step_indicator.dart` |
| UI-P1-T10 | OtpInputRow | `lib/core/widgets/otp_input_row.dart` |
| UI-P1-T11 | SectionHeader | `lib/core/widgets/section_header.dart` |
| UI-P1-T12 | NotificationItem | `lib/core/widgets/notification_item.dart` |
| UI-P1-T13 | TransactionItem | `lib/core/widgets/transaction_item.dart` |
| UI-P1-T14 | BranchCard | `lib/core/widgets/branch_card.dart` |
| UI-P1-T15 | TimeSlotChip | `lib/core/widgets/time_slot_chip.dart` |
| UI-P1-T16 | VitalsChart | `lib/core/widgets/vitals_chart.dart` |
| UI-P1-T17 | DocumentItem | `lib/core/widgets/document_item.dart` |
| UI-P1-T18 | OfflineBanner | `lib/core/widgets/offline_banner.dart` |

### Phases 2–13
See `docs/ui-migration-plan.md` for full screen inventory and notes.

---

## Task Creation Rules (for AI Director)

When the Director reaches this Epic and creates task files, each task MUST:

1. **Reference design system** in the Context section:
   - `docs/ui-design-system.md` — relevant sections
   - `docs/ui-migration-plan.md` — relevant phase
   - `docs/design-system-v2.png` — visual target

2. **Compliance check** — before marking task DONE, verify:
   - Colors match `AppColors` tokens (no hardcoded hex)
   - Typography uses `AppTextStyles` (no hardcoded sizes)
   - Spacing uses `AppSpacing` constants (no hardcoded px)
   - Border radius uses `AppRadius` constants
   - Shadows use `AppShadows` constants
   - Dark mode works (test `ThemeMode.dark`)
   - Skeleton loader defined
   - Empty state defined
   - Error state defined

3. **Existing component audit** — before building:
   - Read the existing implementation if it exists
   - Compare against design system spec
   - If fully compliant: keep it, note in Implementation Notes
   - If non-compliant: rebuild it to spec, document what changed

4. **No one-off styling** — all styling must use shared tokens. No inline `const Color(0xFF...)`, no hardcoded `TextStyle(fontSize: 14)`.

5. **flutter analyze must pass** before QA.

---

## Scheduling

The Director schedules this Epic via Phase 2B when:
- All Processes (7, 8, 9, 10) are complete
- `tasks/done/` contains all Process tasks
- `tasks/backlog/`, `in-progress/`, `in-review/` are empty

The Epic runs as a sequence of task batches: Phase 0 tasks → (when all done) Phase 1 tasks → (when done) Phases 2–13 tasks.

Tasks are named: `UI-P{phase}-T{num}-{slug}.md`
Example: `UI-P0-T01-app-colors.md`
