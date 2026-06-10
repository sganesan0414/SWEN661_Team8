import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/reminder.dart';
import '../providers/medications_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/reminders_provider.dart';
import 'add_edit_reminder_screen.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const RemindersScreen({super.key, this.onBack});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  // Local hide/disable sets for derived (medication/appointment) reminders
  final Set<String> _hiddenMedIds = {};
  final Set<String> _disabledMedIds = {};
  final Set<String> _hiddenApptIds = {};
  final Set<String> _disabledApptIds = {};

  Future<void> _confirmDelete(String id, String title, VoidCallback onConfirm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Remove "$title" from your reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditReminderScreen()),
    );
  }

  void _navigateToEdit(Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditReminderScreen(reminder: reminder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medState = ref.watch(medicationsProvider);
    final apptState = ref.watch(appointmentsProvider);
    final customReminders = ref.watch(remindersProvider);

    final visibleMeds = medState.medications
        .where((m) => !m.taken && !_hiddenMedIds.contains(m.id))
        .toList();
    final visibleAppts = apptState.upcoming
        .where((a) => !_hiddenApptIds.contains(a.id))
        .toList();

    final activeCount = visibleMeds.where((m) => !_disabledMedIds.contains(m.id)).length +
        visibleAppts.where((a) => !_disabledApptIds.contains(a.id)).length +
        customReminders.where((r) => r.isEnabled).length;

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    return isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMainColumn(
                                context,
                                visibleMeds,
                                visibleAppts,
                                customReminders,
                                activeCount,
                              ),
                              const SizedBox(height: 24),
                              _buildSideColumn(activeCount, visibleMeds.length,
                                  visibleAppts.length),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildMainColumn(
                                  context,
                                  visibleMeds,
                                  visibleAppts,
                                  customReminders,
                                  activeCount,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 1,
                                child: _buildSideColumn(activeCount,
                                    visibleMeds.length, visibleAppts.length),
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainColumn(
    BuildContext context,
    List visibleMeds,
    List visibleAppts,
    List<Reminder> customReminders,
    int activeCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledBackButton(
          label: 'Dashboard',
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminders', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    '$activeCount active reminders',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(140, 44),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Custom reminders ───────────────────────────────────────────
        if (customReminders.isNotEmpty) ...[
          Text('My Reminders', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...customReminders.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ReminderCard(
                  icon: r.type == ReminderType.medication
                      ? Icons.medication_outlined
                      : Icons.event_outlined,
                  iconColor: r.type == ReminderType.medication
                      ? AppColors.primary
                      : const Color(0xFF7B3FA0),
                  title: r.title,
                  subtitle: r.subtitle,
                  timeLabel: r.formattedTime,
                  daysLabel: r.daysLabel,
                  isEnabled: r.isEnabled,
                  onToggle: () =>
                      ref.read(remindersProvider.notifier).toggle(r.id),
                  onEdit: () => _navigateToEdit(r),
                  onDelete: () => _confirmDelete(
                    r.id,
                    r.title,
                    () => ref.read(remindersProvider.notifier).delete(r.id),
                  ),
                ),
              )),
          const SizedBox(height: 8),
        ],

        // ── Medications due ────────────────────────────────────────────
        Text('Medications Due', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        if (visibleMeds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('All medications taken for today.',
                style: AppTextStyles.bodyMedium),
          )
        else
          ...visibleMeds.map((med) {
            final disabled = _disabledMedIds.contains(med.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ReminderCard(
                icon: Icons.medication_outlined,
                iconColor: AppColors.primary,
                title: med.name,
                subtitle: med.dose,
                timeLabel: med.times.isNotEmpty ? med.times.first : '',
                daysLabel: med.schedule,
                isEnabled: !disabled,
                onToggle: () => setState(() {
                  if (disabled) {
                    _disabledMedIds.remove(med.id);
                  } else {
                    _disabledMedIds.add(med.id);
                  }
                }),
                onDelete: () => _confirmDelete(
                  med.id,
                  med.name,
                  () => setState(() => _hiddenMedIds.add(med.id)),
                ),
              ),
            );
          }),

        // ── Upcoming appointments ──────────────────────────────────────
        if (visibleAppts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Upcoming Appointments', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...visibleAppts.map((appt) {
            final disabled = _disabledApptIds.contains(appt.id);
            final h = appt.dateTime.hour > 12
                ? appt.dateTime.hour - 12
                : (appt.dateTime.hour == 0 ? 12 : appt.dateTime.hour);
            final m = appt.dateTime.minute.toString().padLeft(2, '0');
            final period = appt.dateTime.hour >= 12 ? 'PM' : 'AM';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ReminderCard(
                icon: Icons.event_outlined,
                iconColor: const Color(0xFF7B3FA0),
                title: appt.doctorName,
                subtitle: appt.specialty,
                timeLabel: '$h:$m $period',
                daysLabel: _apptDateLabel(appt.dateTime),
                isEnabled: !disabled,
                onToggle: () => setState(() {
                  if (disabled) {
                    _disabledApptIds.remove(appt.id);
                  } else {
                    _disabledApptIds.add(appt.id);
                  }
                }),
                onDelete: () => _confirmDelete(
                  appt.id,
                  appt.doctorName,
                  () => setState(() => _hiddenApptIds.add(appt.id)),
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSideColumn(int activeCount, int medicationsDue, int appointments) {
    return Column(
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
              _StatRow(label: 'Medications Due', value: '$medicationsDue'),
              const SizedBox(height: 12),
              _StatRow(label: 'Appointments', value: '$appointments'),
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
    );
  }

  String _apptDateLabel(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'One-time · ${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

// ── Reminder card ────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String daysLabel;
  final bool isEnabled;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.daysLabel,
    required this.isEnabled,
    required this.onToggle,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon, title/subtitle, time chip
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timeLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: isEnabled ? AppColors.primary : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Days row
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 5),
                Text(
                  daysLabel,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Actions row: toggle, edit (optional), delete
            Row(
              children: [
                Switch(
                  value: isEnabled,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryLight,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Text(
                  isEnabled ? 'On' : 'Off',
                  style: AppTextStyles.caption.copyWith(
                    color: isEnabled ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.textMuted),
                    onPressed: onEdit,
                    tooltip: 'Edit reminder',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.redAccent),
                  onPressed: onDelete,
                  tooltip: 'Delete reminder',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Setting row ──────────────────────────────────────────────────────────────

class _SettingRow extends StatefulWidget {
  final String label;
  final bool value;

  const _SettingRow({required this.label, required this.value});

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(widget.label, style: AppTextStyles.bodyMedium)),
        Switch(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

// ── Stat row ─────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
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
