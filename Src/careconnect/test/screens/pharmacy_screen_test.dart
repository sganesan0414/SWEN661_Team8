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
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('CVS Pharmacy'), findsWidgets);
      expect(find.text('Walgreens'), findsOneWidget);
      expect(find.text('Rite Aid'), findsOneWidget);
    });

    testWidgets('includes a dashboard back button label', (tester) async {
      await tester.pumpWidget(_wrap(const PharmacyScreen()));
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
