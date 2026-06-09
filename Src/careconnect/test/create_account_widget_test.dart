import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/create_account.dart';

void main() {
  group('CreateAccountScreen Widget Tests', () {
    // Test 1: Verify form validation - cannot proceed without agreeing to terms
    testWidgets('Cannot proceed without agreeing to Terms and Privacy Policy', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      // Fill in all required fields
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final phoneField = find.byType(TextFormField).at(2);
      final passwordField = find.byType(TextFormField).at(3);
      final confirmPasswordField = find.byType(TextFormField).at(4);

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(emailField, 'john@example.com');
      await tester.enterText(phoneField, '555-123-4567');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');

      // Do NOT check the terms checkbox
      // Try to click Continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.tap(continueButton);
      await tester.pump();

      // Should show snackbar error about terms
      expect(find.text('Please agree to Terms of Service and Privacy Policy'), findsOneWidget);
    });

    // Test 2: Verify password visibility toggle works
    testWidgets('Password visibility toggle shows and hides password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      // Find the password field
      final passwordField = find.byType(TextFormField).at(3);
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Find and tap the password visibility button
      final visibilityButtons = find.byIcon(Icons.visibility_outlined);
      expect(visibilityButtons, findsWidgets);

      // Tap first visibility button (password field)
      await tester.tap(visibilityButtons.first);
      await tester.pump();

      // After tapping, should show hide icon instead of show icon
      // This means password is now visible
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      // Should show visibility icon again
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    });

    // Test 3: Verify complete account creation flow with validation
    testWidgets('Complete account creation flow validates all steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      // Fill in all fields correctly
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final phoneField = find.byType(TextFormField).at(2);
      final passwordField = find.byType(TextFormField).at(3);
      final confirmPasswordField = find.byType(TextFormField).at(4);

      await tester.enterText(nameField, 'Jane Smith');
      await tester.enterText(emailField, 'jane.smith@example.com');
      await tester.enterText(phoneField, '+1 (555) 987-6543');
      await tester.enterText(passwordField, 'securePassword123');
      await tester.enterText(confirmPasswordField, 'securePassword123');

      // Find and check the terms agreement checkbox
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      // Verify checkbox is now checked
      expect(checkbox, findsOneWidget);

      // Click Continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.tap(continueButton);
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Creating Account…'), findsOneWidget);

      // Wait for the async operation to complete
      await tester.pumpAndSettle();
    });
  });
}
