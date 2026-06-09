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
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Oxygen Saturation'), findsOneWidget);
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
  });
}
