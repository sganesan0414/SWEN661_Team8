# SWEN661_Team8

Project Name : CareConnect

Description  : Team 8 Repository for the STML Accessibility Customization app as part of CareConnect project.

Team Members : Brice Tikum, David Oguh, Sivakumar Ganesan

[Team Charter / Project Plan](https://github.com/sganesan0414/SWEN661_Team8/blob/main/Team8_WK01_Charter_Proposal.docx)

[STML & WCAG Accessibility Guidelines](docs/STML_WCAG_GUIDELINES.md)

## Architecture Overview

```
Src/careconnect/lib/
├── main.dart                  - Providers and Notification setup
├── models/                    - Dart data classes
│   ├── medication.dart
│   ├── appointment.dart
│   ├── care_team_member.dart
│   ├── health_metric.dart
│   └── health_report.dart
├── services/
│   └── notification_service.dart  - flutter_local_notifications setup
├── providers/                 - Riverpod StateNotifierProviders. One provider per data area
│   ├── account_provider.dart
│   ├── medications_provider.dart
│   ├── appointments_provider.dart
│   ├── care_team_provider.dart
│   ├── health_metrics_provider.dart
│   └── health_reports_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── medications_screen.dart        - Standalone screen
│   ├── appointments_screen.dart       - Tab 2 content widget
│   ├── care_team_screen.dart          - Tab 4 content widget
│   ├── health_metrics_screen.dart     - Pushed from dashboard Quick Actions
│   └── health_reports_screen.dart     - Pushed from dashboard Quick Actions
├── components/widgets.dart
└── theme/app_theme.dart       - STML based AppColors, AppTextStyles, AppTheme
```

## Screen Map

| Screen | How to reach | Tab index |
|---|---|---|
| LoginScreen | from app launch | - |
| DashboardScreen | after sign-in | shell |
| Home tab | default dashboard | 0 |
| Medications tab | bottom nav or Quick Action | 1 |
| Appointments tab | bottom nav or Quick Action | 2 |
| Reminders tab | bottom nav | 3 |
| Care Team tab | bottom nav | 4 |
| HealthMetricsScreen | Quick Action tile on home | pushed |
| HealthReportsScreen | Quick Action tile on home | pushed |

## Providers

| Provider | Usage |
|---|---|
| `accountProvider` | Sign-in / sign-out, profile info |
| `medicationsProvider` | Medication list, state, undo, search  |
| `appointmentsProvider` | Setup and list appointment w/ CRUD, schedules/cancels notifications |
| `careTeamProvider` | Care team member list, add/remove |
| `healthMetricsProvider` | Vital readings grid, add reading |
| `healthReportsProvider` | create and list (monthly/quarterly/custom) reports and share them |
| `notificationServiceProvider` | Plain Provider for notifications |

## Accessibility Features

CareConnect is built as an STML (Sensory, Touch, Motor, Language) accessibility-first
application. Accessibility is implemented in the shared theme/design system and in the
semantic markup of every screen, and is verified by a dedicated automated test suite.
See the [STML & WCAG Accessibility Guidelines](docs/STML_WCAG_GUIDELINES.md) for the
design rationale. A formal VPAT 2.5 (WCAG 2.1) conformance assessment and a WCAG 2.1
Level AA criteria checklist are maintained as separate project deliverables.

### Screen reader support (TalkBack / VoiceOver)

All 13 screens expose a rich semantics tree (61+ `Semantics` widgets) so that Android
TalkBack and iOS VoiceOver announce controls meaningfully:

- **Descriptive labels** — interactive controls carry explicit `label:` / `semanticLabel`
  text (e.g. `'Email address input'`, `'Show password'`, `'Sign in to your account'`,
  `'Reschedule appointment with Dr. Sarah Johnson'`). Appointment tiles announce the
  doctor, specialty, and date; stat cards announce Total / Upcoming / Completed.
- **Roles** — controls are flagged with `button: true` (21 usages) so they are announced
  and activated as buttons.
- **Headings** — section and detail-sheet titles are flagged with `header: true`
  (e.g. the appointment detail sheet), enabling heading-based navigation.
- **State exposure** — `value`, `selected`, `toggled`, and `enabled` flags communicate
  the current state of toggles, selections, and disabled controls.
- **Grouped reading** — `MergeSemantics` (5 usages) combines related label/value pairs
  into a single, coherent announcement.
- **Decorative noise removed** — purely decorative icons are wrapped in
  `ExcludeSemantics` (13 usages) so the screen reader does not read redundant graphics.
- **Live announcements** — status and validation feedback use `liveRegion: true` so it is
  announced without moving focus (WCAG 4.1.3 Status Messages).

### Keyboard, focus & input

- Form fields use `focusNode`s and `textInputAction` (`next` / `done`) with
  `onFieldSubmitted` to provide a logical, uninterrupted focus order through forms.
- `FocusTraversal` is used to keep traversal order predictable.
- Icon-only buttons include `tooltip`s in addition to semantic labels.
- `autofillHints` (e.g. `AutofillHints.email`, `AutofillHints.password`) are applied to
  credential fields to support platform autofill and input-purpose identification.

### Visual design (contrast & color)

The STML design system (`lib/theme/app_theme.dart`) encodes accessibility into tokens:

- **WCAG-AA color contrast** — text colors are chosen for documented ratios on white:
  `textPrimary` ~16:1, `textSecondary` ~9:1, `textMuted` ~4.6:1, with a high-contrast
  primary blue (`#1A3FB0`).
- **Not color-alone** — state (e.g. medication Taken / Due soon, appointment
  Completed / Upcoming) is paired with text and icons, not signalled by color alone.
- **Visible focus / boundaries** — inputs show a 2&nbsp;px primary-colored focused border;
  controls have visible borders (`#CDD2E0`).

### Touch targets & text scaling

- **Large touch targets** — primary buttons use a 56&nbsp;dp minimum height and text
  buttons enforce a 48&nbsp;dp minimum, exceeding the Android 48&nbsp;dp and iOS 44&nbsp;pt
  guidelines.
- **Dynamic text** — layouts honor the OS font-scale setting and are verified to render
  without overflow at 200% text scale (`TextScaler.linear(2.0)`).

### Automated accessibility testing

The suite in [`test/accessibility/`](Src/careconnect/test/accessibility) contains
**138 accessibility tests across all 12 screens**, run under
`tester.ensureSemantics()` and Flutter's accessibility guideline matchers:

| Guideline matcher | What it verifies |
|---|---|
| `androidTapTargetGuideline` | All tap targets ≥ 48×48&nbsp;dp (TalkBack) |
| `iOSTapTargetGuideline` | All tap targets ≥ 44×44&nbsp;pt (VoiceOver) |
| `labeledTapTargetGuideline` | Every tappable element has a semantic label |
| `textContrastGuideline` | Text meets WCAG AA contrast ratio |

In addition to the four guideline checks, each screen's tests assert specific semantic
behavior — header flags, contextual action labels, live-region announcements, and
no-overflow rendering at 200% text scale.

Run the accessibility tests with:

```bash
flutter test test/accessibility/
```

## Testing

Provider tests (`test/providers/`) use `ProviderContainer` and check for state consistency 

Screen widget tests (`test/screens/`) wrap the screen under test with a fake notification service
```dart
ProviderScope(
  overrides: [notificationServiceProvider.overrideWithValue(MockNotificationService())],
  child: MaterialApp(theme: AppTheme.theme, home: TheScreen()),
)
``` 
so that notifications can be tested (at least without a device) and that widget existence can be detected

Mocks (`test/mocks.dart`) use `mocktail`, `MockNotificationService` stubs `scheduleAppointmentReminder` and `cancelAppointmentReminders` with `thenAnswer((_) async {})`.

## Notification Setup

`flutter_local_notifications` schedules two notifications per appointment. One for the day before and one an hour before
- 24 hours before - "Appointment Tomorrow"
- 1 hour before - "Appointment in 1 Hour"

Cancelling a notification removes both by `id.hashCode` and `id.hashCode + 1`.


# David temp notice

### Required AndroidManifest.xml permissions (already added):
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
