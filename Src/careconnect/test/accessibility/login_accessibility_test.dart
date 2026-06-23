// TalkBack (Android) and VoiceOver (iOS) accessibility tests for LoginScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const LoginScreen()),
    );

void main() {
  group('LoginScreen – TalkBack / VoiceOver accessibility', () {
    // ── Android TalkBack ────────────────────────────────────────────────────

    testWidgets('meets Android tap-target guideline (48×48 dp minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all tappable elements have semantic labels (TalkBack)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // ── iOS VoiceOver ───────────────────────────────────────────────────────

    testWidgets('meets iOS tap-target guideline (44×44 pt minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    // ── Color contrast ──────────────────────────────────────────────────────

    testWidgets('text meets WCAG AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic labels ─────────────────────────────────────────────────────

    testWidgets('email field has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel(RegExp(r'[Ee]mail')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('password field has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel(RegExp(r'[Pp]assword')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('show/hide password toggle has descriptive label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel(RegExp(r'Show password|Hide password')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('sign-in button has descriptive semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel(RegExp(r'[Ss]ign in')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    testWidgets('fingerprint biometric button has semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel('Sign in with Fingerprint'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('Face ID biometric button has semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      expect(
        find.bySemanticsLabel('Sign in with Face ID'),
        findsOneWidget,
      );
      handle.dispose();
    });

    // ── Keyboard / focus traversal ──────────────────────────────────────────

    testWidgets('email field is keyboard-focusable', (tester) async {
      await tester.pumpWidget(_wrap());
      final emailField = find.byType(TextFormField).first;
      await tester.tap(emailField);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNotNull,
      );
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
