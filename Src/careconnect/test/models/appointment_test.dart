import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/appointment.dart';

void main() {
  group('Appointment', () {
    final base = Appointment(
      id: 'a1',
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2026, 6, 1, 9),
      location: 'Clinic',
    );

    test('copyWith overrides dateTime when provided', () {
      final newTime = DateTime(2026, 7, 1, 10);
      final updated = base.copyWith(dateTime: newTime);
      expect(updated.dateTime, newTime);
      expect(updated.id, base.id);
    });

    test('copyWith keeps dateTime when not provided', () {
      final updated = base.copyWith(status: AppointmentStatus.completed);
      expect(updated.dateTime, base.dateTime);
      expect(updated.status, AppointmentStatus.completed);
    });
  });
}
