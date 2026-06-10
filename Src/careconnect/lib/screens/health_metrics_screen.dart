import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/health_metric.dart';
import '../providers/health_metrics_provider.dart';

class HealthMetricsScreen extends ConsumerStatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  ConsumerState<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends ConsumerState<HealthMetricsScreen> {
  String? _selectedMetricId;
  final _valueController = TextEditingController();
  bool _saveCooling = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _saveReading() async {
    if (_saveCooling || _selectedMetricId == null || _valueController.text.isEmpty) return;
    final value = double.tryParse(_valueController.text);
    if (value == null) return;

    setState(() => _saveCooling = true);
    HapticFeedback.mediumImpact();

    await ref.read(healthMetricsProvider.notifier).addReading(_selectedMetricId!, value);

    _valueController.clear();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _saveCooling = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthMetricsProvider);
    final metrics = state.metrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Metrics'),
        leading: LabeledBackButton(
          label: 'Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 160,
      ),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Health Metrics'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: metrics.map((m) => _VitalCard(metric: m)).toList(),
                  ),
                  const SizedBox(height: 24),

                  Text('Add Reading', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedMetricId,
                    hint: Text('Select metric', style: AppTextStyles.bodyMedium),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.monitor_heart_outlined),
                    ),
                    items: metrics.map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedMetricId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'Enter reading value',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Save reading',
                    child: ElevatedButton.icon(
                      onPressed: _saveCooling ? null : _saveReading,
                      icon: state.isAddingReading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_outlined),
                      label: Text(state.isAddingReading ? 'Saving…' : 'Save Reading'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Recent Readings', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 12),
                  ...metrics.expand((m) => m.history.reversed.take(3).map((r) => _ReadingRow(metric: m, reading: r))),
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

class _VitalCard extends StatelessWidget {
  final HealthMetric metric;
  const _VitalCard({required this.metric});

  Color get _statusColor {
    return switch (metric.status) {
      MetricStatus.normal   => AppColors.success,
      MetricStatus.warning  => AppColors.warning,
      MetricStatus.critical => Colors.red,
    };
  }

  String get _statusLabel {
    return switch (metric.status) {
      MetricStatus.normal   => 'Normal',
      MetricStatus.warning  => 'Warning',
      MetricStatus.critical => 'Critical',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${metric.name}: ${metric.displayValue} ${metric.unit}, status: $_statusLabel',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(metric.name, style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor),
                  ),
                  child: Text(_statusLabel, style: AppTextStyles.caption.copyWith(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(metric.displayValue, style: AppTextStyles.headlineMedium),
            Text(metric.unit, style: AppTextStyles.caption),
            const SizedBox(height: 8),
            _Sparkline(history: metric.history),
          ],
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<VitalReading> history;
  const _Sparkline({required this.history});

  @override
  Widget build(BuildContext context) {
    final last7 = history.length > 7 ? history.sublist(history.length - 7) : history;
    if (last7.isEmpty) return const SizedBox(height: 8);

    final values = last7.map((r) => r.value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: last7.map((r) {
        final normalized = range == 0 ? 0.5 : (r.value - minV) / range;
        final height = 4.0 + normalized * 12;
        return Container(
          width: 6,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5 + normalized * 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final HealthMetric metric;
  final VitalReading reading;
  const _ReadingRow({required this.metric, required this.reading});

  @override
  Widget build(BuildContext context) {
    final dt = reading.timestamp;
    final dateStr = '${dt.month}/${dt.day}/${dt.year}';
    final valueStr = reading.secondaryValue != null
        ? '${reading.value.toStringAsFixed(0)}/${reading.secondaryValue}'
        : reading.value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(metric.name, style: AppTextStyles.labelMedium)),
            Text('$valueStr ${metric.unit}', style: AppTextStyles.labelLarge),
            const SizedBox(width: 12),
            Text(dateStr, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
