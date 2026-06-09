import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('LoginScreen', () {
    testWidgets('renders key elements', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Fingerprint'), findsOneWidget);
      expect(find.text('Face ID'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('sign-in button shows loading state', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Signing in…'), findsOneWidget);
    });
  });
}
