import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/health_metric.dart';

void main() {
  group('HealthMetric', () {
    final base = HealthMetric(
      id: 'hr',
      name: 'Heart Rate',
      unit: 'bpm',
      displayValue: '72',
      status: MetricStatus.normal,
    );

    test('copyWith overrides history when provided', () {
      final reading = VitalReading(timestamp: DateTime(2026, 1, 1), value: 80);
      final updated = base.copyWith(
        history: [reading],
        displayValue: '80',
        status: MetricStatus.warning,
      );
      expect(updated.history, [reading]);
      expect(updated.displayValue, '80');
      expect(updated.status, MetricStatus.warning);
    });

    test('copyWith keeps history when not provided', () {
      final updated = base.copyWith();
      expect(updated.history, base.history);
    });
  });
}
