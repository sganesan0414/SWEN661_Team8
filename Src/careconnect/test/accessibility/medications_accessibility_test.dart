// TalkBack (Android) and VoiceOver (iOS) accessibility tests for MedicationsScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/medications_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const MedicationsScreen()),
    );

void main() {
  group('MedicationsScreen – TalkBack / VoiceOver accessibility', () {
    // ── Android TalkBack ────────────────────────────────────────────────────

    testWidgets('meets Android tap-target guideline (48×48 dp minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all tappable elements have semantic labels (TalkBack)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // ── iOS VoiceOver ───────────────────────────────────────────────────────

    testWidgets('meets iOS tap-target guideline (44×44 pt minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    // ── Color contrast ──────────────────────────────────────────────────────

    testWidgets('text meets WCAG AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic labels ─────────────────────────────────────────────────────

    testWidgets('search field announces "Search medications" to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Ss]earch medications')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets(
        '"Mark as Taken" button includes medication name in semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Mark .+ as taken')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('medication card announces taken status to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Cards have combined labels that include taken / not-yet-taken status
      expect(
        find.bySemanticsLabel(RegExp(r'(Already taken|Not yet taken)')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('stat cards have accessible combined labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'Total Medications')),
          findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Taken Today')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Upcoming')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('add medication button has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Aa]dd medication')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Dynamic text scaling ────────────────────────────────────────────────

    testWidgets('renders without overflow at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: _wrap(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
