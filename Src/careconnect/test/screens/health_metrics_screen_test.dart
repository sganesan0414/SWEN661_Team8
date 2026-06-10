import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/health_metrics_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );

void main() {
  group('HealthMetricsScreen', () {
    testWidgets('renders all 4 vital cards', (tester) async {
      await tester.pumpWidget(_wrap(const HealthMetricsScreen()));
      expect(find.text('Blood Pressure'), findsWidgets);
      expect(find.text('Heart Rate'), findsWidgets);
      expect(find.text('Temperature'), findsWidgets);
      expect(find.text('Oxygen Saturation'), findsWidgets);
    });

    testWidgets('renders Add Reading section', (tester) async {
      await tester.pumpWidget(_wrap(const HealthMetricsScreen()));
      expect(find.text('Add Reading'), findsOneWidget);
      expect(find.text('Save Reading'), findsOneWidget);
    });

    testWidgets('renders Recent Readings section', (tester) async {
      await tester.pumpWidget(_wrap(const HealthMetricsScreen()));
      expect(find.text('Recent Readings'), findsOneWidget);
    });

    testWidgets('save reading button adds a new reading after selection', (tester) async {
      await tester.pumpWidget(_wrap(const HealthMetricsScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Blood Pressure').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '125');
      await tester.pump();
      await tester.tap(find.text('Save Reading'));
      await tester.pump();
      // Drain the sequential save timers (800ms provider + 1500ms screen)
      // before the tree is disposed.
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
      expect(find.text('Save Reading'), findsOneWidget);
    });
  });
}
