enum ReportType { monthly, quarterly, custom }

class HealthReport {
  final String id;
  final String title;
  final DateTime generatedAt;
  final ReportType type;

  const HealthReport({
    required this.id,
    required this.title,
    required this.generatedAt,
    required this.type,
  });
}
