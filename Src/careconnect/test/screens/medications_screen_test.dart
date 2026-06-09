import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/medications_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('MedicationsScreen', () {
    testWidgets('renders medication list', (tester) async {
      await tester.pumpWidget(_wrap(const MedicationsScreen()));
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap(const MedicationsScreen()));
      expect(find.text('Total Medications'), findsOneWidget);
      expect(find.text('Taken Today'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('search filters medications', (tester) async {
      await tester.pumpWidget(_wrap(const MedicationsScreen()));
      await tester.enterText(find.byType(TextField), 'Aspirin');
      await tester.pump();
      expect(find.text('Aspirin'), findsOneWidget);
      expect(find.text('Lisinopril'), findsNothing);
    });

    testWidgets('mark as taken button shows loading state', (tester) async {
      await tester.pumpWidget(_wrap(const MedicationsScreen()));
      final markTakenBtn = find.text('Mark as Taken').first;
      await tester.tap(markTakenBtn);
      await tester.pump();
      expect(find.text('Marking…'), findsOneWidget);
    });
  });
}
