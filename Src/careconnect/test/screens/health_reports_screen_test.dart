import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/health_reports_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('HealthReportsScreen', () {
    testWidgets('renders mock reports', (tester) async {
      await tester.pumpWidget(_wrap(const HealthReportsScreen()));
      expect(find.text('May 2026 Monthly Summary'), findsOneWidget);
      expect(find.text('Q1 2026 Quarterly Report'), findsOneWidget);
    });

    testWidgets('renders generate section', (tester) async {
      await tester.pumpWidget(_wrap(const HealthReportsScreen()));
      expect(find.text('Generate New Report'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Quarterly'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap(const HealthReportsScreen()));
      expect(find.text('Total Reports'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Generated'), findsOneWidget);
    });
  });
}
