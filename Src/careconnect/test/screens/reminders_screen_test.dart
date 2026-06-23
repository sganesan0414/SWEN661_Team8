import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/reminder.dart';
import 'package:careconnect/providers/reminders_provider.dart';
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

    testWidgets('toggling a medication switch flips its enabled label', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      final lisinoprilCard = find.ancestor(
        of: find.text('Lisinopril'),
        matching: find.byType(Column),
      ).first;
      final switchFinder = find.descendant(
        of: find.ancestor(of: lisinoprilCard, matching: find.byType(Container)).first,
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('canceling delete keeps the medication reminder', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      final deleteIcon = find.byIcon(Icons.delete_outline).first;
      await tester.ensureVisible(deleteIcon);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();
      expect(find.text('Delete Reminder'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Lisinopril'), findsOneWidget);
    });

    testWidgets('confirming delete removes the medication reminder', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      final deleteIcon = find.byIcon(Icons.delete_outline).first;
      await tester.ensureVisible(deleteIcon);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Lisinopril'), findsNothing);
    });

    testWidgets('tapping Add Reminder navigates to the add/edit screen', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      final addButton = find.widgetWithText(ElevatedButton, 'Add Reminder');
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      expect(find.text('Reminder Type'), findsOneWidget);
    });

    testWidgets('toggling the Sound setting switch does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const RemindersScreen()));
      final soundRow = find.ancestor(
        of: find.text('Sound'),
        matching: find.byType(Row),
      ).first;
      final soundSwitch = find.descendant(of: soundRow, matching: find.byType(Switch));
      await tester.ensureVisible(soundSwitch);
      await tester.tap(soundSwitch);
      await tester.pump();
    });
  });

  group('RemindersScreen custom reminders', () {
    Reminder buildCustomReminder() => const Reminder(
          id: 'custom-1',
          type: ReminderType.medication,
          title: 'Drink water',
          subtitle: 'Stay hydrated',
          time: TimeOfDay(hour: 9, minute: 0),
          days: [true, true, true, true, true, true, true],
        );

    testWidgets('renders a seeded custom reminder under My Reminders', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(remindersProvider.notifier).add(buildCustomReminder());

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.theme, home: const RemindersScreen()),
      ));
      expect(find.text('My Reminders'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
    });

    testWidgets('toggling a custom reminder updates provider state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(remindersProvider.notifier).add(buildCustomReminder());

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.theme, home: const RemindersScreen()),
      ));
      final toggle = find.descendant(
        of: find.ancestor(of: find.text('Drink water'), matching: find.byType(Container)).first,
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      expect(container.read(remindersProvider).first.isEnabled, isFalse);
    });

    testWidgets('editing a custom reminder navigates to the edit screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(remindersProvider.notifier).add(buildCustomReminder());

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.theme, home: const RemindersScreen()),
      ));
      final editIcon = find.byIcon(Icons.edit_outlined);
      await tester.ensureVisible(editIcon);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();
      expect(find.text('Edit Reminder'), findsOneWidget);
    });

    testWidgets('deleting a custom reminder removes it after confirmation', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(remindersProvider.notifier).add(buildCustomReminder());

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.theme, home: const RemindersScreen()),
      ));
      final deleteIcon = find.byIcon(Icons.delete_outline).first;
      await tester.ensureVisible(deleteIcon);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(container.read(remindersProvider), isEmpty);
    });
  });
}
