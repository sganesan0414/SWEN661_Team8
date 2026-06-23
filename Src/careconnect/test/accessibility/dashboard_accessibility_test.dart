// TalkBack (Android) and VoiceOver (iOS) accessibility tests for DashboardScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/screens/dashboard_screen.dart';
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
      overrides: [notificationServiceProvider.overrideWithValue(mockNotif)],
      child: MaterialApp(theme: AppTheme.theme, home: const DashboardScreen()),
    );
  }

  group('DashboardScreen – TalkBack / VoiceOver accessibility', () {
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

    testWidgets('profile greeting button has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Open profile for')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('mini stat cards expose combined label to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Medications Today|Adherence Rate|Next Appointment')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('quick action tiles have semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Medications|Appointments|Health|Reports|Pharmacy')),
        findsAtLeastNWidgets(3),
      );
      handle.dispose();
    });

    testWidgets('alert banner content is reachable by screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      // AlertBanner wraps content in Semantics(liveRegion: true).
      // Verify the title text is present and accessible.
      expect(find.text('Refill Reminder'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('upcoming medication rows have semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'due at')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('next appointment card has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Upcoming appointment:')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('settings and sign-out app-bar buttons have semantic labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.bySemanticsLabel('Open settings'), findsOneWidget);
      expect(find.bySemanticsLabel('Sign out'), findsOneWidget);
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
