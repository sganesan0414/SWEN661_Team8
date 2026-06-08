import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'package:careconnect/models/appointment.dart';
import '../mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('AppointmentsNotifier', () {
    late MockNotificationService mockNotif;
    late ProviderContainer container;

    setUp(() {
      mockNotif = MockNotificationService();
      when(() => mockNotif.scheduleAppointmentReminder(any()))
          .thenAnswer((_) async {});
      when(() => mockNotif.cancelAppointmentReminders(any()))
          .thenAnswer((_) async {});

      container = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(mockNotif),
      ]);
    });

    tearDown(() => container.dispose());

    test('initial state has 3 mock appointments', () {
      expect(container.read(appointmentsProvider).appointments.length, 3);
    });

    test('scheduleAppointment calls notification service', () async {
      final appt = Appointment(
        id: 'new1',
        doctorName: 'Dr. Test',
        specialty: 'Test',
        dateTime: DateTime.now().add(const Duration(days: 5)),
        location: 'Test Clinic',
      );
      await container.read(appointmentsProvider.notifier).scheduleAppointment(appt);
      verify(() => mockNotif.scheduleAppointmentReminder(appt)).called(1);
      expect(container.read(appointmentsProvider).appointments.length, 4);
    });

    test('cancelAppointment changes status and cancels notification', () async {
      await container.read(appointmentsProvider.notifier).cancelAppointment('a1');
      final appt = container.read(appointmentsProvider).appointments.firstWhere((a) => a.id == 'a1');
      expect(appt.status, AppointmentStatus.cancelled);
      verify(() => mockNotif.cancelAppointmentReminders('a1')).called(1);
    });

    test('upcoming excludes cancelled appointments', () async {
      await container.read(appointmentsProvider.notifier).cancelAppointment('a1');
      final upcoming = container.read(appointmentsProvider).upcoming;
      expect(upcoming.any((a) => a.id == 'a1'), isFalse);
    });
  });
}
