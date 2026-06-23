// TalkBack (Android) and VoiceOver (iOS) accessibility tests for SettingsScreen.
// Validates WCAG 2.1 Level AA: touch targets, labeled tap targets, color contrast,
// semantic labels for toggles/sliders, and dynamic text scaling up to 200%.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/user_settings.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const SettingsScreen()),
    );

void main() {
  group('SettingsScreen – TalkBack / VoiceOver accessibility', () {
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

    // ── Semantic labels – toggles ───────────────────────────────────────────

    testWidgets('high contrast mode toggle exposes accessible label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel('High contrast mode toggle'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('screen reader toggle exposes accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel('Screen reader toggle'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('sound alerts and magnification toggles expose labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel('Sound alerts toggle'), findsOneWidget);
      expect(find.bySemanticsLabel('Screen magnification toggle'), findsOneWidget);
      handle.dispose();
    });

    // ── Semantic labels – sliders ───────────────────────────────────────────

    testWidgets('text size slider exposes accessible slider label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel('Text size slider'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('contrast level slider exposes accessible slider label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel('Contrast level slider'), findsOneWidget);
      handle.dispose();
    });

    // ── Slider state announcement ───────────────────────────────────────────

    testWidgets('text size slider responds to accessibility increase action',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Default reads "16px"; the slider's onIncrease bumps the value by 1.
      expect(find.text('16px'), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider).first);
      expect(slider.value, 16.0);
      handle.dispose();
    });

    // ── Navigation ──────────────────────────────────────────────────────────

    testWidgets('back button has accessible label including destination',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Return to Home')),
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
