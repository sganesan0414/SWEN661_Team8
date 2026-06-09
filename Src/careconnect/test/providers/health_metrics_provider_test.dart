import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/providers/health_metrics_provider.dart';

void main() {
  group('HealthMetricsNotifier', () {
    test('initial state has 4 metrics', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(healthMetricsProvider).metrics.length, 4);
    });

    test('addReading appends to metric history', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final initialHistory = container.read(healthMetricsProvider).metrics
          .firstWhere((m) => m.id == 'hr').history.length;
      await container.read(healthMetricsProvider.notifier).addReading('hr', 75.0);
      final newHistory = container.read(healthMetricsProvider).metrics
          .firstWhere((m) => m.id == 'hr').history.length;
      expect(newHistory, initialHistory + 1);
    });

    test('isAddingReading is false after add completes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(healthMetricsProvider.notifier).addReading('hr', 75.0);
      expect(container.read(healthMetricsProvider).isAddingReading, isFalse);
    });
  });
}
