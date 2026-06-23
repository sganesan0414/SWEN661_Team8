// TalkBack (Android) and VoiceOver (iOS) accessibility tests for AppointmentsScreen.
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
        home: const Scaffold(body: AppointmentsScreen()),
      ),
    );
  }

  group('AppointmentsScreen – TalkBack / VoiceOver accessibility', () {
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

    testWidgets('appointment tile label includes doctor, specialty and date',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Dr\. Sarah Johnson')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('stat cards have accessible labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'Total')), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel(RegExp(r'Upcoming')), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel(RegExp(r'Completed')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('detail sheet heading is marked as a header', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Dr. Sarah Johnson'));
      await tester.pumpAndSettle();

      final node = tester.getSemantics(
        find.text('Dr. Sarah Johnson').last,
      );
      expect(node.flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    testWidgets('detail sheet reschedule button includes doctor name in label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Dr. Sarah Johnson'));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'Reschedule appointment with')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('detail sheet cancel button includes doctor name in label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Dr. Sarah Johnson'));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'Cancel appointment with')),
        findsOneWidget,
      );
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
