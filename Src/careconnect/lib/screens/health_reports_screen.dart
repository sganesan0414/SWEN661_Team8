import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/health_report.dart';
import '../providers/health_reports_provider.dart';
import '../utils/formatting.dart';

class HealthReportsScreen extends ConsumerStatefulWidget {
  const HealthReportsScreen({super.key});

  @override
  ConsumerState<HealthReportsScreen> createState() => _HealthReportsScreenState();
}

class _HealthReportsScreenState extends ConsumerState<HealthReportsScreen> {
  final Map<String, bool> _shareCooling = {};

  Future<void> _share(String id) async {
    if (_shareCooling[id] == true) return;
    setState(() => _shareCooling[id] = true);
    HapticFeedback.mediumImpact();
    ref.read(healthReportsProvider.notifier).shareReport(id);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _shareCooling[id] = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthReportsProvider);
    final reports = state.reports;
    final now = DateTime.now();
    final thisMonth = reports.where((r) =>
        r.generatedAt.year == now.year && r.generatedAt.month == now.month).length;
    final lastGenStr = reports.isEmpty
        ? 'None'
        : '${reports.first.generatedAt.month}/${reports.first.generatedAt.day}';


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Reports'),
        leading: LabeledBackButton(
          label: 'Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: AppSizing.backButtonWidth,
      ),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Health Reports'),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: StatCard(icon: Icons.description_outlined, iconColor: AppColors.primary, value: '${reports.length}', label: 'Total Reports')),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(icon: Icons.calendar_month, iconColor: AppColors.accent, value: '$thisMonth', label: 'This Month')),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(icon: Icons.access_time, iconColor: AppColors.success, value: lastGenStr, label: 'Last Generated')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const SectionHeader(title: 'Generate New Report'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                    children: [
                      QuickActionTile(
                        icon: Icons.calendar_month_outlined,
                        iconColor: AppColors.primary,
                        label: 'Monthly',
                        onTap: () => ref.read(healthReportsProvider.notifier).generateReport(ReportType.monthly),
                      ),
                      QuickActionTile(
                        icon: Icons.bar_chart_outlined,
                        iconColor: AppColors.appointment,
                        label: 'Quarterly',
                        onTap: () => ref.read(healthReportsProvider.notifier).generateReport(ReportType.quarterly),
                      ),
                      QuickActionTile(
                        icon: Icons.tune_outlined,
                        iconColor: AppColors.warning,
                        label: 'Custom',
                        onTap: () => ref.read(healthReportsProvider.notifier).generateReport(ReportType.custom),
                      ),
                    ],
                  ),

                  AnimatedSize(
                    duration: context.motion(AppDurations.normal),
                    curve: AppCurves.standard,
                    alignment: Alignment.topCenter,
                    child: state.isGenerating
                        ? Semantics(
                            liveRegion: true,
                            label: 'Generating report, please wait',
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: AppSpacing.lg),
                                const Center(child: CircularProgressIndicator()),
                                const SizedBox(height: AppSpacing.sm),
                                Center(child: Text('Generating report…', style: AppTextStyles.bodyMedium)),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),

                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Your Reports'),
                  const SizedBox(height: 12),
                  if (reports.isEmpty)
                    const EmptyState(
                      icon: Icons.description_outlined,
                      message: 'No reports yet. Generate one above.',
                    )
                  else
                    ...reports.asMap().entries.map((entry) => EntranceSlide(
                          index: entry.key,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _ReportCard(
                              report: entry.value,
                              isShareCooling: _shareCooling[entry.value.id] == true,
                              onShare: () => _share(entry.value.id),
                            ),
                          ),
                        )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final HealthReport report;
  final bool isShareCooling;
  final VoidCallback onShare;

  const _ReportCard({
    required this.report,
    required this.isShareCooling,
    required this.onShare,
  });

  String get _typeBadge {
    return switch (report.type) {
      ReportType.monthly   => 'Monthly',
      ReportType.quarterly => 'Quarterly',
      ReportType.custom    => 'Custom',
    };
  }

  Color get _typeColor {
    return switch (report.type) {
      ReportType.monthly   => AppColors.primary,
      ReportType.quarterly => AppColors.appointment,
      ReportType.custom    => AppColors.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dt = report.generatedAt;
    final dateStr = formatNumericDate(dt);

    return Semantics(
      label: '${report.title}, $_typeBadge report, generated $dateStr',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(report.title, style: AppTextStyles.labelLarge)),
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _typeColor),
                    ),
                    child: Text(_typeBadge, style: AppTextStyles.caption.copyWith(color: _typeColor, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Generated $dateStr', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Download ${report.title}',
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showAppSnackBar(context, '${report.title} downloaded');
                      },
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Download'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: isShareCooling ? 'Sharing ${report.title}' : 'Share ${report.title}',
                    child: ElevatedButton.icon(
                      onPressed: isShareCooling ? null : onShare,
                      icon: isShareCooling
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.share_outlined, size: 18),
                      label: Text(isShareCooling ? 'Sharing…' : 'Share'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
