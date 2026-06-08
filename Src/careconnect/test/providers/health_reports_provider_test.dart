import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/providers/health_reports_provider.dart';
import 'package:careconnect/models/health_report.dart';

void main() {
  group('HealthReportsNotifier', () {
    test('initial state has 2 mock reports', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(healthReportsProvider).reports.length, 2);
    });

    test('generateReport adds a report of the correct type', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(healthReportsProvider.notifier).generateReport(ReportType.monthly);
      final reports = container.read(healthReportsProvider).reports;
      expect(reports.length, 3);
      expect(reports.first.type, ReportType.monthly);
    });

    test('generateReport quarterly adds quarterly report', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(healthReportsProvider.notifier).generateReport(ReportType.quarterly);
      expect(container.read(healthReportsProvider).reports.first.type, ReportType.quarterly);
    });

    test('isGenerating is false after generation completes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(healthReportsProvider.notifier).generateReport(ReportType.custom);
      expect(container.read(healthReportsProvider).isGenerating, isFalse);
    });

    test('generated report has a date', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final before = DateTime.now();
      await container.read(healthReportsProvider.notifier).generateReport(ReportType.monthly);
      final report = container.read(healthReportsProvider).reports.first;
      expect(report.generatedAt.isAfter(before) || report.generatedAt.isAtSameMomentAs(before), isTrue);
    });
  });
}
