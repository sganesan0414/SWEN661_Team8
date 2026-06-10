import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/screens/dashboard_screen.dart';
import 'package:careconnect/theme/app_theme.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import '../mocks.dart';

Widget wrap(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(theme: AppTheme.theme, home: const DashboardScreen()),
);

void main() {
  setUpAll(registerFallbacks);



  testWidgets('renders home tab with AppBar title CareConnect', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    expect(find.text('CareConnect'), findsOneWidget);
  });

  testWidgets('tapping Medications tab changes title', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.medication_outlined).last);
    await tester.pump();
    expect(find.text('My Medications'), findsOneWidget);
  });

  testWidgets('reminders tab shows Coming Soon', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pump();
    expect(find.text('Coming Soon'), findsOneWidget);
  });

  testWidgets('quick action navigates to Health Metrics screen', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    await tester.tap(find.text('Health\nMetrics'));
    await tester.pumpAndSettle();
    expect(find.text('Health Metrics'), findsOneWidget);
  });

  testWidgets('quick action navigates to Health Reports screen', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Health Reports'), findsOneWidget);
  });

  testWidgets('sign out button returns to Welcome Back screen', (tester) async {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});

    await tester.pumpWidget(wrap([
      notificationServiceProvider.overrideWithValue(mockNotif),
    ]));
    await tester.pump();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
