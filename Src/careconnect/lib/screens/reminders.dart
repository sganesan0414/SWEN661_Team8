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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reminders')),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Reminders'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Medications Due', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  Text('All medications taken for today.', style: AppTextStyles.bodyMedium)
                else
                  ...upcoming.map((med) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.name, style: AppTextStyles.labelLarge),
                                Text('${med.dose} · ${med.times.join(', ')}', style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                const SizedBox(height: 24),
                Text('Upcoming Appointments', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 12),
                if (upcomingAppts.isEmpty)
                  Text('No upcoming appointments.', style: AppTextStyles.bodyMedium)
                else
                  ...upcomingAppts.map((appt) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appt.doctorName, style: AppTextStyles.labelLarge),
                                Text(appt.specialty, style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
