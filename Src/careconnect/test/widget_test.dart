import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen smoke test - renders sign-in button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('LoginScreen shows loading indicator on sign-in tap', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.theme, home: const LoginScreen()),
      ),
    );
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    // Drain the Future.delayed timers from signIn()/_handleSignIn().
    await tester.pump(const Duration(milliseconds: 4000));
  });
}
