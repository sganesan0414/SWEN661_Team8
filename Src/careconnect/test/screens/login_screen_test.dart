import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'careconnect_accounts': jsonEncode({
        'jane@example.com': {
          'name': 'Jane Doe',
          'phone': '555',
          'password': 'oldpass12',
        },
      }),
    });
  });

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

    testWidgets('tapping Use PIN instead navigates to the PIN screen', (tester) async {
      tester.view.physicalSize = const Size(1400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const LoginScreen()));
      final pinButton = find.text('Use PIN instead');
      await tester.ensureVisible(pinButton);
      await tester.tap(pinButton);
      await tester.pumpAndSettle();
      expect(find.text('Enter PIN'), findsOneWidget);
    });

    testWidgets('sign-in with wrong credentials shows an error snackbar', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.enterText(
        find.byType(TextFormField).first,
        'jane@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'wrong-password',
      );
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Invalid email or password'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1500));
    });
  });

  group('LoginScreen Forgot Password dialog', () {
    Finder inDialog(Finder matching) => find.descendant(
          of: find.byType(AlertDialog),
          matching: matching,
        );

    Future<void> openDialog(WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      final forgotButton = find.text('Forgot Password?');
      await tester.ensureVisible(forgotButton);
      await tester.tap(forgotButton);
      await tester.pumpAndSettle();
    }

    testWidgets('opens with email/password fields and a Cancel action', (tester) async {
      await openDialog(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Enter your account email and a new password.'),
        findsOneWidget,
      );
      expect(inDialog(find.text('New password')), findsOneWidget);
      expect(inDialog(find.text('Confirm password')), findsOneWidget);

      await tester.tap(inDialog(find.text('Cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('password visibility toggle works inside the dialog', (tester) async {
      await openDialog(tester);

      expect(inDialog(find.byIcon(Icons.visibility_outlined)), findsOneWidget);
      await tester.tap(inDialog(find.byIcon(Icons.visibility_outlined)));
      await tester.pump();
      expect(inDialog(find.byIcon(Icons.visibility_off_outlined)), findsOneWidget);
    });

    testWidgets('mismatched passwords show a validation error', (tester) async {
      await openDialog(tester);

      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'New password')),
        'newpassword1',
      );
      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'Confirm password')),
        'newpassword2',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('unknown email shows a not-found error', (tester) async {
      await openDialog(tester);

      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'Email')),
        'nobody@example.com',
      );
      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'New password')),
        'newpassword1',
      );
      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'Confirm password')),
        'newpassword1',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('No account found with this email'), findsOneWidget);
    });

    testWidgets('valid reset closes the dialog and shows a confirmation', (tester) async {
      await openDialog(tester);

      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'Email')),
        'jane@example.com',
      );
      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'New password')),
        'newpassword1',
      );
      await tester.enterText(
        inDialog(find.widgetWithText(TextField, 'Confirm password')),
        'newpassword1',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text('Password reset. Please sign in with your new password.'),
        findsOneWidget,
      );
    });
  });
}
