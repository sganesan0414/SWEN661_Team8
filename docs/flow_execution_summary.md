# Flow Execution Summary

**Project:** CareConnect (SWEN661 Team 8)
**Scope:** Integration tests — multi-screen workflows and interactions
**Test command:** `flutter test test/app_flow_test.dart` (run from `Src/careconnect`)
**Date executed:** 2026-06-23
**Result:** 1 / 1 test cases passed, 0 failed
**Total flows executed:** 12

## Flow Inventory

Every row below is a distinct screen-to-screen transition exercised within the single end-to-end test case `sign in, push/pop a screen, visit every tab, sign out` in [test/app_flow_test.dart](../Src/careconnect/test/app_flow_test.dart).

> **Note:** `account_provider.dart` was rewritten mid-project from an always-succeeds mock to real credential validation against accounts persisted via `SharedPreferences`. This broke the original version of this test (`pumpAndSettle timed out`, since the hardcoded sign-in credentials no longer matched any registered account). The test now registers an account through the real Create Account screen before signing in, matching the app's actual auth flow.

| # | Flow | Trigger | Verification | Status |
|---|---|---|---|---|
| 1 | Create Account → Login | Fill registration form, tap "Continue" | "Account created" snackbar; returns to "Welcome Back" | ✅ Pass |
| 2 | Login → Dashboard | Tap "Sign In" with the registered account's credentials | Dashboard AppBar shows "CareConnect"; greeting shows "Good Morning, Siva" | ✅ Pass |
| 3 | Dashboard → Health Metrics → back | Tap "Health Metrics" Quick Action tile | "Health Metrics" title renders; back arrow returns to "CareConnect" | ✅ Pass |
| 4 | Dashboard → Profile → back | Tap "Good Morning, Siva" greeting | "Profile" title renders; back navigation returns to "CareConnect" | ✅ Pass |
| 5 | Dashboard → Settings → back | Tap Settings icon (AppBar action, tooltip "Open settings") | "Settings" / "Manage your accessibility preferences" renders; back returns to "CareConnect" | ✅ Pass |
| 6 | Dashboard → Pharmacy → back | Tap "Pharmacy" Quick Action tile | "My Pharmacies" renders; back returns to "CareConnect" | ✅ Pass |
| 7 | Dashboard tab: Home → Medications | Tap "Medications" bottom-nav item | Context breadcrumb shows "Home › My Medications" | ✅ Pass |
| 8 | Dashboard tab: Medications → Appointments | Tap "Appointments" bottom-nav item | Context breadcrumb shows "Home › Appointments" | ✅ Pass |
| 9 | Dashboard tab: Appointments → Reminders | Tap "Reminders" bottom-nav item | Context breadcrumb shows "Home › Reminders" | ✅ Pass |
| 10 | Dashboard tab: Reminders → Care Team | Tap "Care Team" bottom-nav item | Context breadcrumb shows "Home › Care Team" | ✅ Pass |
| 11 | Dashboard tab: Care Team → Home | Tap "Home" bottom-nav item | Context breadcrumb shows "Home - Daily Overview" | ✅ Pass |
| 12 | Dashboard → Sign out → Login | Tap "Sign out" (AppBar action) | Returns to LoginScreen, "Welcome Back" renders | ✅ Pass |

## Cross-Validation (independent single-flow tests)

These flows are also each verified independently in [test/screens/dashboard_screen_test.dart](../Src/careconnect/test/screens/dashboard_screen_test.dart), providing redundant coverage outside the combined end-to-end run:

| Flow | Test case | Status |
|---|---|---|
| Dashboard tab: Home → Medications | `tapping Medications tab changes title` | ✅ Pass |
| Dashboard → Health Metrics | `quick action navigates to Health Metrics screen` | ✅ Pass |
| Dashboard → Health Reports | `quick action navigates to Health Reports screen` | ✅ Pass |
| Dashboard → Sign out → Login | `sign out button returns to Welcome Back screen` | ✅ Pass |

## Full Suite Context

Run alongside the full suite (`flutter test`) for regression context:

- **Total test cases:** 430
- **Passed:** 430
- **Failed:** 0
- **Code coverage:** 91.34% (2,532 / 2,772 lines) — re-measured from the full 430-test suite after the `account_provider.dart` rewrite. Raw data in `coverage/lcov.info`.
  - `coverage/html/index.html` (the `genhtml`-rendered view) is **not usable on this machine**: this Perl-based tool has a Windows-specific bug where its final summary reports "no data found" despite `lcov.info` containing fully valid, verified per-file `LF:`/`LH:`/`DA:` records (confirmed by independently parsing the file). The numeric figures above are computed directly from `lcov.info`, not from the broken HTML view.
  - Lowest-covered files: `lib/main.dart` (69.2%), `lib/providers/appointments_provider.dart` (72.9%), `lib/screens/pin_screen.dart` (77.1%), `lib/screens/user_profile.dart` (80.1%).

## Known Gaps (not yet automated as flows)

- Medications ↔ Pharmacy cross-link
- Care Team ↔ other-screen cross-links
- `Src/careconnect/e2e/login_flow.yaml` (a Maestro flow testing invalid-credential sign-in) exists in the repo but has never been executed — no report artifact found for it.
- `.maestro/` flows in this repo are unverified against a real device/emulator due to an intermittent Maestro Android driver connection issue on this machine (see `.maestro/README.md`).
