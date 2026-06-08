import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/medication.dart';
import '../providers/medications_provider.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  final Map<String, bool> _cooling = {};

  Future<void> _markTaken(String id, String name) async {
    if (_cooling[id] == true) return;
    HapticFeedback.mediumImpact();

    setState(() => _cooling[id] = true);
    ref.read(medicationsProvider.notifier).markTaken(id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name marked as taken'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undo(id),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _cooling[id] = false);
  }

  void _undo(String id) {
    HapticFeedback.lightImpact();
    ref.read(medicationsProvider.notifier).undoTaken(id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationsProvider);
    final filtered = state.filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Medications'),
        leading: LabeledBackButton(
          label: 'Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 100,
        actions: [
          Semantics(
            button: true,
            label: 'Add medication',
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26),
              tooltip: 'Add Medication',
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ContextBar(
            screenLabel: 'Home › My Medications',
            onHome: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Search medications',
                    child: TextField(
                      onChanged: (v) =>
                          ref.read(medicationsProvider.notifier).setSearchQuery(v),
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search medications…',
                        prefixIcon: const Icon(Icons.search_outlined),
                        suffixIcon: state.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => ref
                                    .read(medicationsProvider.notifier)
                                    .setSearchQuery(''),
                                tooltip: 'Clear search',
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: StatCard(icon: Icons.medication, iconColor: AppColors.primary, value: '${state.medications.length}', label: 'Total Medications')),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.check_circle_outline, iconColor: AppColors.success, value: '${state.takenCount}', label: 'Taken Today')),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.schedule, iconColor: AppColors.warning, value: '${state.upcomingCount}', label: 'Upcoming')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'No medications match your search.',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...filtered.map((med) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _MedicationCard(
                            med: med,
                            isCooling: _cooling[med.id] == true,
                            onMarkTaken: () => _markTaken(med.id, med.name),
                          ),
                        )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CareConnectBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication med;
  final bool isCooling;
  final VoidCallback onMarkTaken;

  const _MedicationCard({
    required this.med,
    required this.isCooling,
    required this.onMarkTaken,
  });

  Color get _borderColor => med.taken ? AppColors.success : AppColors.primary;
  Color get _bgColor => med.taken ? AppColors.successBg : AppColors.infoBg;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${med.name} ${med.dose}. Schedule: ${med.schedule}. Times: ${med.times.join(", ")}. ${med.taken ? "Already taken today." : "Not yet taken."}',
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 2),
                      Text(med.dose, style: AppTextStyles.bodyMedium.copyWith(color: _borderColor)),
                    ],
                  ),
                ),
                if (med.taken)
                  Semantics(
                    label: 'Taken',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('Taken', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(med.times.join(', '), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.repeat, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(med.schedule, style: AppTextStyles.bodyMedium),
            ]),
            const SizedBox(height: 14),
            if (!med.taken)
              Semantics(
                button: true,
                label: 'Mark ${med.name} as taken',
                child: ElevatedButton.icon(
                  onPressed: isCooling ? null : onMarkTaken,
                  icon: isCooling
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(isCooling ? 'Marking…' : 'Mark as Taken'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: AppTextStyles.labelLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle, color: AppColors.success),
                label: const Text('Taken', style: TextStyle(color: AppColors.success)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.success),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
