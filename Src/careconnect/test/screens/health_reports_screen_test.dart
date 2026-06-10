import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/components/widgets.dart';
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
      expect(find.widgetWithText(QuickActionTile, 'Monthly'), findsOneWidget);
      expect(find.widgetWithText(QuickActionTile, 'Quarterly'), findsOneWidget);
      expect(find.widgetWithText(QuickActionTile, 'Custom'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap(const HealthReportsScreen()));
      expect(find.text('Total Reports'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Generated'), findsOneWidget);
    });

    testWidgets('generate buttons start report generation flow', (tester) async {
      await tester.pumpWidget(_wrap(const HealthReportsScreen()));
      await tester.tap(find.widgetWithText(QuickActionTile, 'Monthly'));
      await tester.pump();
      expect(find.text('Generating report…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('Monthly Summary'), findsWidgets);
    });
  });
}
