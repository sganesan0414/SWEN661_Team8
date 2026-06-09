import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late List<_ReminderData> reminders;

  @override
  void initState() {
    super.initState();
    reminders = [
      _ReminderData(
        name: 'Take Lisinopril',
        time: '8:00 AM',
        days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        icon: Icons.medication_outlined,
        soundOn: true,
        vibrationOn: true,
        isEnabled: true,
      ),
      _ReminderData(
        name: 'Take Metformin',
        time: '8:00 AM',
        days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        icon: Icons.medication_outlined,
        soundOn: true,
        vibrationOn: false,
        isEnabled: true,
      ),
      _ReminderData(
        name: 'Blood Pressure Check',
        time: '7:15 AM',
        days: ['Mon', 'Wed', 'Fri'],
        icon: Icons.favorite_outline,
        soundOn: true,
        vibrationOn: true,
        isEnabled: true,
      ),
      _ReminderData(
        name: 'Doctor Appointment',
        time: '10:00 AM',
        days: ['June 15'],
        icon: Icons.event_outlined,
        soundOn: true,
        vibrationOn: true,
        isEnabled: true,
      ),
      _ReminderData(
        name: 'Take Atorvastatin',
        time: '9:00 PM',
        days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        icon: Icons.medication_outlined,
        soundOn: true,
        vibrationOn: true,
        isEnabled: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CareConnect'),
        actions: [
          Semantics(
            button: true,
            label: 'Sign out',
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
              label: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ContextBar(
            screenLabel: 'Reminders — Medication & Health Reminders',
          ),
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
                                  Text('Reminders',
                                    style: AppTextStyles.displayLarge),
                                  const SizedBox(height: 4),
                                  Text('${reminders.where((r) => r.isEnabled).length} active reminders',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
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

                          // Reminders List
                          ...reminders.map((reminder) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ReminderCard(
                              reminder: reminder,
                              onToggle: (value) {
                                setState(() {
                                  reminder.isEnabled = value;
                                });
                              },
                              onEdit: () {},
                              onDelete: () {
                                setState(() {
                                  reminders.remove(reminder);
                                });
                              },
                            ),
                          )),
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
                          // Global Settings Card
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
                                Text('Global Settings',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                _SettingToggle(
                                  label: 'Master Sound',
                                  value: true,
                                  onChanged: (value) {},
                                ),
                                const SizedBox(height: 12),
                                _SettingToggle(
                                  label: 'Master Vibration',
                                  value: true,
                                  onChanged: (value) {},
                                ),
                                const SizedBox(height: 12),
                                _SettingToggle(
                                  label: 'Do Not Disturb',
                                  value: false,
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Statistics Card
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
                                Text('Statistics',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                _StatisticRow(
                                  label: 'Active Reminders',
                                  value: reminders.where((r) => r.isEnabled).length.toString(),
                                ),
                                const SizedBox(height: 12),
                                _StatisticRow(
                                  label: 'Medication Alerts',
                                  value: '3',
                                ),
                                const SizedBox(height: 12),
                                _StatisticRow(
                                  label: 'Health Checks',
                                  value: '1',
                                ),
                                const SizedBox(height: 12),
                                _StatisticRow(
                                  label: 'Appointments',
                                  value: '1',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions Card
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
                                Text('Quick Actions',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
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

class _ReminderData {
  final String name;
  final String time;
  final List<String> days;
  final IconData icon;
  final bool soundOn;
  final bool vibrationOn;
  bool isEnabled;

  _ReminderData({
    required this.name,
    required this.time,
    required this.days,
    required this.icon,
    required this.soundOn,
    required this.vibrationOn,
    required this.isEnabled,
  });
}

class _ReminderCard extends StatelessWidget {
  final _ReminderData reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(reminder.icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.name,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(reminder.time,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Switch(
                value: reminder.isEnabled,
                onChanged: onToggle,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: reminder.days.map((day) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: reminder.isEnabled ? AppColors.primary.withOpacity(0.1) : AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(day,
                style: AppTextStyles.caption.copyWith(
                  color: reminder.isEnabled ? AppColors.primary : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                )),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (reminder.soundOn) ...[
                Icon(Icons.volume_up_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Sound On',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ],
              if (reminder.soundOn && reminder.vibrationOn)
                const SizedBox(width: 12),
              if (reminder.vibrationOn) ...[
                Icon(Icons.vibration, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Vibration On',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  label: const Text('Delete',
                    style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
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
        Text(widget.label, style: AppTextStyles.bodyMedium),
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() => _value = value);
            widget.onChanged(value);
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatisticRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            )),
        ),
      ],
    );
  }
}
