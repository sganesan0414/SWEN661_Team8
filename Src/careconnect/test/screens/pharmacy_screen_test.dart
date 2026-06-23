import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/pharmacy.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('PharmacyScreen', () {
    testWidgets('renders pharmacy overview and prescription cards', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      expect(find.text('My Pharmacies'), findsWidgets);
      expect(find.text('6 active prescriptions'), findsOneWidget);
      // Prescription cards render name and dose together, e.g. "Lisinopril 10 mg".
      expect(find.textContaining('Lisinopril'), findsWidgets);
      expect(find.textContaining('Metformin'), findsWidgets);
      expect(find.text('CVS Pharmacy'), findsWidgets);
      expect(find.text('Walgreens'), findsOneWidget);
      expect(find.text('Rite Aid'), findsOneWidget);
    });

    testWidgets('includes a dashboard back button label', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      // LabeledBackButton renders the destination as "Return to Dashboard".
      expect(find.textContaining('Dashboard'), findsWidgets);
      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('tapping View Details opens the prescription detail sheet', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      final viewDetails = find.widgetWithText(ElevatedButton, 'View Details').first;
      await tester.ensureVisible(viewDetails);
      await tester.tap(viewDetails);
      await tester.pumpAndSettle();

      expect(find.text('Cost per fill'), findsOneWidget);
      expect(find.text('Pharmacy'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Close'), findsOneWidget);
    });

    testWidgets('the X icon closes the prescription detail sheet', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      final viewDetails = find.widgetWithText(ElevatedButton, 'View Details').first;
      await tester.ensureVisible(viewDetails);
      await tester.tap(viewDetails);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Cost per fill'), findsNothing);
    });

    testWidgets('the Close button closes the prescription detail sheet', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      final viewDetails = find.widgetWithText(ElevatedButton, 'View Details').first;
      await tester.ensureVisible(viewDetails);
      await tester.tap(viewDetails);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Close'));
      await tester.pumpAndSettle();
      expect(find.text('Cost per fill'), findsNothing);
    });

    testWidgets('tapping Get Directions on a prescription shows a snackbar', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      final getDirections =
          find.widgetWithText(OutlinedButton, 'Get Directions').first;
      await tester.ensureVisible(getDirections);
      await tester.tap(getDirections);
      await tester.pump();
      expect(find.textContaining('Directions to CVS Pharmacy'), findsOneWidget);
    });

    testWidgets('tapping Directions on a nearby pharmacy card shows a snackbar', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      final directions = find.widgetWithText(ElevatedButton, 'Directions').first;
      await tester.ensureVisible(directions);
      await tester.tap(directions);
      await tester.pump();
      expect(find.textContaining('Directions to'), findsWidgets);
    });

    testWidgets('renders the wide two-column layout on large screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Prescription Status'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);
    });
  });
}
