import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';

class _Medication {
  final String id, name, dose, schedule;
  final List<String> times;
  bool taken;

  _Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    required this.times,
    this.taken = false,
  });
}

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  // TODO: We need to replace this with a real provider
  final List<_Medication> _meds = [
    _Medication(id: '1', name: 'Lisinopril',    dose: '10 mg',  schedule: 'Daily',        times: ['8:00 AM']),
    _Medication(id: '2', name: 'Metformin',     dose: '500 mg', schedule: 'Twice daily',  times: ['8:00 AM', '8:00 PM'], taken: true),
    _Medication(id: '3', name: 'Atorvastatin',  dose: '20 mg',  schedule: 'Daily',        times: ['9:00 PM']),
    _Medication(id: '4', name: 'Aspirin',       dose: '81 mg',  schedule: 'Daily',        times: ['8:00 AM']),
    _Medication(id: '5', name: 'Levothyroxine', dose: '75 mcg', schedule: 'Daily',        times: ['7:00 AM'], taken: true),
    _Medication(id: '6', name: 'Omeprazole',    dose: '20 mg',  schedule: 'Daily',        times: ['7:30 AM']),
  ];

  String _searchQuery = '';
  String? _lastUndoneId;    
  final Map<String, bool> _cooling = {}; 

  List<_Medication> get _filtered => _meds.where((m) {
    if (_searchQuery.isEmpty) return true;
    return m.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  int get _takenCount => _meds.where((m) => m.taken).length;
  int get _upcomingCount => _meds.where((m) => !m.taken).length;

  Future<void> _markTaken(String id) async {
    if (_cooling[id] == true) return; // STML #22: debounce guard
    HapticFeedback.mediumImpact();    // STML #17: immediate feedback

    setState(() {
      _cooling[id] = true;
      final med = _meds.firstWhere((m) => m.id == id);
      med.taken = true;
      _lastUndoneId = null;
    });

    final med = _meds.firstWhere((m) => m.id == id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${med.name} marked as taken'),
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
    setState(() {
      final med = _meds.firstWhere((m) => m.id == id);
      med.taken = false;
      _lastUndoneId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search medications…',
                        prefixIcon: const Icon(Icons.search_outlined),
                        suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                              tooltip: 'Clear search',
                            )
                          : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: StatCard(icon: Icons.medication, iconColor: AppColors.primary, value: '${_meds.length}', label: 'Total Medications')),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.check_circle_outline, iconColor: AppColors.success, value: '$_takenCount', label: 'Taken Today')),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.schedule, iconColor: AppColors.warning, value: '$_upcomingCount', label: 'Upcoming')),
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
                        onMarkTaken: () => _markTaken(med.id),
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
  final _Medication med;
  final bool isCooling;
  final VoidCallback onMarkTaken;

  const _MedicationCard({
    required this.med,
    required this.isCooling,
    required this.onMarkTaken,
  });

  Color get _borderColor {
    if (med.taken) return AppColors.success;
    return AppColors.primary;
  }

  Color get _bgColor {
    if (med.taken) return AppColors.successBg;
    return AppColors.infoBg;
  }

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
            // ── Header row ─────────────────────────────────────────────────
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

            // ── Schedule ───────────────────────────────────────────────────
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

            // ── Action button (STML #22: debounced; #28: linear action) ───
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
                onPressed: null, // Taken — read-only
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