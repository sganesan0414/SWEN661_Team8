import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/medications_provider.dart';

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Pharmacies')),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Pharmacy'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Current Prescriptions', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 12),
                ...medState.medications.map((med) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${med.name} ${med.dose}', style: AppTextStyles.titleLarge),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.local_pharmacy_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('CVS Pharmacy', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                        ]),
                        const SizedBox(height: 8),
                        Text(med.schedule, style: AppTextStyles.bodyMedium),
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
