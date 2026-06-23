// TalkBack (Android) and VoiceOver (iOS) accessibility tests for HealthMetricsScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/health_metrics_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(
          theme: AppTheme.theme, home: const HealthMetricsScreen()),
    );

void main() {
  group('HealthMetricsScreen – TalkBack / VoiceOver accessibility', () {
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

    testWidgets('vital cards announce name, value, unit and status',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // VitalCard labels follow pattern: "<name>: <value> <unit>, status: <status>"
      expect(
        find.bySemanticsLabel(RegExp(r'.+: .+ .+, status:')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('vital card status Normal is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'status: Normal')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('recent reading rows announce metric, value and date',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'recorded on')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('save reading button has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Ss]ave reading')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('metric dropdown has descriptive semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Ss]elect metric')),
        findsAtLeastNWidgets(1),
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
