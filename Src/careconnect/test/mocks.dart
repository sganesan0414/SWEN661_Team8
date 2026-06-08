import 'package:mocktail/mocktail.dart';
import 'package:careconnect/services/notification_service.dart';
import 'package:careconnect/models/appointment.dart';

class MockNotificationService extends Mock implements NotificationService {}

void registerFallbacks() {
  registerFallbackValue(
    const Appointment(
      id: 'fallback',
      doctorName: 'Fake Doctor',
      specialty: 'General',
      dateTime: _time,
      location: 'Clinic',
    ),
  );
}

const _time = DateTime.utc(2000);
