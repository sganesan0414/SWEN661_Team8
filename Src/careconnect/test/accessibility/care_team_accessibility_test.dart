// TalkBack (Android) and VoiceOver (iOS) accessibility tests for CareTeamScreen.
// Validates WCAG 2.1 Level AA requirements: touch targets, semantic labels,
// color contrast, and screen-reader state announcements.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/care_team_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('CareTeamScreen – TalkBack / VoiceOver accessibility', () {
    // ── Android TalkBack ────────────────────────────────────────────────────

    testWidgets('meets Android tap-target guideline (48×48 dp minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(
          tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all tappable elements have semantic labels (TalkBack)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(
          tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // ── iOS VoiceOver ───────────────────────────────────────────────────────

    testWidgets('meets iOS tap-target guideline (44×44 pt minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(
          tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    // ── Color contrast ──────────────────────────────────────────────────────

    testWidgets('text meets WCAG AA contrast ratio (4.5:1 normal / 3:1 large)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic tree ───────────────────────────────────────────────────────

    testWidgets('member cards expose combined name + role semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(
            RegExp(r'Dr\. Sarah Johnson.*Primary Care Physician')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('emergency contact includes "Emergency Contact" in label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp(r'Emergency Contact')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('contact chips announce phone number with "Phone:" prefix',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp(r'^Phone:')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('contact chips announce email address with "Email:" prefix',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp(r'^Email:')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('"Manage Access" button label includes member name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp(r'Manage access for')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('stat cards have combined value + label semantic annotation',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp(r'Total Members')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Emergency Contacts')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Dynamic text scaling ────────────────────────────────────────────────

    testWidgets('renders without overflow at 200% text scale',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: _wrap(const CareTeamScreen()),
        ),
      );
      await tester.pump();
      // If there were overflow errors, tester would throw.
      expect(tester.takeException(), isNull);
    });
  });
}
