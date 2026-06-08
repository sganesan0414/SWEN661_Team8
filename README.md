# SWEN661_Team8

Project Name : CareConnect

Description  : Team 8 Repository for the STML Accessibility Customization app as part of CareConnect project.

Team Members : Brice Tikum, David Oguh, Sivakumar Ganesan

[Team Charter / Project Plan](https://github.com/sganesan0414/SWEN661_Team8/blob/main/Team8_WK01_Charter_Proposal.docx)

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
