import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_metric.dart';

class HealthMetricsState {
  final List<HealthMetric> metrics;
  final bool isAddingReading;

  const HealthMetricsState({
    this.metrics = const [],
    this.isAddingReading = false,
  });

  HealthMetricsState copyWith({
    List<HealthMetric>? metrics,
    bool? isAddingReading,
  }) {
    return HealthMetricsState(
      metrics: metrics ?? this.metrics,
      isAddingReading: isAddingReading ?? this.isAddingReading,
    );
  }
}

class HealthMetricsNotifier extends StateNotifier<HealthMetricsState> {
  HealthMetricsNotifier()
      : super(HealthMetricsState(metrics: _mockMetrics));

  Future<void> addReading(String metricId, double value, {String? secondaryValue}) async {
    state = state.copyWith(isAddingReading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    final reading = VitalReading(
      timestamp: DateTime.now(),
      value: value,
      secondaryValue: secondaryValue,
    );
    state = state.copyWith(
      isAddingReading: false,
      metrics: state.metrics.map((m) {
        if (m.id != metricId) return m;
        return m.copyWith(history: [...m.history, reading]);
      }).toList(),
    );
  }
}

final _now = DateTime.now();

final _mockMetrics = [
  HealthMetric(
    id: 'bp',
    name: 'Blood Pressure',
    unit: 'mmHg',
    displayValue: '120/80',
    status: MetricStatus.normal,
    history: [
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 6), value: 118, secondaryValue: '76'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 5), value: 122, secondaryValue: '80'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 4), value: 119, secondaryValue: '78'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 3), value: 124, secondaryValue: '82'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 2), value: 121, secondaryValue: '79'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 1), value: 120, secondaryValue: '80'),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day),     value: 120, secondaryValue: '80'),
    ],
  ),
  HealthMetric(
    id: 'hr',
    name: 'Heart Rate',
    unit: 'bpm',
    displayValue: '72',
    status: MetricStatus.normal,
    history: [
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 6), value: 74),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 5), value: 71),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 4), value: 73),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 3), value: 70),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 2), value: 69),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 1), value: 71),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day),     value: 72),
    ],
  ),
  HealthMetric(
    id: 'temp',
    name: 'Temperature',
    unit: '°F',
    displayValue: '98.6',
    status: MetricStatus.normal,
    history: [
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 6), value: 98.4),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 5), value: 98.7),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 4), value: 98.5),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 3), value: 98.6),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 2), value: 98.8),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 1), value: 98.5),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day),     value: 98.6),
    ],
  ),
  HealthMetric(
    id: 'o2',
    name: 'Oxygen Saturation',
    unit: '%',
    displayValue: '98',
    status: MetricStatus.normal,
    history: [
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 6), value: 97),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 5), value: 98),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 4), value: 99),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 3), value: 98),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 2), value: 97),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day - 1), value: 98),
      VitalReading(timestamp: DateTime(_now.year, _now.month, _now.day),     value: 98),
    ],
  ),
];

final healthMetricsProvider =
    StateNotifierProvider<HealthMetricsNotifier, HealthMetricsState>((ref) {
  return HealthMetricsNotifier();
});
