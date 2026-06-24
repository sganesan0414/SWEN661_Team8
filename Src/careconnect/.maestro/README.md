# Maestro Flows

Mirrors the 7 multi-screen workflows already covered by `test/app_flow_test.dart`
(see `docs/flow_execution_summary.md`), but driven against a real
emulator/device instead of the Flutter test harness.

## Prerequisites

- Maestro CLI installed. On Windows this requires WSL — see
  https://maestro.mobile.dev for install instructions.
- An Android emulator or device running, with the app already installed
  (`flutter run` once, or `flutter install`).
- App id: `com.example.careconnect` (from `android/app/build.gradle.kts`).

## Running

```bash
# single flow
maestro test .maestro/login.yaml

# everything in this directory
maestro test .maestro/
```

## Generating a report

```bash
maestro test .maestro/ --format junit --output report.xml
maestro test .maestro/ --format html --output report.html
```

## Known fragility

`dashboard_tab_navigation.yaml` relies on `index: 1` to disambiguate the
bottom-nav label from the identical AppBar title text (Appointments /
Reminders / Care Team). This is a guess at traversal order, not a verified
selector — confirm with `maestro studio`, or add explicit `Key`s to
`CareConnectBottomNav` in `lib/components/widgets.dart` for a stable fix.

Flows not yet covered here (also gaps in the Flutter integration suite):
Medications ↔ Pharmacy, Care Team ↔ other-screen cross-links.
