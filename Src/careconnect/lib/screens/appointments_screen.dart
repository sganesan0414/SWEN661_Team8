import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/appointment.dart';
import '../providers/appointments_provider.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentsProvider);
    final appointments = state.appointments;
    final upcoming = state.upcoming;
    final completed = state.completed;

    final now = DateTime.now();
    final soonAppt = upcoming.where((a) =>
        a.dateTime.difference(now).inHours <= 24 &&
        a.dateTime.isAfter(now)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: StatCard(icon: Icons.calendar_today, iconColor: AppColors.primary, value: '${appointments.length}', label: 'Total')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.upcoming, iconColor: AppColors.warning, value: '${upcoming.length}', label: 'Upcoming')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.check_circle_outline, iconColor: AppColors.success, value: '${completed.length}', label: 'Completed')),
              ],
            ),
          ),
          if (soonAppt.isNotEmpty) ...[
            const SizedBox(height: 16),
            AlertBanner(
              icon: Icons.alarm,
              title: 'Appointment Soon',
              body: '${soonAppt.first.doctorName} - ${soonAppt.first.specialty} is within 24 hours.',
              actionLabel: 'View Details',
              onAction: () => _showDetailSheet(context, ref, soonAppt.first),
            ),
          ],
          const SizedBox(height: 20),
          Text('Your Appointments', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...appointments.map((appt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AppointmentListTile(
                  appointment: appt,
                  onTap: () => _showDetailSheet(context, ref, appt),
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, Appointment appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AppointmentDetailSheet(appointment: appt, ref: ref),
    );
  }
}

class _AppointmentListTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentListTile({required this.appointment, required this.onTap});

  Color get _borderColor {
    return switch (appointment.status) {
      AppointmentStatus.upcoming   => AppColors.primary,
      AppointmentStatus.completed  => AppColors.success,
      AppointmentStatus.cancelled  => AppColors.border,
    };
  }

  Color get _bgColor {
    return switch (appointment.status) {
      AppointmentStatus.upcoming   => AppColors.infoBg,
      AppointmentStatus.completed  => AppColors.successBg,
      AppointmentStatus.cancelled  => AppColors.surfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime;
    final dateStr = '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
    final timeStr = _formatTime(dt);

    return Semantics(
      button: true,
      label: '${appointment.doctorName}, ${appointment.specialty}, $dateStr at $timeStr',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _borderColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outlined, color: _borderColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName, style: AppTextStyles.labelLarge),
                    Text(appointment.specialty, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(child: Text('$dateStr  $timeStr', style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
                    ]),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(child: Text(appointment.location, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
              _StatusBadge(status: appointment.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AppointmentStatus.upcoming   => ('Upcoming',  AppColors.primary),
      AppointmentStatus.completed  => ('Done',      AppColors.success),
      AppointmentStatus.cancelled  => ('Cancelled', AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _AppointmentDetailSheet extends StatelessWidget {
  final Appointment appointment;
  final WidgetRef ref;

  const _AppointmentDetailSheet({required this.appointment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime;
    final dateStr = '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
    final timeStr = _formatTime(dt);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative drag handle — no semantic value
          ExcludeSemantics(
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(appointment.doctorName, style: AppTextStyles.headlineMedium),
          ),
          Text(appointment.specialty, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text('$dateStr at $timeStr', style: AppTextStyles.bodyMedium),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(child: Text(appointment.location, style: AppTextStyles.bodyMedium)),
          ]),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notes', style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(appointment.notes, style: AppTextStyles.bodyMedium),
          ],
          const SizedBox(height: 24),
          if (appointment.status == AppointmentStatus.upcoming) ...[
            Semantics(
              label: 'Reschedule appointment with ${appointment.doctorName}',
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Reschedule'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              label: 'Cancel appointment with ${appointment.doctorName}',
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(appointmentsProvider.notifier).cancelAppointment(appointment.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Appointment'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

String _monthName(int month) {
  const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return names[month];
}

String _formatTime(DateTime dt) {
  final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final m = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}
