enum MetricStatus { normal, warning, critical }

class VitalReading {
  final DateTime timestamp;
  final double value;
  final String? secondaryValue;

  const VitalReading({
    required this.timestamp,
    required this.value,
    this.secondaryValue,
  });
}

class HealthMetric {
  final String id;
  final String name;
  final String unit;
  final String displayValue;
  final MetricStatus status;
  final List<VitalReading> history;

  const HealthMetric({
    required this.id,
    required this.name,
    required this.unit,
    required this.displayValue,
    required this.status,
    this.history = const [],
  });

  HealthMetric copyWith({
    String? displayValue,
    MetricStatus? status,
    List<VitalReading>? history,
  }) {
    return HealthMetric(
      id: id,
      name: name,
      unit: unit,
      displayValue: displayValue ?? this.displayValue,
      status: status ?? this.status,
      history: history ?? this.history,
    );
  }
}
