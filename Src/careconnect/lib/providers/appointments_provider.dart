import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/notification_service.dart';

class AppointmentsState {
  final List<Appointment> appointments;
  final bool isLoading;

  const AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
  });

  AppointmentsState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<Appointment> get upcoming => appointments
      .where((a) => a.status == AppointmentStatus.upcoming)
      .toList();

  List<Appointment> get completed => appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .toList();
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final NotificationService _notificationService;

  AppointmentsNotifier(this._notificationService)
      : super(AppointmentsState(appointments: _mockAppointments));

  Future<void> scheduleAppointment(Appointment appointment) async {
    state = state.copyWith(
      appointments: [...state.appointments, appointment],
    );
    await _notificationService.scheduleAppointmentReminder(appointment);
  }

  Future<void> cancelAppointment(String id) async {
    state = state.copyWith(
      appointments: state.appointments
          .map((a) =>
              a.id == id ? a.copyWith(status: AppointmentStatus.cancelled) : a)
          .toList(),
    );
    await _notificationService.cancelAppointmentReminders(id);
  }

  Future<void> rescheduleAppointment(String id, DateTime newDateTime) async {
    final old = state.appointments.firstWhere((a) => a.id == id);
    await _notificationService.cancelAppointmentReminders(id);
    final updated = old.copyWith(dateTime: newDateTime);
    state = state.copyWith(
      appointments: state.appointments
          .map((a) => a.id == id ? updated : a)
          .toList(),
    );
    await _notificationService.scheduleAppointmentReminder(updated);
  }
}

final _mockAppointments = [
  Appointment(
    id: 'a1',
    doctorName: 'Dr. Sarah Johnson',
    specialty: 'Primary Care',
    dateTime: DateTime(2026, 6, 15, 10, 0),
    location: 'City Medical Center, Room 204',
    notes: 'Annual physical - bring medication list.',
  ),
  Appointment(
    id: 'a2',
    doctorName: 'Dr. Michael Chen',
    specialty: 'Cardiology',
    dateTime: DateTime(2026, 7, 3, 14, 30),
    location: 'Heart & Vascular Institute',
    notes: 'Heart checkup - fasting required.',
  ),
  Appointment(
    id: 'a3',
    doctorName: 'Dr. Emily Rodriguez',
    specialty: 'Endocrinology',
    dateTime: DateTime(2026, 5, 20, 9, 0),
    location: 'Diabetes & Hormone Clinic',
    notes: 'Routine diabetes management.',
    status: AppointmentStatus.completed,
  ),
];

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  return AppointmentsNotifier(ref.read(notificationServiceProvider));
});
