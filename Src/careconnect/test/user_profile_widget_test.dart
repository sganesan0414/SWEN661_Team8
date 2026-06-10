import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/user_profile.dart';

Widget _wrap() =>
    const ProviderScope(child: MaterialApp(home: UserProfileScreen()));

void main() {
  group('UserProfileScreen Widget Tests', () {
    testWidgets('Editing a field marks profile as changed', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Profile'), findsAtLeastNWidgets(1));

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Jane Doe');
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Save Changes'), findsOneWidget);
    });

    testWidgets('Cancel button resets profile to provider values', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Modified Name');
      await tester.pumpAndSettle();

      final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
      expect(cancelButton, findsOneWidget);
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, isNot('Modified Name'));
    });

    testWidgets('Password change dialog validates password requirements', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'Change Password'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Change Password'));
      await tester.pumpAndSettle();

      final allFields = find.byType(TextField);
      expect(allFields, findsAtLeastNWidgets(3));

      // The last 3 TextFields belong to the dialog
      final fieldCount = allFields.evaluate().length;
      final currentField = allFields.at(fieldCount - 3);
      final newField    = allFields.at(fieldCount - 2);
      final confirmField = allFields.at(fieldCount - 1);

      await tester.enterText(currentField, 'oldpassword');
      await tester.enterText(newField, 'password123');
      await tester.enterText(confirmField, 'password456');
      await tester.pump();

      final dialogButtons = find.widgetWithText(ElevatedButton, 'Change Password');
      await tester.tap(dialogButtons.last);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
