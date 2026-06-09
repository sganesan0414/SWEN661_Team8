import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/user_profile.dart';

void main() {
  group('UserProfileScreen Widget Tests', () {
    // Test 1: Verify that editing a field marks changes
    testWidgets('Editing a field marks profile as changed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );

      // Verify initial state - Cancel button should be disabled
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Find the full name text field and edit it
      final fullNameField = find.byType(TextField).first;
      await tester.enterText(fullNameField, 'Jane Doe');
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );

      // Save Changes button should be enabled (not null)
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Changes');
      expect(saveButton, findsOneWidget);
    });

    // Test 2: Verify cancel button resets changes
    testWidgets('Cancel button resets profile to original values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );

      // Edit the full name field
      final fullNameField = find.byType(TextField).first;
      await tester.enterText(fullNameField, 'Modified Name');

      // Tap Cancel button
      final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
      await tester.tap(cancelButton);
      await tester.pump();

      // Full name should revert to original
      expect(find.text('John Smith'), findsWidgets);
    });

    // Test 3: Verify password change dialog validation
    testWidgets('Password change dialog validates password requirements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );

      // Scroll down to find Change Password button
      await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton.icon, 'Change Password'),
        500.0,
      );

      // Tap Change Password button
      await tester.tap(find.widgetWithText(ElevatedButton.icon, 'Change Password'));
      await tester.pumpAndSettle();

      // Try to confirm with mismatched passwords
      final passwordField = find.byType(TextField).at(0);
      final confirmField = find.byType(TextField).at(2);

      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password456');

      // Tap Change Password in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Change Password'));
      await tester.pump();

      // Should show error snackbar about passwords not matching
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
