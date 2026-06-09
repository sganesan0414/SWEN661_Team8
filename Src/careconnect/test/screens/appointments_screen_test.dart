import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/screens/appointments_screen.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'package:careconnect/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  Widget wrap() {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});
    return ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(mockNotif)],
      child: MaterialApp(theme: AppTheme.theme, home: const Scaffold(body: AppointmentsScreen())),
    );
  }

  group('AppointmentsScreen', () {
    testWidgets('renders appointment list', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
      expect(find.text('Dr. Michael Chen'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('tapping appointment shows detail sheet', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Dr. Sarah Johnson'));
      await tester.pumpAndSettle();
      expect(find.text('Annual Physical Exam'), findsAtLeastNWidgets(1));
    });
  });
}
