# He Clinic V2 — UI Design System

> **Status:** Official design system for He Clinic V2 mobile app.
> **Source of truth:** `docs/design-system-v2.png` + `docs/v2-ux-spec.md`
> **Last Updated:** July 2026
> **Scope:** Flutter mobile app only. Do NOT apply to admin panel (separate spec).

---

## 1. DESIGN PRINCIPLES

| Principle | Description |
|-----------|-------------|
| Clean & Modern | Minimal clutter, generous whitespace, purposeful hierarchy |
| Professional & Trustworthy | Healthcare-grade confidence — no playful or gimmicky patterns |
| Consistent Healthcare Look | Every screen feels like the same product |
| Mobile-First | Designed for thumb reach, 44px min tap targets, safe area awareness |
| Intuitive | Users should never need a manual — flows are self-explanatory |

---

## 2. COLOR PALETTE

### Primary Colors

| Token | Hex | Dart Name | Usage |
|-------|-----|-----------|-------|
| `primary` | `#131C3C` | `AppColors.primary` | Nav bar bg, app bar bg, hero banners, primary text on light |
| `primaryLight` | `#1D2B5F` | `AppColors.primaryLight` | Hover states, gradient end for dark surfaces |
| `accent` | `#3B8DFF` | `AppColors.accent` | CTAs, active nav icons, links, focus rings, progress bars |
| `accentBlue` | `#2868F5` | `AppColors.accentBlue` | Alternate accent for interactive elements |

### Semantic Colors

| Token | Hex | Dart Name | Usage |
|-------|-----|-----------|-------|
| `success` | `#27F5A3` | `AppColors.success` | Success chips, confirmed states, earn points |
| `warning` | `#F5A623` | `AppColors.warning` | Warning banners, pending chips, tier badges (Gold) |
| `error` | `#F54636` | `AppColors.error` | Error states, destructive actions, cancelled chips |
| `textSecondary` | `#8B7380` | `AppColors.textSecondary` | Subtitles, captions, placeholders, inactive labels |

### Surface Colors

| Token | Hex | Dart Name | Usage |
|-------|-----|-----------|-------|
| `background` | `#587380` | `AppColors.background` | Page backgrounds — NOTE: use `#F8F9FC` for light mode screens |
| `surface` | `#FFFFFF` | `AppColors.surface` | Cards, modals, input fields, bottom sheets |

### Light Mode Overrides (Applied at Theme Level)

| Context | Value |
|---------|-------|
| Page scaffold background | `#F8F9FC` |
| Card / sheet surface | `#FFFFFF` |
| Dividers | `#E5E7EB` |
| Input border (rest) | `#E5E7EB` |
| Input border (focus) | `#3B8DFF` (accent) |
| Input border (error) | `#F54636` (error) |

### Dark Mode Overrides

| Context | Value |
|---------|-------|
| Page scaffold background | `#0A0E1A` |
| Card / sheet surface | `#141C2E` |
| Dividers | `#1F2937` |
| Text primary | `#FFFFFF` |
| Text secondary | `#9CA3AF` |

### Loyalty / Points Gradient

| Usage | Value |
|-------|-------|
| Points card gradient start | `#131C3C` (primary) |
| Points card gradient end | `#3B8DFF` (accent) |
| Silver tier accent | `#C0C0C0` |
| Gold tier accent | `#F5A623` (warning) |

---

## 3. TYPOGRAPHY

**Font Family:** Plus Jakarta Sans (primary). Fallback: system sans-serif.
**Previous font (Poppins) is replaced entirely.**

Add to `pubspec.yaml`:
```
google_fonts: ^6.2.1  # already pinned
```

Use `GoogleFonts.plusJakartaSans(...)` or register as default theme font.

### Type Scale

| Style Token | Size | Weight | Line Height | Usage |
|-------------|------|--------|-------------|-------|
| `heading1` | 24px | 700 Bold | 1.2 | Page hero titles, greeting text |
| `heading2` | 20px | 700 SemiBold | 1.25 | Section headers, screen titles |
| `heading3` | 16px | 600 SemiBold | 1.3 | Card titles, modal headers, list item titles |
| `body1` | 14px | 400 Regular | 1.5 | Primary body text, descriptions |
| `body2` | 12px | 400 Regular | 1.5 | Secondary body, subtitles, timestamps |
| `caption` | 10px | 500 Medium | 1.4 | Nav labels, tags, form hints |
| `button` | 15px | 600 SemiBold | 1.0 | All button labels |
| `label` | 13px | 500 Medium | 1.0 | Form labels, chips |

### Dart Usage Pattern

```dart
// AppTextStyles — define once in lib/core/theme/text_styles.dart
static TextStyle heading1 = GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700);
static TextStyle heading2 = GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700);
static TextStyle heading3 = GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600);
static TextStyle body1    = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400);
static TextStyle body2    = GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400);
static TextStyle caption  = GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500);
static TextStyle button   = GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600);
static TextStyle label    = GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500);
```

---

## 4. SPACING SCALE

All spacing uses an 8px base grid.

| Token | Value | Usage |
|-------|-------|-------|
| `space2` | 2px | Micro gaps (icon badge offsets) |
| `space4` | 4px | `xs` — icon-to-label gap, chip inner padding vertical |
| `space8` | 8px | `sm` — tight rows, inner card elements |
| `space12` | 12px | Between form field and label |
| `space16` | 16px | `md` — standard screen horizontal padding |
| `space20` | 20px | Section inner padding |
| `space24` | 24px | `lg` — section-to-section spacing |
| `space32` | 32px | `xl` — large section breaks |
| `space48` | 48px | `2xl` — hero sections, onboarding illustrations |

**Standard screen horizontal padding: 16px on both sides.**

---

## 5. BORDER RADIUS

| Token | Value | Usage |
|-------|-------|-------|
| `radiusXS` | 4px | Notification dot, micro badges |
| `radiusSM` | 8px | Tags, status chips, filter chips |
| `radiusMD` | 12px | Input fields, search bars |
| `radiusLG` | 16px | Cards, list tiles, image containers |
| `radiusXL` | 24px | Primary buttons, bottom sheet top corners |
| `radius2XL` | 32px | Hero banner cards, loyalty card |
| `radiusFull` | 9999px | Avatars, FABs, circular badges |

---

## 6. SHADOWS / ELEVATION

| Token | Value | Usage |
|-------|-------|-------|
| `shadowLow` | `0 1px 4px rgba(0,0,0,0.06)` | Cards at rest |
| `shadowMid` | `0 4px 16px rgba(0,0,0,0.10)` | Floating elements, dropdowns, active cards |
| `shadowHigh` | `0 8px 32px rgba(0,0,0,0.16)` | Modals, bottom sheets |
| `shadowNav` | `0 -2px 12px rgba(0,0,0,0.08)` | Bottom navigation bar |

---

## 7. ICONS

**Library:** Material Icons (bundled with Flutter) + custom SVG assets for branded icons.

| Context | Icon Source | Size |
|---------|-------------|------|
| Bottom nav icons | Material Icons | 24px |
| Quick action card icons | Material Icons (filled, accent color) | 28px |
| List item leading icons | Material Icons | 20px |
| Form field trailing icons | Material Icons | 20px |
| Status icons (success/error) | Material Icons | 40px |
| App bar action icons | Material Icons | 24px |
| Doctor specialty icons | Material Icons | 16px |
| Notification type icons | Material Icons | 24px |

**Do not use icon fonts other than Material. Do not import FontAwesome.**

---

## 8. BUTTONS

### Variants

| Variant | Background | Text Color | Border | Usage |
|---------|-----------|------------|--------|-------|
| Primary | `#3B8DFF` (accent) | `#FFFFFF` | none | Main CTA — Book, Confirm, Save, Login |
| Secondary | transparent | `#3B8DFF` | 1.5px solid accent | Secondary action — Cancel, Back |
| Ghost | transparent | `#3B8DFF` | none | Tertiary — See All, View History |
| Destructive | `#F54636` (error) | `#FFFFFF` | none | Delete, Cancel Appointment, Logout |
| Disabled | `#E5E7EB` | `#9CA3AF` | none | Non-interactive state |
| WhatsApp | `#25D366` | `#FFFFFF` | none | WhatsApp redirect CTA specifically |

### Dimensions

| Property | Value |
|----------|-------|
| Height | 52px |
| Width | Full width by default; auto for inline |
| Border radius | 24px (`radiusXL`) |
| Padding horizontal | 24px |
| Font | `button` style (15px / 600) |
| Icon spacing | 8px between icon and label |

### States

| State | Visual |
|-------|--------|
| Default | As above |
| Pressed | Scale 0.97, 150ms ease |
| Loading | Replace label with 20px circular `CircularProgressIndicator` (white, strokeWidth 2) |
| Disabled | `#E5E7EB` bg, `#9CA3AF` text, no interaction |

---

## 9. INPUT FIELDS

| Property | Value |
|----------|-------|
| Height | 52px |
| Border radius | 12px (`radiusMD`) |
| Background | `#FFFFFF` (surface) |
| Border rest | 1.5px solid `#E5E7EB` |
| Border focus | 1.5px solid `#3B8DFF` |
| Border error | 1.5px solid `#F54636` |
| Label position | Above field, `label` typography, `primary` color |
| Placeholder | `body1`, `textSecondary` color |
| Helper text | Below field, `body2`, `textSecondary` |
| Error text | Below field, `body2`, `error` color |
| Padding | 16px horizontal, 14px vertical |

### Validation Behavior

- Validate on field **blur** (not keystroke)
- Error border + message appear immediately on blur with invalid input
- Error clears immediately when input becomes valid (on change, after first error)
- Success state: no visual change needed — keep clean

### Special Input Types

| Type | Component |
|------|-----------|
| Password | Show/hide toggle (eye icon) in trailing |
| Phone number | Country code prefix `+60`, custom widget (existing `phonefield`) |
| Date | Date picker bottom sheet, display formatted `dd MMM yyyy` |
| Nationality | Custom dropdown picker (existing `nationality` widget) |
| OTP | 6 individual boxes, 48x52px each, auto-advance on digit entry |
| Dropdown | Outlined, chevron-down trailing icon, bottom sheet picker |

---

## 10. CARDS

### Base Card

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border radius | 16px (`radiusLG`) |
| Padding | 16px |
| Shadow | `shadowLow` |
| Border (light mode) | 1px solid `#E5E7EB` |

### Appointment Card

| Zone | Content |
|------|---------|
| Leading | Doctor photo, 56px circle avatar |
| Title | Doctor name, `heading3` |
| Subtitle | Specialty, `body2`, `textSecondary` |
| Meta row | Branch name with location icon |
| Bottom row | Date + time (left), status chip (right) |
| Interaction | Tap → Appointment Detail screen |

Upcoming variant adds: "X days to go" badge (top-right corner, accent bg).

### Doctor Card (horizontal scroll)

| Zone | Content |
|------|---------|
| Avatar | 80px circle, doctor photo |
| Name | `heading3`, centered |
| Specialty | `body2`, `textSecondary`, centered |
| Rating | Star icon + rating text, `caption` (if available) |
| Availability chip | "Available Today" — success color |

### Article Card

| Zone | Content |
|------|---------|
| Image | Full width, 140px height, `radiusLG` top corners |
| Category chip | Overlaid top-left on image |
| Title | `heading3`, 2 lines max |
| Excerpt | `body2`, `textSecondary`, 2 lines max |
| Footer | Author + date, `body2`, `textSecondary` |

### Video Thumbnail Card

| Zone | Content |
|------|---------|
| Thumbnail | 16:9 ratio, `radiusLG` |
| Play icon overlay | 36px circle (semi-transparent white bg), centered |
| Title | `body2`, 2 lines max |
| Author | `caption`, `textSecondary` |

### Loyalty Points Card

| Zone | Content |
|------|---------|
| Background | Linear gradient: `primary` (#131C3C) → `accent` (#3B8DFF), `radius2XL` |
| Top left | Tier badge chip |
| Center | Balance in `heading1` white bold |
| Sub-label | "Patient Appreciation Points", `body2`, white 70% |
| Bottom row | "Redeem Points" + "View History" ghost buttons (white outlined) |

### Health Record Card

| Zone | Content |
|------|---------|
| Leading icon | Type icon (note/letter/lab), 40px circle bg, accent tint |
| Title | `heading3` |
| Subtitle | Doctor name, `body2`, `textSecondary` |
| Trailing | Date, `body2`, `textSecondary` |

---

## 11. CHIPS / TAGS / BADGES

### Status Chips (Appointments)

| Status | Background | Text Color |
|--------|-----------|------------|
| Confirmed | `#ECFDF5` | `#10B981` |
| Pending | `#FFF7ED` | `#F59E0B` |
| Cancelled | `#FEF2F2` | `#EF4444` |
| Completed | `#EFF6FF` | `#3B82F6` |

Dimensions: height 24px, radius 8px (`radiusSM`), padding 4px 10px, `label` typography.

### Filter Chips

| State | Style |
|-------|-------|
| Default | `#F3F4F6` bg, `#6B7280` text |
| Active | `accent` bg, white text |

Dimensions: height 32px, radius 8px, padding 8px 14px, `label` typography.

### Notification Badge (Red Dot)

| Property | Value |
|----------|-------|
| Size | 18px circle |
| Background | `#F54636` (error) |
| Text | white, `caption`, count or blank dot |
| Position | top-right of icon, offset (-6px, -6px) |

### Tier Badges

| Tier | Background | Text |
|------|-----------|------|
| Standard | `#F3F4F6` | `#6B7280` |
| Silver | `#F0F0F0` | `#9CA3AF` |
| Gold | `#FFF7ED` | `#F5A623` |

---

## 12. BOTTOM NAVIGATION BAR

| Property | Value |
|----------|-------|
| Tabs | 5: Home, Appointments, Health, Notifications, Profile |
| Background | `#131C3C` (primary) |
| Height | 64px + bottom safe area inset |
| Active icon + label | `#3B8DFF` (accent) |
| Inactive icon + label | `rgba(255,255,255,0.5)` |
| Label style | `caption`, 10px |
| Shadow | `shadowNav` |
| Notification badge | Red dot on Notifications tab when unread count > 0 |

### Tab Icons (Material)

| Tab | Icon (inactive) | Icon (active) |
|-----|----------------|---------------|
| Home | `home_outlined` | `home` |
| Appointments | `calendar_today_outlined` | `calendar_today` |
| Health | `favorite_outlined` | `favorite` |
| Notifications | `notifications_outlined` | `notifications` |
| Profile | `person_outlined` | `person` |

---

## 13. APP BAR

### Main Tab App Bar (Home, etc.)

| Property | Value |
|----------|-------|
| Background | `#131C3C` (primary) |
| Leading | He Clinic logo (left-aligned, 32px height) |
| Trailing | Notification bell icon (white) with badge |
| Title | hidden on Home — replaced by logo |
| Elevation | 0 (no shadow) |

### Sub-page App Bar

| Property | Value |
|----------|-------|
| Background | `#F8F9FC` (bg-light) or transparent over hero |
| Leading | Back arrow, `primary` color |
| Title | Screen name, `heading3`, `primary` color |
| Trailing | Context action (share, edit, search) |
| Elevation | 0 |

---

## 14. HERO BANNER / SLIDER

| Property | Value |
|----------|-------|
| Height | 180px |
| Border radius | `radiusLG` (16px) |
| Content | Full-bleed image, optional text overlay |
| Dot indicator | Centered below, 6px dots, active dot accent color |
| Auto-scroll | Every 4 seconds |
| Animation | Smooth page scroll |
| Skeleton | Shimmer rect 180px height while loading |

---

## 15. SKELETON LOADERS

Always use skeleton loaders instead of spinners for list/content loading.

| Pattern | Shape |
|---------|-------|
| List item | 48px circle (left) + 2 text bars (right) |
| Card | Full card rect — image top + 3 text bars |
| Article card | 140px image rect + 3 bars |
| Video grid | 2-col 16:9 rects + 2 bars each |
| Appointment card | Full card rect with 3 bars |
| Doctor horizontal | Circle + 2 bars, repeated |
| Slider | Full-width 180px rect |

**Animation:** Shimmer left-to-right, 1.5s loop.
**Colors (light):** `#E5E7EB` → `#F3F4F6`
**Colors (dark):** `#1F2937` → `#374151`

Use `flutter_animate` package (already in pubspec) for shimmer effect.

---

## 16. EMPTY STATES

| Screen | Illustration | Title | Subtitle | CTA |
|--------|-------------|-------|---------|-----|
| No appointments | Calendar SVG | No appointments yet | Book your first visit today | Book Now |
| No notifications | Bell SVG | You're all caught up | We'll notify you when something's new | — |
| No documents | File SVG | No documents yet | Your health records will appear here | — |
| No records | Clipboard SVG | No records found | Your clinical notes will appear here | — |
| No articles | Articles SVG | No articles yet | Check back soon for health tips | — |
| No videos | Play SVG | No videos yet | Check back soon for our latest videos | — |
| No doctors | Person SVG | No doctors available | Please contact the clinic directly | — |
| No search results | Search SVG | No results found | Try a different search term | — |

Layout: centered, SVG ~160px, `heading3` title, `body1` subtitle in `textSecondary`, optional primary button below.

---

## 17. ERROR STATES

| Property | Value |
|----------|-------|
| Icon | `error_outline`, 40px, `error` color |
| Title | "Something went wrong", `heading3` |
| Subtitle | Context-specific message, `body1`, `textSecondary` |
| CTA | "Try Again" ghost button |

**Rule: Never show a blank screen. Every list, tab, and page must have a defined error state.**

---

## 18. TOAST / SNACKBAR

| Property | Value |
|----------|-------|
| Position | Bottom of screen, above nav bar |
| Shape | Pill / rounded, `radiusXL` |
| Auto-dismiss | 3 seconds |
| Max width | Screen width − 32px |
| Animation | Slide up + fade in, 250ms |

| Type | Left accent / bg | Icon |
|------|-----------------|------|
| Success | `#27F5A3` left bar | `check_circle_outline` |
| Error | `#F54636` left bar | `error_outline` |
| Warning | `#F5A623` left bar | `warning_amber` |
| Info | `#131C3C` bg, white text | `info_outline` |

---

## 19. BOTTOM SHEETS

| Property | Value |
|----------|-------|
| Border radius | 24px top corners only |
| Handle bar | 4px × 36px, `#E5E7EB`, centered, 8px from top |
| Background | `#FFFFFF` (surface) |
| Max height | 90% screen height |
| Overflow | Scrollable inside |
| Backdrop | `rgba(0,0,0,0.4)`, tap to dismiss |
| Animation | Spring slide-up, 350ms |
| Close animation | Ease slide-down, 280ms |

---

## 20. DIALOGS / MODALS

### Confirmation Modal

| Zone | Content |
|------|---------|
| Icon | Warning / question icon, 48px, `warning` color |
| Title | "Are you sure?", `heading3`, centered |
| Body | Consequence message, `body1`, `textSecondary`, centered |
| Actions | Row: Cancel (ghost) left, Confirm (destructive or primary) right |

### Success Modal

| Zone | Content |
|------|---------|
| Icon | Animated checkmark, 64px, `accent` color |
| Title | "Done!", `heading3`, centered |
| Body | Context message, `body1`, `textSecondary`, centered |
| CTA | Primary button full width |

### Loading Modal

| Zone | Content |
|------|---------|
| Spinner | `CircularProgressIndicator`, accent color, 32px |
| Label | "Please wait…", `body1`, `textSecondary` |
| Backdrop | `rgba(0,0,0,0.4)`, blocks all interaction |

### Redemption Code Modal

| Zone | Content |
|------|---------|
| Icon | Animated checkmark, 64px, `accent` |
| Title | "Your Redemption Code", `heading3`, centered |
| Code block | Large monospace font, accent-colored border, `radiusMD` |
| Discount | "RM X.XX discount", `heading2`, accent, centered |
| Instructions | `body2`, `textSecondary`, centered |
| CTA | "Done" primary button |

---

## 21. LOADING STATES (FULL-PAGE)

Only used on initial app load / auth check. Not for navigated screens.

| Property | Value |
|----------|-------|
| Background | `primary` (#131C3C) |
| Content | He Clinic logo centered + fade-in animation |
| Fallback | If loading > 10s: show error with retry |

---

## 22. FORM PATTERNS

| Pattern | Rule |
|---------|------|
| Label placement | Always above the field, never floating/placeholder-only |
| Validation trigger | On blur, not on keystroke |
| Error recovery | Clear error on first valid keystroke after error shown |
| Required fields | Mark with * after label |
| Submit button | Disabled until all required fields are valid |
| Password | Always include show/hide toggle |
| Date fields | Always use date picker, never free-text |
| Checkbox | 20px, accent checkmark color |
| Radio | 20px, accent fill color |

---

## 23. ANIMATIONS

| Transition | Type | Duration | Easing |
|-----------|------|----------|--------|
| Screen push | Slide left | 300ms | ease |
| Screen pop | Slide right | 300ms | ease |
| Bottom sheet open | Slide up + fade | 350ms | spring |
| Bottom sheet close | Slide down + fade | 280ms | ease |
| Tab switch | Fade | 200ms | ease |
| Toast appear | Slide up + fade | 250ms | ease |
| Skeleton → content | Crossfade | 300ms | ease |
| Button press | Scale 0.97 | 150ms | ease |
| Checkmark animate | Draw + scale | 400ms | spring |
| Page skeleton | Shimmer sweep | 1500ms | loop |
| Loyalty card gradient | Static (no animation) | — | — |

**All animations implemented via `flutter_animate` package (already in pubspec).**

---

## 24. DARK MODE

System setting respected automatically via `ThemeMode.system`.

| Token | Light | Dark |
|-------|-------|------|
| Page bg | `#F8F9FC` | `#0A0E1A` |
| Surface / card | `#FFFFFF` | `#141C2E` |
| Text primary | `#131C3C` | `#FFFFFF` |
| Text secondary | `#8B7380` | `#9CA3AF` |
| Divider | `#E5E7EB` | `#1F2937` |
| Input bg | `#FFFFFF` | `#1A2236` |
| Skeleton base | `#E5E7EB` | `#1F2937` |
| Skeleton shimmer | `#F3F4F6` | `#374151` |

Primary, accent, success, warning, error colors remain unchanged in dark mode.

---

## 25. ACCESSIBILITY

| Rule | Requirement |
|------|------------|
| Touch targets | Minimum 44×44px on all interactive elements |
| Color contrast | Min 4.5:1 body text, 3:1 large text (WCAG 2.1 AA) |
| Image alt text | `semanticLabel` on all `Image` and icon widgets |
| Form labels | Explicit labels — never placeholder-only for accessibility |
| Focus indicators | Visible focus ring on all focusable elements (keyboard nav) |
| Reading order | Logical top-to-bottom, left-to-right semantic order |
| Color alone | Never convey information by color alone — pair with icon or text |
| Screen reader | All custom widgets annotated with `Semantics` widget |

> Full WCAG 2.1 AA compliance requires manual testing with assistive technologies and expert review.

---

## 26. FILE STRUCTURE (Target)

```
lib/
  core/
    theme/
      app_colors.dart          # All color constants
      app_text_styles.dart     # All text style constants
      app_theme.dart           # ThemeData (light + dark)
      app_spacing.dart         # Spacing constants
      app_radius.dart          # Border radius constants
      app_shadows.dart         # BoxShadow constants
    widgets/
      app_button.dart          # Primary, Secondary, Ghost, Destructive, WhatsApp
      app_input.dart           # Text input with label/error states
      app_card.dart            # Base card widget
      app_chip.dart            # Status, filter chips
      app_skeleton.dart        # Shimmer skeleton base + presets
      app_bottom_sheet.dart    # Standard bottom sheet wrapper
      app_dialog.dart          # Confirmation, success, loading, code modals
      app_toast.dart           # Toast/snackbar utility
      app_empty_state.dart     # Empty state component
      app_error_state.dart     # Error state component
      app_app_bar.dart         # Main tab + sub-page app bar variants
      app_nav_bar.dart         # Bottom navigation bar
      appointment_card.dart    # Appointment card component
      doctor_card.dart         # Doctor horizontal scroll card
      article_card.dart        # Article list card
      video_card.dart          # Video thumbnail card
      loyalty_card.dart        # Points balance card
      health_record_card.dart  # Health record list item
      hero_slider.dart         # Auto-scroll banner slider
      quick_action_grid.dart   # 2×2 quick action cards
```

---

## 27. DESIGN RULES SUMMARY

1. **No new colors.** Only use tokens defined in this document.
2. **No new fonts.** Plus Jakarta Sans only.
3. **No spinners for lists.** Always use skeleton loaders.
4. **No blank screens.** Every state (loading, empty, error) must have a defined UI.
5. **No floating labels.** Labels always sit above fields.
6. **No hardcoded magic numbers.** Use spacing/radius/color tokens.
7. **Shared components first.** Build `AppButton`, `AppCard`, etc. before building screens.
8. **Every screen uses shared components.** No one-off widget styling inside screen files.
9. **Business logic stays out of widgets.** UI components are purely presentational.
10. **Dark mode always.** Every new widget must handle both light and dark themes.
