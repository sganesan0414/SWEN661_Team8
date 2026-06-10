import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../theme/app_theme.dart';

class AddEditReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddEditReminderScreen({super.key, this.reminder});

  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends ConsumerState<AddEditReminderScreen> {
  late ReminderType _type;
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TimeOfDay _time;
  late List<bool> _days;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _type = r?.type ?? ReminderType.medication;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _subtitleCtrl = TextEditingController(text: r?.subtitle ?? '');
    _time = r?.time ?? const TimeOfDay(hour: 8, minute: 0);
    _days = r != null ? List<bool>.from(r.days) : List.filled(7, true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _setQuickDays(String option) {
    setState(() {
      switch (option) {
        case 'everyday':
          _days = List.filled(7, true);
        case 'weekdays':
          _days = [true, true, true, true, true, false, false];
        case 'weekends':
          _days = [false, false, false, false, false, true, true];
      }
    });
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    final notifier = ref.read(remindersProvider.notifier);
    if (_isEditing) {
      notifier.update(widget.reminder!.copyWith(
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        time: _time,
        days: List<bool>.from(_days),
      ));
    } else {
      notifier.add(Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        time: _time,
        days: List<bool>.from(_days),
      ));
    }
    Navigator.of(context).pop();
  }

  bool get _isEveryDay => _days.every((d) => d);
  bool get _isWeekdays =>
      _days[0] && _days[1] && _days[2] && _days[3] && _days[4] &&
      !_days[5] && !_days[6];
  bool get _isWeekends =>
      !_days[0] && !_days[1] && !_days[2] && !_days[3] && !_days[4] &&
      _days[5] && _days[6];

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final h = _time.hour > 12
        ? _time.hour - 12
        : (_time.hour == 0 ? 12 : _time.hour);
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$h:$m $period';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reminder Type', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'Medication',
                    icon: Icons.medication_outlined,
                    selected: _type == ReminderType.medication,
                    onTap: () => setState(() => _type = ReminderType.medication),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    label: 'Appointment',
                    icon: Icons.event_outlined,
                    selected: _type == ReminderType.appointment,
                    onTap: () =>
                        setState(() => _type = ReminderType.appointment),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Title', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g., Lisinopril or Dr. Smith Visit',
              ),
            ),
            const SizedBox(height: 16),

            Text('Details (optional)', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _subtitleCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g., 10 mg or Annual Checkup',
              ),
            ),
            const SizedBox(height: 20),

            Text('Time', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(timeStr, style: AppTextStyles.bodyLarge),
                    const Spacer(),
                    Text('Tap to change', style: AppTextStyles.caption),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Repeat On', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickDayButton(
                    label: 'Every Day',
                    selected: _isEveryDay,
                    onTap: () => _setQuickDays('everyday'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickDayButton(
                    label: 'Weekdays',
                    selected: _isWeekdays,
                    onTap: () => _setQuickDays('weekdays'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickDayButton(
                    label: 'Weekends',
                    selected: _isWeekends,
                    onTap: () => _setQuickDays('weekends'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _days[i] = !_days[i]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _days[i] ? AppColors.primary : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _days[i] ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNames[i],
                        style: AppTextStyles.caption.copyWith(
                          color: _days[i] ? Colors.white : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(_isEditing ? 'Save Changes' : 'Add Reminder'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDayButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickDayButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
