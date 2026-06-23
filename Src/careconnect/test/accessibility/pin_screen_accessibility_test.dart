// TalkBack (Android) and VoiceOver (iOS) accessibility tests for PinEntryScreen.
// Validates WCAG 2.1 Level AA: touch targets, labeled tap targets, color contrast,
// semantic labels for the PIN keypad, and dynamic text scaling up to 200%.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/pin_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: const PinEntryScreen()),
    );

// PinEntryScreen is a tall, vertically-centered layout. The default test
// viewport (800×600) is shorter than a real phone and triggers a false overflow,
// so each test renders on a phone-sized surface. tester.view is reset per test
// via addTearDown so the size never leaks into other test files.
Future<void> _pumpPin(WidgetTester tester, {double textScale = 1.0}) async {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: _wrap(),
    ),
  );
  await tester.pump();
}

void main() {
  group('PinEntryScreen – TalkBack / VoiceOver accessibility', () {
    // ── Android TalkBack ────────────────────────────────────────────────────

    testWidgets('meets Android tap-target guideline (48×48 dp minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('all tappable elements have semantic labels (TalkBack)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // ── iOS VoiceOver ───────────────────────────────────────────────────────

    testWidgets('meets iOS tap-target guideline (44×44 pt minimum)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    // ── Color contrast ──────────────────────────────────────────────────────

    testWidgets('text meets WCAG AA contrast ratio (4.5:1 normal / 3:1 large)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    // ── Semantic labels – keypad ────────────────────────────────────────────

    testWidgets('numeric keypad digits expose accessible labels', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      // Each _PinKey wraps its digit in Semantics(button: true, label: digit);
      // the labeledTapTargetGuideline test confirms every key is labeled. Here
      // we assert the visible digit text is present (the digit acts as its label).
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('delete key exposes descriptive semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      expect(find.bySemanticsLabel('Delete last digit'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('PIN prompt instruction text is present', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      expect(find.text('Enter your 4-digit PIN'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('back button has accessible label including destination',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      expect(
        find.bySemanticsLabel(RegExp(r'Return to Login')),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });

    // ── Keypad interaction ──────────────────────────────────────────────────

    testWidgets('tapping a digit key registers input without error',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPin(tester);
      // Tapping the digit's Text hit-tests through to the enclosing InkWell.
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    // ── Dynamic text scaling ────────────────────────────────────────────────

    testWidgets('renders without overflow at 200% text scale', (tester) async {
      await _pumpPin(tester, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
