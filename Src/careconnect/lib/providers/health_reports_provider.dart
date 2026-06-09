import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_report.dart';

class HealthReportsState {
  final List<HealthReport> reports;
  final bool isGenerating;

  const HealthReportsState({
    this.reports = const [],
    this.isGenerating = false,
  });

  HealthReportsState copyWith({
    List<HealthReport>? reports,
    bool? isGenerating,
  }) {
    return HealthReportsState(
      reports: reports ?? this.reports,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class HealthReportsNotifier extends Notifier<HealthReportsState> {
  @override
  HealthReportsState build() => HealthReportsState(reports: _mockReports);

  Future<void> generateReport(ReportType type) async {
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    final title = switch (type) {
      ReportType.monthly   => 'Monthly Summary - ${_monthName(now.month)} ${now.year}',
      ReportType.quarterly => 'Quarterly Report - Q${((now.month - 1) ~/ 3) + 1} ${now.year}',
      ReportType.custom    => 'Custom Report - ${now.month}/${now.day}/${now.year}',
    };
    final report = HealthReport(
      id: 'r${now.millisecondsSinceEpoch}',
      title: title,
      generatedAt: now,
      type: type,
    );
    state = state.copyWith(
      isGenerating: false,
      reports: [report, ...state.reports],
    );
  }

  void shareReport(String id) {
    // Stub - real implementation would invoke platform share sheet
  }
}

String _monthName(int month) {
  const names = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return names[month];
}

final _mockReports = [
  HealthReport(
    id: 'r1',
    title: 'May 2026 Monthly Summary',
    generatedAt: DateTime(2026, 5, 31),
    type: ReportType.monthly,
  ),
  HealthReport(
    id: 'r2',
    title: 'Q1 2026 Quarterly Report',
    generatedAt: DateTime(2026, 3, 31),
    type: ReportType.quarterly,
  ),
];

final healthReportsProvider =
    NotifierProvider<HealthReportsNotifier, HealthReportsState>(
        HealthReportsNotifier.new);
