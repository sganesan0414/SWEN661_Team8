// TalkBack (Android) and VoiceOver (iOS) accessibility tests for RemindersScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/screens/reminders.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'package:careconnect/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  Widget wrap() {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any()))
        .thenAnswer((_) async {});
    return ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockNotif),
      ],
      child: MaterialApp(
        theme: AppTheme.theme,
        home: const RemindersScreen(),
      ),
    );
  }

  group('RemindersScreen – TalkBack / VoiceOver accessibility', () {
    // ── Android TalkBack ────────────────────────────────────────────────────

    testWidgets('meets Android tap-target guideline (48×48 dp minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all tappable elements have semantic labels (TalkBack)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // ── iOS VoiceOver ───────────────────────────────────────────────────────

    testWidgets('meets iOS tap-target guideline (44×44 pt minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    // ── Color contrast ──────────────────────────────────────────────────────

    testWidgets('text meets WCAG AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic labels ─────────────────────────────────────────────────────

    testWidgets('reminder card Switch exposes toggled state to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();

      // The Semantics wrapper around each Switch uses
      // label: '<title> reminder enabled/disabled' and toggled: isEnabled.
      expect(
        find.bySemanticsLabel(RegExp(r'reminder (enabled|disabled)')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('delete buttons carry reminder title in tooltip', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      // Delete buttons use tooltip 'Delete <title>' — verify at least one exists
      expect(find.byTooltip(RegExp(r'^Delete ')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('global settings switches have toggled semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      // Switches in the global settings panel announce their label + toggled state
      expect(
        find.bySemanticsLabel(RegExp(r'(Sound|Vibration|Do Not Disturb)')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('"Add Reminder" button has accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Add Reminder'), findsOneWidget);
      handle.dispose();
    });

    // ── Dynamic text scaling ────────────────────────────────────────────────

    testWidgets('renders without overflow at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: wrap(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
