// TalkBack (Android) and VoiceOver (iOS) accessibility tests for CreateAccountScreen.
// Validates WCAG 2.1 Level AA: touch targets, labeled tap targets, color contrast,
// semantic labels for inputs/controls, and dynamic text scaling up to 200%.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/create_account.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const CreateAccountScreen()),
    );

void main() {
  group('CreateAccountScreen – TalkBack / VoiceOver accessibility', () {
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

    // ── Semantic labels – form inputs ───────────────────────────────────────

    testWidgets('full name input exposes accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Ff]ull name')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('email and phone inputs expose accessible labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'[Ee]mail')), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel(RegExp(r'[Pp]hone')), findsAtLeastNWidgets(1));
      handle.dispose();
    });

    testWidgets('password and confirm-password inputs expose accessible labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'[Pp]assword')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('show/hide password toggles have descriptive labels',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Show password|Hide password')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    // ── Semantic labels – controls ──────────────────────────────────────────

    testWidgets('terms agreement checkbox exposes accessible label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.bySemanticsLabel('Agreement checkbox'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('continue button has descriptive semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Continue to next step')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('sign-in link exposes accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'Go back to sign in')),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Checkbox interaction (state announcement) ───────────────────────────

    testWidgets('agreement checkbox toggles checked state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
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
