# Flutter Developer — Context

Last Updated: 2026-07-05

## Active Task
P1-T08 (remove-duplicate-profile-pages) — IN-REVIEW

## Last Completed Task
P1-T07 (remove-duplicate-auth-pages) — DONE. Confirmed RegisterPageWidget is the active route (not RegisterPageCopy). Removed RegisterPageCopyWidget route from nav.dart, export from index.dart, and entry from push_notifications_handler.dart. Deleted register_page_copy/ directory. Verified zero remaining references across lib/.

## Known Constraints
- All Plato API calls must route through Laravel proxy (after P1-T01 + P1-T02 complete)
- Use EnvConfig for all base URLs — never hardcode
- Follow FlutterFlow-inherited patterns in docs/CODEBASE.md
- Apply design tokens from docs/v2-ux-spec.md Section 1
- Always implement skeleton loaders, empty states, and error states on list/content screens

## Pending Items
None.
