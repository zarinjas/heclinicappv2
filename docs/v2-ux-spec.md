# He Clinic V2 — UI/UX Specification

> **Purpose:** Complete UI/UX reference for design and development. AI should use this alongside v2-decisions.md.
> **Last Updated:** July 2026
> **Status:** Specification phase — pending mockup approval

---

## 1. DESIGN SYSTEM

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| primary | #0F1B3D | Main brand, headers, nav bar background |
| accent | #00C9A7 | CTAs, active states, highlights, icons |
| gold | #F5A623 | Premium badges, special tags |
| bg-light | #F8F9FC | Page backgrounds (light mode) |
| bg-dark | #0A0E1A | Page backgrounds (dark mode) |
| surface | #FFFFFF | Cards, modals, sheets (light) |
| surface-dark | #141C2E | Cards, modals, sheets (dark) |
| text-primary | #0F1B3D | Body text, headings |
| text-secondary | #6B7280 | Subtitles, captions, placeholders |
| text-inverse | #FFFFFF | Text on dark/accent backgrounds |
| error | #EF4444 | Error states, destructive actions |
| warning | #F59E0B | Warning banners |
| success | #10B981 | Success toasts, confirmed states |
| divider | #E5E7EB | Borders, separators |

### Typography

Font: Plus Jakarta Sans throughout. Fallback: system sans-serif.

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| heading-xl | 28px | 700 | Page titles |
| heading-lg | 22px | 700 | Section headers |
| heading-md | 18px | 600 | Card titles, modal headers |
| heading-sm | 16px | 600 | List item titles |
| body-lg | 16px | 400 | Primary body text |
| body-md | 14px | 400 | Secondary body text |
| body-sm | 12px | 400 | Captions, labels, timestamps |
| label | 13px | 500 | Form labels, tags |
| button | 15px | 600 | All button text |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon + label gaps |
| sm | 8px | Inner card padding, tight rows |
| md | 16px | Standard screen padding |
| lg | 24px | Section spacing |
| xl | 32px | Large section breaks |
| 2xl | 48px | Hero sections |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 8px | Tags, chips |
| md | 12px | Input fields |
| lg | 16px | Cards |
| xl | 24px | Buttons, bottom sheets |
| full | 9999px | Avatars, badges |

### Shadows

| Level | Usage |
|-------|-------|
| low — 0 1px 4px rgba(0,0,0,0.06) | Cards at rest |
| mid — 0 4px 16px rgba(0,0,0,0.10) | Floating elements, dropdowns |
| high — 0 8px 32px rgba(0,0,0,0.16) | Modals, bottom sheets |

---

## 2. COMPONENT LIBRARY

### Buttons

| Variant | Style | Usage |
|---------|-------|-------|
| Primary | Solid #00C9A7 bg, white text | Main CTA |
| Secondary | Outlined #00C9A7 border, accent text | Secondary action |
| Ghost | No border, accent text | Inline / tertiary |
| Destructive | Solid #EF4444, white text | Delete, remove |
| Disabled | #E5E7EB bg, #9CA3AF text | Non-interactive |

- Height: 52px, full width by default
- Border radius: xl (24px)
- Press animation: scale 0.97, 150ms

### Input Fields

- Height: 52px
- Border radius: md (12px)
- Border: 1.5px solid #E5E7EB at rest
- Focus border: #00C9A7 (accent)
- Error border: #EF4444
- Label sits above field, label typography
- Helper / error text sits below field, body-sm

### Cards

- Background: surface
- Border radius: lg (16px)
- Padding: md (16px)
- Shadow: low
- Light mode: 1px solid #E5E7EB border

### Bottom Sheet / Modal

- Slides up from bottom with spring animation
- Border radius: xl top corners only
- Handle bar: 4px x 36px, #E5E7EB, centered at top, 8px from top edge
- Background: surface
- Max height: 90% screen height, scrollable inside
- Backdrop: rgba(0,0,0,0.4), tap to dismiss

### Skeleton Loaders

Always use instead of spinner for list/content loading.

- Shape mirrors actual content layout
- List item: avatar circle + 2 text lines
- Card: full card rectangle
- Text blocks: varied-width horizontal bars
- Animation: shimmer left-to-right, 1.5s loop
- Colors: #E5E7EB to #F3F4F6 (light) / #1F2937 to #374151 (dark)

Use flutter_animate package (already in pubspec) for shimmer animation.

### Inline Spinner

Only for button loading state — replaces button label text while loading.

### Empty States

- Centered SVG illustration (~160px height)
- heading-md title
- body-md subtitle in text-secondary
- Optional Primary button CTA

| Screen | Title | Subtitle | CTA |
|--------|-------|----------|-----|
| No appointments | No appointments yet | Book your first visit today | Book Now |
| No notifications | You are all caught up | We will notify you when something is new | — |
| No documents | No documents yet | Your health records will appear here | — |
| No records | No records found | Your clinical notes will appear here | — |
| No articles | No articles yet | Check back soon for health tips and updates | — |
| No videos | No videos yet | Check back soon for our latest videos | — |

### Error States

- Error icon (red, 40px)
- Something went wrong in heading-sm
- Error description in body-md, text-secondary
- Try Again ghost button
- Never show a blank screen

### Toast / Snackbar

- Appears at bottom, above nav bar
- Rounded pill shape, lg radius
- Auto-dismiss: 3s
- Success: #10B981 left accent bar
- Error: #EF4444 left accent bar
- Info: #0F1B3D background, white text

### Tags / Chips

- Height: 28px, border radius: sm (8px), padding: 4px 10px, body-sm typography

| Type | Colors |
|------|--------|
| Confirmed | #ECFDF5 bg, #10B981 text |
| Pending | #FFF7ED bg, #F59E0B text |
| Cancelled | #FEF2F2 bg, #EF4444 text |
| Info | #EFF6FF bg, #3B82F6 text |

---

## 3. NAVIGATION

### Bottom Navigation Bar (5 Tabs)

  [ Home ]  [ Appointments ]  [ Health ]  [ Notifications ]  [ Profile ]

- Background: primary (#0F1B3D)
- Active icon + label: accent (#00C9A7)
- Inactive icon + label: rgba(255,255,255,0.5)
- Label: body-sm, 11px
- Notification badge on Notifications tab: red dot with unread count
- Height: 64px + safe area bottom inset

### App Bar (Top)

- Background: primary (#0F1B3D) for main tab screens
- Background: bg-light / bg-dark (transparent style) for sub-pages
- Title: heading-sm, white
- Leading: back arrow (sub-pages), logo (main tabs)
- Trailing: action icons (search, settings, etc.)

---

## 4. SCREEN SPECIFICATIONS

### SCREEN: Splash Screen

Layout:
- Full screen, primary background
- He Clinic logo centered, animated fade-in
- Tagline below logo: body-md, white, 60% opacity
- No skip button — auto-navigates after load completes

Logic:
- Run initFirebase() + loadLoginData()
- If isLoggedIn -> navigate to Home tab
- If not -> navigate to Onboarding

---

### SCREEN: Onboarding

Layout:
- 3 swipeable slides, page indicator dots at bottom
- Each slide: full-screen illustration (top 55%), title + subtitle (bottom 45%)
- Next button bottom right
- Skip ghost button top right (slides 1 and 2 only)
- Slide 3: Get Started primary button (full width)

Slides:
  1. Title: Your Health, Simplified
     Subtitle: Book appointments and track your health in one place

  2. Title: Book in Minutes
     Subtitle: See real available slots and connect with your doctor instantly

  3. Title: Stay in the Loop
     Subtitle: Get instant updates on your appointments and health records

---

### SCREEN: Login

Layout:
- Top: He Clinic logo + Welcome back heading-lg
- Email input field
- Password input field with show/hide toggle
- Forgot Password? ghost button, right-aligned below password
- Login primary button (full width)
- Divider: or continue with
- Google Sign-In outlined button
- Apple Sign-In outlined button (iOS only)
- Bottom text: Do not have an account? Register (Register is tappable link)

States:
- Loading: Login button shows inline spinner, disabled
- Error: red toast Invalid email or password
- Biometric: auto-prompt on screen load if biometric is enabled

---

### SCREEN: Register

Layout:
- Step indicator at top: Step 1 of 2 / Step 2 of 2
- Back arrow available on both steps

Step 1 — Account Details:
- Full Name, Email, Phone Number (with country picker), Password, Confirm Password
- Next primary button

Step 2 — Medical Info:
- NRIC / Passport No, Date of Birth (date picker), Nationality (custom picker), Known Allergies (optional, multiline)
- Create Account primary button

Validation (on field blur):
- Email: valid format check
- Phone: valid Malaysian format
- Password: min 8 characters
- Confirm Password: must match password
- NRIC: 12-digit format

---

### SCREEN: Forgot Password

3-step flow, back navigation available between steps.

Step 1 — Enter Email:
- Email input
- Send Reset Code primary button

Step 2 — Enter OTP:
- 6-digit OTP input (individual box style, auto-advance per digit)
- Timer countdown: Resend code in 0:59
- Resend ghost button (active after countdown ends)

Step 3 — New Password:
- New Password input + Confirm Password input
- Reset Password primary button
- On success: toast Password reset successfully, navigate to Login

---

### SCREEN: Home

Layout (scrollable):

  App bar: He Clinic logo (left), Notifications bell icon (right, with badge)

  Good morning, {Name}               <- heading-md, primary color
  [Hero Slider — 180px height]       <- auto-scroll 4s, dot indicators, dynamic from CMS

  Quick Actions (2x2 grid cards)
    [ Book Appointment ]  [ My Records  ]
    [ Health           ]  [ Packages    ]

  Loyalty Points Widget             <- visible only if loyalty account exists
  [Points Balance Card]

  Upcoming Appointment               <- section header + See All link
  [Appointment Card or empty state]

  Our Doctors                        <- section header + See All link
  [Horizontal scroll — doctor avatar cards]

  Health Tips                        <- section header + See All link
  [Article Card]
  [Article Card]

  Videos                             <- section header + See All link
  [Video Thumbnail Grid — 2 columns]

Video Thumbnail Grid (Home):
- 2-column grid, max 4 thumbnails shown (latest 4 published videos)
- Each card: thumbnail (16:9, lg radius), play icon overlay (centered, 36px, white semi-transparent circle), title below (body-sm, 2 lines max)
- Skeleton: 2x2 rect placeholders while loading
- Section hidden entirely if 0 published videos
- Tap card -> url_launcher opens TikTok app or browser

Loyalty Points Widget (Points Balance Card):
- Background: gradient from primary (#0F1B3D) to accent (#00C9A7)
- Border radius: lg (16px), shadow: mid
- Left side:
    Tier badge chip (Standard / Silver / Gold) — gold color for Silver+
    Points balance — heading-xl white, bold
    Label: "Patient Appreciation Points" — body-sm, white 70% opacity
- Right side:
    Circular tier icon (40px) — star outline (Standard), star half-filled (Silver), star filled (Gold)
- Bottom row:
    "Redeem Points" ghost button (white outlined) — left
    "View History" ghost button (white outlined) — right
- Tap card → My Points screen
- Hidden if patient has no loyalty_account yet (first-time patient)

Quick Action Cards:
- 4 cards in 2x2 grid
- Each: teal icon (28px) + label, card style, lg radius
- Tap navigates to respective screen

Hero Slider:
- Dynamic from CMS Sliders API
- Auto-scroll every 4s, dot indicator
- Tap opens article or URL (configurable per slide in CMS)

Doctor Cards (horizontal scroll):
- Circle avatar (80px), doctor name, specialty
- Shows only is_visible_in_app = true doctors
- Tap opens Doctor Detail bottom sheet

Upcoming Appointment Card:
- Doctor photo + name, date + time, branch name
- Status chip (Confirmed / Pending)
- View Details ghost button

---

### SCREEN: My Points

Access: Home → Loyalty Widget tap, or Profile → My Points

Layout (scrollable):

  App bar: My Points, back arrow

  [Points Summary Card — full width]
    Gradient bg (primary → accent)
    Current Balance: {X} pts — heading-xl, white
    Tier badge: Standard / Silver / Gold
    Tier progress bar:
      Standard: progress toward 5,000 lifetime pts for Silver
      Silver: progress toward 20,000 lifetime pts for Gold
      Gold: "Maximum tier reached"
    Expiry notice (if any points expiring within 30 days):
      body-sm, warning color: "X points expiring on {date}"

  [Redeem Points — primary button, full width]
    Disabled if balance < 100
    Label: "Redeem Points (min. 100 pts)"

  Transaction History            <- section header
  Filter chips: All / Earned / Redeemed / Expired
  [Transaction list — paginated]

Transaction Item:
  [Icon]  Earned from visit         <- type label
          Invoice #INV-20250714      <- invoice ref or reason
          14 Jul 2025               <- date
                          +100 pts  <- right-aligned, green for earn, red for redeem/expire

  Icon per type:
    earn   → arrow-down-circle, accent green
    redeem → gift icon, accent teal
    expire → clock icon, text-secondary
    adjust → pencil icon, warning amber

Empty state (no transactions):
  Illustration + "No points activity yet"
  Subtitle: "Points are earned automatically when your invoice is finalized"

---

### SCREEN: Redeem Points (Bottom Sheet)

Triggered from: My Points screen → Redeem Points button

Layout:
  [Handle bar]
  Redeem Points                    <- heading-md
  Available: {X} pts               <- body-md, text-secondary

  Amount selector:
    Minus button  [  200 pts  ]  Plus button
    Stepper increments by 100
    Min: 100 pts / Max: min(balance, 1000) pts

  Discount value preview:
    = RM {X.XX} discount            <- heading-sm, accent color
    body-sm: "Discount applied to your next invoice"

  Info note (body-sm, text-secondary):
    "Show your redemption code to the staff at the counter."
    "Code is valid for this visit only."

  [Confirm Redemption — primary button, full width]

On confirm:
  Loading modal (Please wait...)
  On success → show Redemption Code modal

### SCREEN: Redemption Code Modal

  [Animated checkmark — 64px, accent]
  Your Redemption Code             <- heading-md, centered

  [Code block — large monospace font, accent border]
  HEC-A3F9-2024

  RM {X.XX} discount               <- heading-sm, accent, centered

  body-sm, text-secondary, centered:
  "Show this code to the counter staff."
  "Valid for today's visit only."

  [Done — primary button, full width]
  Tap Done → dismiss modal, refresh points balance

---

### SCREEN: Appointments Tab

Layout:
- Tab switcher: Upcoming / Past
- List of appointment cards per tab

Appointment Card:
  [Doctor Photo 56px]  Dr. Ahmad Rizal
                       General Practitioner
                       TTDI Branch
  Date: Monday, 14 July 2025    Time: 10:30 AM
  [Status chip: Confirmed]

- Tap card -> Appointment Detail screen
- Past tab: same card layout, muted status chip

Empty state: No upcoming appointments + Book Now button

---

### SCREEN: Booking Flow — Step 1: Select Branch

Layout:
- App bar: Book Appointment, back arrow
- Step indicator: 1 Branch > 2 Doctor > 3 Date & Time > 4 Confirm
- Branch list — vertical scroll
- Each branch card: branch photo, name, address, operating hours
- Selected branch: accent border highlight
- Next button (disabled until branch selected)

Data: GET /api/v2/config/branches

---

### SCREEN: Booking Flow — Step 2: Select Doctor

Layout:
- Step indicator (step 2 active)
- No Preference card at top (always first):
    Icon: group/people icon
    Label: No Preference
    Subtitle: We will find the earliest available slot for you
- Doctor cards below — only doctors assigned to selected branch with is_visible_in_app = true
- Each doctor card: circle avatar (64px), name, specialty
- Selected doctor: accent border highlight
- Next button (disabled until selection made)

---

### SCREEN: Booking Flow — Step 3: Date & Time

Layout:
- Step indicator (step 3 active)
- Month selector: left/right arrows, current month label center
  - Only future months allowed — validate before API call
- Calendar grid: highlight days that have available slots
- On day tap: time slot chips appear below calendar
- Time slot chips:
    Available: outlined accent chip
    Unavailable: greyed, not tappable
    Selected: solid accent chip
- Skeleton loader while fetching slots (calendar + chips shape)
- Continue button (disabled until slot selected)

API: POST /appointment/slots via Laravel proxy

---

### SCREEN: Booking Flow — Step 4: Confirm & WhatsApp

Layout:
- Step indicator (step 4 active)
- Summary card:
    Branch:   [Branch Name]
    Doctor:   [Doctor Name / No Preference]
    Date:     [Selected Date]
    Time:     [Selected Time]
    Patient:  [Name], [NRIC]
- Info banner (teal bg, white text):
    Your preferred slot is not confirmed until our team responds via WhatsApp.
- Book via WhatsApp primary button (WhatsApp icon)

On tap: open WhatsApp deep link with pre-filled message.

Pre-filled message:
  Hi He Clinic [Branch Name]!

  I would like to book an appointment:
  - Name: [Patient Name]
  - NRIC: [Patient NRIC]
  - Branch: [Branch Name]
  - Doctor: [Doctor Name / No Preference]
  - Date: [Selected Date]
  - Time: [Selected Time]

  Please confirm my appointment. Thank you!

Deep link: https://wa.me/{branch_whatsapp_number}?text={url_encoded_message}

---

### SCREEN: Health Tab

Layout:
- Tab switcher: Records / Vitals / Documents

Records Tab:
- Filter chips at top: All / Notes / Letters / Lab Results / MC
- Each record card: type icon, title, date, doctor name
- Tap -> Record Detail screen (full text or PDF viewer)
- Paginated list, skeleton while loading

Vitals Tab:
- One graph card per vital type (weight, BP, blood glucose, etc.)
- Line chart with date axis
- Render dynamically based on GET /patient/{id}/graphing response shape
- Empty state if no vitals recorded yet

Documents Tab:
- PDF document list
- Each item: file icon, document name, upload date, admin note (if any)
- Tap -> opens PDF viewer (webview)
- Sorted: newest first
- Skeleton while loading

---

### SCREEN: Notifications Tab

Layout:
  Notifications                    [Mark all read]
  ----------------------------------------
  [Blue dot]  Appointment Confirmed          <- unread
              Your appointment with Dr...
              2 hours ago
  ----------------------------------------
              New Document Available         <- read (no dot)
              Your blood test result is...
              Yesterday
  ----------------------------------------

- Unread card: subtle #F0FDF4 background tint
- Tap card: mark as read + navigate to deep link if present
- Swipe left to dismiss notification
- Mark all read in app bar trailing
- Empty state: You are all caught up

---

### SCREEN: Profile Tab

Layout (scrollable):
  [Avatar 80px]  {Full Name}
                 {Email}
                 {NRIC}

  My Details                        [Edit arrow]

  Settings
    > Biometric Login               [toggle]
    > Notification Preferences      [arrow]
    > Change Password               [arrow]

  About
    > He Clinic Info                [arrow]
    > Privacy Policy                [arrow]
    > Terms of Service              [arrow]

  [Log Out]  <- destructive button, full width

---

### SCREEN: Profile Edit

Layout:
- Form fields: Full Name, Phone Number, Date of Birth (date picker), Address
- Profile photo: circular avatar with Change Photo overlay on tap
- Save Changes primary button (sticky at bottom)
- Unsaved changes confirmation prompt on back navigation

---

### SCREEN: Doctor Detail (Bottom Sheet)

Layout:
  [Handle bar]

  [Doctor Photo — 100px circle, centered]
  Dr. Ahmad Rizal                    <- heading-md, centered
  General Practitioner               <- body-md, text-secondary, centered
  TTDI Branch                        <- body-sm, text-secondary, centered

  About                              <- heading-sm
  [Bio text]                         <- body-md

  [Book Appointment — primary button, full width]

---

### SCREEN: Branch Detail

Layout:
- Hero image (branch photo, 220px, full width)
- Branch name (heading-lg), address (body-md)
- Operating hours (body-md)
- Get Directions button -> maps.google.com/?q={lat},{lng}
- WhatsApp Us button -> WA deep link (branch WA number)
- Tap triggers deep link to external apps

---


### SCREEN: Articles List

Access: Home -> Health Tips -> See All

Layout:
- App bar: Health Tips, back arrow
- Vertical list of article cards, paginated (10/page)
- Each article card:
    Featured image (full width, 140px height, lg radius)
    Category chip (top-left over image, if category set)
    Title (heading-sm, 2 lines max)
    Excerpt (body-sm, text-secondary, 2 lines max)
    Author + published date (body-sm, text-secondary)
- Skeleton loader (image rect + 3 text bars) while loading
- Empty state: illustration + "No articles yet" + "Check back soon for health tips and updates"
- Error state: error icon + Try Again button

Data: GET /api/v2/cms/articles (paginated, 10/page)
Tap card -> Article Detail screen (existing spec)

---

### SCREEN: Videos List

Access: Home -> Videos -> See All

Layout:
- App bar: Videos, back arrow
- 2-column grid of video thumbnail cards, paginated (10/page)
- Each video card:
    Thumbnail image (16:9 ratio, lg radius)
    Play icon overlay (centered, 36px, white, semi-transparent bg circle)
    Title (body-sm, 2 lines max, below thumbnail)
    TikTok author handle (body-sm, text-secondary, below title)
- Skeleton loader (thumbnail rect + 2 text bars per card) while loading
- Empty state: illustration + "No videos yet" + "Check back soon for our latest videos"
- Error state: error icon + Try Again button

Data: GET /api/v2/cms/videos (paginated, 10/page)
Tap card -> url_launcher opens tiktok_url in TikTok app or browser

---

### SCREEN: Article Detail

Layout:
- Featured image (full width, 240px)
- Title (heading-lg), published date + author (body-sm, text-secondary)
- Scrollable rich text content (body-md)
- Share button in app bar trailing

---

## 5. MODAL PATTERNS

### Confirmation Modal

Used for irreversible actions: logout, cancel appointment, delete.

  [Warning icon — 48px]
  Are you sure?                      <- heading-md, centered
  This action cannot be undone.      <- body-md, text-secondary, centered

  [Cancel — ghost btn]  [Confirm — destructive btn]

### Success Modal

After completing a key action: booking sent, password changed, profile saved.

  [Animated checkmark — accent, 64px]
  Done!                              <- heading-md, centered
  [Context-specific message]         <- body-md, text-secondary, centered

  [Back to Home — primary button, full width]

### Loading Modal

For operations that take time. Blocks interaction until complete.

  [Circular spinner — accent color]
  Please wait...                     <- body-md, text-secondary

Backdrop blocks all interaction. Auto-dismisses when operation completes.

---

## 6. ERROR AND FEEDBACK PATTERNS

### Inline Form Validation

- Validate on field blur (not on keystroke)
- Error message below field in error color (#EF4444)
- Field border turns red on error
- Border returns to accent green immediately on valid input

### API Error Handling (UI Layer)

| Error | UI Response |
|-------|------------|
| 401 Unauthorized | Redirect to Login + toast: Session expired. Please log in again. |
| 429 Too Many Requests | Retry silently with backoff. After 4 retries: toast Too many requests, please try again in a moment. |
| 500 Server Error | Error state component + Try Again button |
| No internet | Orange banner at top: No internet connection — showing last synced data |
| Timeout | Toast: Request timed out. Please check your connection. |

### Offline Behaviour

- App remains usable for read-only cached content
- Labelled: Last synced: {time} shown in relevant list screens
- Write operations show: You need an internet connection for this action

---

## 7. TRANSITIONS AND ANIMATIONS

| Transition | Type | Duration |
|-----------|------|----------|
| Screen push (forward) | Slide left | 300ms ease |
| Screen pop (back) | Slide right | 300ms ease |
| Bottom sheet open | Slide up + fade | 350ms spring |
| Bottom sheet close | Slide down + fade | 280ms ease |
| Tab switch | Fade | 200ms |
| Toast appear | Slide up + fade | 250ms |
| Skeleton to content | Crossfade | 300ms |
| Button press | Scale 0.97 | 150ms |

Use flutter_animate package (already in pubspec) for all animations.

---

## 8. DARK MODE

All screens support dark mode. System setting respected automatically.

| Light | Dark |
|-------|------|
| bg-light #F8F9FC | bg-dark #0A0E1A |
| surface #FFFFFF | surface-dark #141C2E |
| text-primary #0F1B3D | text-inverse #FFFFFF |
| text-secondary #6B7280 | #9CA3AF |
| divider #E5E7EB | #1F2937 |

Primary, accent, error, success, warning colors remain the same in both modes.

---

## 9. ADMIN PANEL UI

### Layout

  +------------------+------------------------------------------+
  |                  |  Top bar: breadcrumb + user avatar       |
  |  Sidebar (dark)  +------------------------------------------+
  |                  |                                          |
  |  Nav items       |  Content area (light bg)                 |
  |                  |                                          |
  +------------------+------------------------------------------+

### Sidebar

- Background: #0A0E1A
- He Clinic logo at top (32px height)
- Nav items: icon (20px) + label, white 60% opacity at rest
- Active item: white 100% + 3px accent (#00C9A7) left border
- Width: 260px (desktop), collapses to icon-only on mobile
- Bottom: user avatar + name + logout icon

### Admin Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Sidebar bg | #0A0E1A | Sidebar |
| Content bg | #F8F9FC | Main content area |
| Surface | #FFFFFF | Cards, tables |
| Accent | #00C9A7 | Buttons, active nav, badges |
| Text | #0F1B3D | Body text |
| Text secondary | #6B7280 | Table labels, captions |
| Border | #E5E7EB | Table borders, dividers |

### Admin Tables

- Striped rows: every other row #F9FAFB
- Sticky header on scroll
- Per-row actions: Edit (pencil icon), View (eye icon), Delete (trash icon) — right-aligned
- Pagination: Previous / 1 2 3 ... / Next — bottom of table
- Search input: above table, left-aligned, with search icon
- Filter chips: right of search, for status / branch / date filters

### Admin Forms

- Full width on mobile, max 720px centered on desktop
- Section grouping with heading-sm labels and dividers
- Save button: sticky bottom on mobile, top-right on desktop
- Unsaved changes: browser confirm prompt before navigate away

### Admin Modals

- Max width: 520px, centered overlay
- Same confirmation modal pattern as mobile (warning icon, cancel + confirm buttons)
- Close X in top right corner

---


### ADMIN: CMS — Articles

Access: Admin Panel sidebar -> CMS -> Articles

List View:
- Table with columns: Featured Image (thumbnail 48px), Title, Category, Status (chip), Published Date, Sort Order, Actions
- Filter chips: All / Published / Draft
- Search input: search by title
- Per-row actions: Edit, Delete
- New Article button (top right, primary)
- Drag handle column for reordering sort_order

Create / Edit Article Form:
- Title (text input, required)
- Slug (auto-generated from title, editable)
- Category (text input or dropdown if predefined list)
- Author Name (text input, optional)
- Featured Image (upload zone — drag & drop or click, preview shown after upload, stored to Firebase Storage)
- Excerpt (textarea, optional — auto-truncated from body if left empty)
- Body (TipTap rich text editor — bold, italic, headings, bullet list, numbered list, links, images)
- Status toggle: Draft / Published
- Published At (datetime picker — defaults to now on first publish)
- Sort Order (number input)
- Save button (top-right on desktop, sticky bottom on mobile)

Delete: confirmation modal before delete

---

### ADMIN: CMS — Videos

Access: Admin Panel sidebar -> CMS -> Videos

List View:
- Table with columns: Thumbnail (48px), Title, TikTok Author, Status (chip), Published Date, Sort Order, Actions
- Filter chips: All / Published / Draft
- Per-row actions: Edit, Delete
- New Video button (top right, primary)
- Drag handle column for reordering sort_order

Create / Edit Video Form:
- TikTok URL (text input, required)
  - Fetch Info button beside URL field
  - On click: POST /api/v2/admin/cms/videos/fetch-info -> fills Title + Thumbnail preview
  - Loading state on button while fetching
  - Error inline if URL invalid or oEmbed fetch fails
- Thumbnail preview (shown after fetch, 16:9, lg radius)
  - Label: Fetched from TikTok — cached automatically on save
- Title (text input, pre-filled from oEmbed, admin can override)
- TikTok Author (read-only, from oEmbed)
- Status toggle: Draft / Published
- Published At (datetime picker)
- Sort Order (number input)
- Save button

Delete: confirmation modal before delete

---

## 10. ACCESSIBILITY

- Minimum tap target: 44x44px on all interactive elements
- Color contrast: minimum 4.5:1 for body text, 3:1 for large text
- All images: semanticLabel / alt text provided
- Form fields: explicit labels — never placeholder-only
- Focus indicators: visible on all focusable elements
- Screen reader: logical reading order maintained
- No information conveyed by color alone — always pair with icon or text

Note: Full WCAG 2.1 AA compliance requires manual testing with assistive technologies.

---

## RELATED DOCUMENTS

| Document | Purpose |
|----------|---------|
| docs/v2-decisions.md | Locked decisions, process flow, backend spec |
| docs/CODEBASE.md | Technical audit of existing codebase |
| docs/api-guidelines.md | Official Plato API reference |
| docs/v2-pitch-deck.md | Client proposal |
