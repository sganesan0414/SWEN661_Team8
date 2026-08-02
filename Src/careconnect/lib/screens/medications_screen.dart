import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
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
    showAppSnackBar(
      context,
      '$name marked as taken',
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: 'Undo', onPressed: () => _undo(id)),
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
        // Was 100, which clipped the "Return to Home" label this button
        // renders. Every screen now reserves the same shared width.
        leadingWidth: AppSizing.backButtonWidth,
        actions: [
          Semantics(
            button: true,
            label: 'Add medication',
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26),
              tooltip: 'Add Medication',
              onPressed: () => showComingSoon(context, 'Adding a medication'),
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
              padding: AppSpacing.screen,
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
                  const SizedBox(height: AppSpacing.xl),
                  // IntrinsicHeight matches every other stat row in the app;
                  // without it these three cards took differing heights
                  // whenever one label wrapped.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: StatCard(icon: Icons.medication, iconColor: AppColors.primary, value: '${state.medications.length}', label: 'Total Medications')),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: StatCard(icon: Icons.check_circle_outline, iconColor: AppColors.success, value: '${state.takenCount}', label: 'Taken Today')),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: StatCard(icon: Icons.schedule, iconColor: AppColors.warning, value: '${state.upcomingCount}', label: 'Upcoming')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (filtered.isEmpty)
                    const EmptyState(
                      icon: Icons.search_off_outlined,
                      message: 'No medications match your search.',
                    )
                  else
                    ...filtered.asMap().entries.map((entry) => EntranceSlide(
                          index: entry.key,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: MedicationCard(
                              med: entry.value,
                              isCooling: _cooling[entry.value.id] == true,
                              onMarkTaken: () =>
                                  _markTaken(entry.value.id, entry.value.name),
                            ),
                          ),
                        )),
                  const SizedBox(height: AppSpacing.xxl),
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
