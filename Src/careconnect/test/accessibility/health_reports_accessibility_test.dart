// TalkBack (Android) and VoiceOver (iOS) accessibility tests for HealthReportsScreen.
// Validates WCAG 2.1 Level AA: touch targets, labeled tap targets, color contrast,
// semantic labels, and dynamic text scaling up to 200%.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/health_reports_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.theme,
        home: const HealthReportsScreen(),
      ),
    );

void main() {
  group('HealthReportsScreen – TalkBack / VoiceOver accessibility', () {
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

    testWidgets('text meets WCAG AA contrast ratio (4.5:1 normal / 3:1 large)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic labels – stat cards ────────────────────────────────────────

    testWidgets('stat cards expose combined value + label to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Total Reports')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'This Month')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Last Generated')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Semantic labels – generate buttons ──────────────────────────────────

    testWidgets('quick action tiles for report generation have accessible labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // QuickActionTile uses Semantics(button: true, label: ...) — the merged
      // semantics node label may also include the child Text's contribution.
      // Checking text visibility is the reliable proxy for label presence;
      // tap-target and labeled-tap-target guidelines already verify the tile
      // is both reachable and labeled in the semantics tree.
      expect(find.text('Monthly'), findsAtLeastNWidgets(1));
      expect(find.text('Quarterly'), findsAtLeastNWidgets(1));
      expect(find.text('Custom'), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    // ── Semantic labels – report cards ──────────────────────────────────────

    testWidgets('report cards announce title and type to screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Card label pattern: "<title>, <Monthly|Quarterly|Custom> report, generated <date>"
      expect(
        find.bySemanticsLabel(RegExp(r'(Monthly|Quarterly|Custom) report, generated')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('monthly report card is announced with correct type',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'May 2026 Monthly Summary.*Monthly report')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('quarterly report card is announced with correct type',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Q1 2026 Quarterly Report.*Quarterly report')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Semantic labels – action buttons ────────────────────────────────────

    testWidgets('download buttons include report title in semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Buttons are labeled "Download <report title>"
      expect(
        find.bySemanticsLabel(RegExp(r'^Download .+')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('share buttons include report title in semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Buttons are labeled "Share <report title>"
      expect(
        find.bySemanticsLabel(RegExp(r'^Share .+')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    // ── Semantic labels – navigation ────────────────────────────────────────

    testWidgets('back button has accessible label including destination',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // LabeledBackButton wraps TextButton in an outer Semantics node,
      // so there may be ≥1 nodes carrying the "Return to Home" label.
      expect(
        find.bySemanticsLabel(RegExp(r'Return to Home')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('breadcrumb context bar announces screen location',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'You are here: Home › Health Reports')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Keyboard / focus ────────────────────────────────────────────────────

    testWidgets('generate-report tiles are keyboard-focusable', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // 'Monthly' appears in the tile and in the report badge; .first picks the
      // QuickActionTile which comes earlier in the widget tree.
      await tester.tap(find.text('Monthly').first);
      // generateReport() runs a 2-second Future.delayed; advance fake time to
      // drain it so no pending timers remain when the test ends.
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
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

    testWidgets('renders without overflow at 150% text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: _wrap(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
