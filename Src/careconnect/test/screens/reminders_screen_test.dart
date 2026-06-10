import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/reminders.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.theme,
        home: child,
      ),
    );

void main() {
  group('RemindersScreen', () {
    testWidgets('renders active reminders summary and due medications', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(_wrap(const RemindersScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Reminders'), findsWidgets);
      expect(find.text('Add Reminder'), findsOneWidget);
      expect(find.textContaining('active reminders'), findsOneWidget);
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Atorvastatin'), findsOneWidget);
      expect(find.text('Aspirin'), findsOneWidget);
      expect(find.text('Omeprazole'), findsOneWidget);
    });

    testWidgets('renders quick actions section and global settings', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Test All Reminders'), findsOneWidget);
      expect(find.text('Snooze All (1 hour)'), findsOneWidget);
      expect(find.text('Global Settings'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });
  });
}
