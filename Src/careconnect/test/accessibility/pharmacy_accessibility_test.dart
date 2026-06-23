// TalkBack (Android) and VoiceOver (iOS) accessibility tests for PharmacyScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/pharmacy.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const PharmacyScreen()),
    );

void main() {
  group('PharmacyScreen – TalkBack / VoiceOver accessibility', () {
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

    testWidgets('prescription cards announce status and refill info',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'status:')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('prescription card labels include refill count', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'refill')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('pharmacy card label includes name, rating and hours',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'CVS Pharmacy.*stars')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('primary pharmacy card notes "your primary pharmacy"',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'your primary pharmacy')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('Get Directions button is labeled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Get Directions'), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('View Details button is labeled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('View Details'), findsAtLeastNWidgets(1));
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
