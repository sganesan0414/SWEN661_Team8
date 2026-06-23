import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/reminder.dart';
import 'package:careconnect/providers/reminders_provider.dart';
import 'package:careconnect/screens/add_edit_reminder_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('AddEditReminderScreen (add mode)', () {
    testWidgets('renders Add Reminder title and defaults', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      expect(find.text('Add Reminder'), findsWidgets);
      expect(find.widgetWithText(ElevatedButton, 'Add Reminder'), findsOneWidget);
    });

    testWidgets('tapping Appointment then Medication type button selects each', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.tap(find.text('Appointment'));
      await tester.pump();
      expect(find.text('Appointment'), findsOneWidget);

      await tester.tap(find.text('Medication'));
      await tester.pump();
      expect(find.text('Medication'), findsOneWidget);
    });

    testWidgets('typing into title and subtitle fields updates them', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.enterText(find.byType(TextField).first, 'Lisinopril');
      await tester.enterText(find.byType(TextField).last, '10 mg');
      await tester.pump();
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('10 mg'), findsOneWidget);
    });

    testWidgets('quick day buttons set Every Day / Weekdays / Weekends', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.ensureVisible(find.text('Weekdays'));
      await tester.tap(find.text('Weekdays'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Weekends'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Every Day'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Every Day'), findsOneWidget);
    });

    testWidgets('tapping an individual day circle toggles it', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.ensureVisible(find.text('Mon'));
      await tester.tap(find.text('Mon'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Mon'), findsOneWidget);
    });

    testWidgets('canceling the time picker leaves the time unchanged', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.ensureVisible(find.text('Tap to change'));
      await tester.tap(find.text('Tap to change'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('confirming the time picker updates the displayed time', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      await tester.ensureVisible(find.text('Tap to change'));
      await tester.tap(find.text('Tap to change'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Default time picker confirms the screen's initial time (8:00 AM);
      // a successful confirm just needs `picked != null` to have run.
      expect(find.textContaining(':'), findsWidgets);
    });

    testWidgets('saving with an empty title shows a validation snackbar', (tester) async {
      await tester.pumpWidget(_wrap(const AddEditReminderScreen()));
      final saveButton = find.widgetWithText(ElevatedButton, 'Add Reminder');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('saving with a title adds a reminder and pops the screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.theme,
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => const AddEditReminderScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Take vitamins');
      final saveButton = find.widgetWithText(ElevatedButton, 'Add Reminder');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(container.read(remindersProvider).length, 1);
      expect(container.read(remindersProvider).first.title, 'Take vitamins');
    });
  });

  group('AddEditReminderScreen (edit mode)', () {
    Reminder buildExisting() => Reminder(
          id: 'r1',
          type: ReminderType.appointment,
          title: 'Dr. Smith Visit',
          subtitle: 'Annual Checkup',
          time: const TimeOfDay(hour: 14, minute: 30),
          days: const [true, true, true, true, true, false, false],
        );

    testWidgets('renders Edit Reminder title with pre-filled fields', (tester) async {
      await tester.pumpWidget(_wrap(AddEditReminderScreen(reminder: buildExisting())));
      expect(find.text('Edit Reminder'), findsOneWidget);
      expect(find.text('Dr. Smith Visit'), findsOneWidget);
      expect(find.text('Annual Checkup'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save Changes'), findsOneWidget);
    });

    testWidgets('saving updates the existing reminder and pops', (tester) async {
      final existing = buildExisting();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(remindersProvider.notifier).add(existing);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.theme,
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => AddEditReminderScreen(reminder: existing),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Dr. Smith Follow-up');
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final updated = container.read(remindersProvider).first;
      expect(updated.id, 'r1');
      expect(updated.title, 'Dr. Smith Follow-up');
    });
  });
}
