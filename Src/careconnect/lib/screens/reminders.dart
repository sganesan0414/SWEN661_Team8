import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/medications_provider.dart';
import '../providers/appointments_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationsProvider);
    final apptState = ref.watch(appointmentsProvider);

    final upcoming = medState.medications.where((m) => !m.taken).toList();
    final upcomingAppts = apptState.upcoming;
    final activeCount = upcoming.length + upcomingAppts.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reminders')),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Reminders'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledBackButton(
                            label: 'Dashboard',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reminders', style: AppTextStyles.displayLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$activeCount active reminders',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Add Reminder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(120, 44),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text('Medications Due', style: AppTextStyles.headlineMedium),
                          const SizedBox(height: 12),
                          if (upcoming.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text('All medications taken for today.', style: AppTextStyles.bodyMedium),
                            )
                          else
                            ...upcoming.map((med) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ReminderCard(
                                icon: Icons.medication_outlined,
                                title: med.name,
                                subtitle: med.dose,
                                time: med.times.isNotEmpty ? med.times.first : '',
                                days: med.schedule,
                                isEnabled: true,
                              ),
                            )),

                          if (upcomingAppts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Upcoming Appointments', style: AppTextStyles.headlineMedium),
                            const SizedBox(height: 12),
                            ...upcomingAppts.map((appt) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ReminderCard(
                                icon: Icons.event_outlined,
                                title: appt.doctorName,
                                subtitle: appt.specialty,
                                time: '${appt.dateTime.hour}:${appt.dateTime.minute.toString().padLeft(2, '0')}',
                                days: 'Jun ${appt.dateTime.day}',
                                isEnabled: true,
                              ),
                            )),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Global Settings',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 16),
                                _SettingRow(label: 'Sound', value: true),
                                const SizedBox(height: 12),
                                _SettingRow(label: 'Vibration', value: true),
                                const SizedBox(height: 12),
                                _SettingRow(label: 'Do Not Disturb', value: false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statistics',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 16),
                                _StatRow(label: 'Active Reminders', value: '$activeCount'),
                                const SizedBox(height: 12),
                                _StatRow(label: 'Medications Due', value: '${upcoming.length}'),
                                const SizedBox(height: 12),
                                _StatRow(label: 'Appointments', value: '${upcomingAppts.length}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Actions',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.notifications_active_outlined),
                                    label: const Text('Test All Reminders'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 44),
                                      side: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.snooze_outlined),
                                    label: const Text('Snooze All (1 hour)'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 44),
                                      side: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String days;
  final bool isEnabled;

  const _ReminderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.days,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: isEnabled ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            days,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final bool value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Switch(
          value: value,
          onChanged: (_) {},
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
