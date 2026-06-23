import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/care_team_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: Scaffold(body: child)),
    );

void main() {
  group('CareTeamScreen – functional', () {
    testWidgets('renders member list', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
      expect(find.text('Patricia Williams'), findsOneWidget);
      expect(find.text('Dr. Michael Chen'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('Emergency Contacts'), findsOneWidget);
    });

    testWidgets('shows emergency badge on emergency contact', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Emergency'), findsOneWidget);
    });

    testWidgets('Manage Access button is present for each member',
        (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.text('Manage Access'), findsAtLeastNWidgets(1));
    });

    testWidgets('phone number chip is visible', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.phone_outlined), findsAtLeastNWidgets(1));
    });
  });

  // ── TalkBack / VoiceOver accessibility ────────────────────────────────────

  group('CareTeamScreen – TalkBack (Android) accessibility', () {
    testWidgets('meets Android 48×48 dp tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all interactive elements have semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('text meets WCAG AA color contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('CareTeamScreen – VoiceOver (iOS) accessibility', () {
    testWidgets('meets iOS 44×44 pt tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });
  });

  group('CareTeamScreen – semantic tree', () {
    testWidgets('member card announces name and role', (tester) async {
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

    testWidgets('emergency contact annotation is in semantic label',
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

    testWidgets('phone chip exposes "Phone:" prefix to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'^Phone:')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('email chip exposes "Email:" prefix to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'^Email:')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('"Manage Access" label includes member name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Manage access for')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('stat cards expose value + label to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'Total Members')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Emergency Contacts')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('renders without overflow at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: _wrap(const CareTeamScreen()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
