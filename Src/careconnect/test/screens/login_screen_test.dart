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
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);
      await tester.pump();
      expect(find.text('Signing in…'), findsOneWidget);
      // Drain Future.delayed timers in signIn() and _handleSignIn() to avoid
      // "pending timer" assertion from the test framework teardown.
      await tester.pump(const Duration(milliseconds: 4000));
    });

    testWidgets('tapping create account navigates to create account screen', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      final createAccount = find.text('Create Account');
      await tester.ensureVisible(createAccount);
      await tester.tap(createAccount);
      await tester.pumpAndSettle();
      expect(find.text('Create Your Account'), findsOneWidget);
    });
  });
}
