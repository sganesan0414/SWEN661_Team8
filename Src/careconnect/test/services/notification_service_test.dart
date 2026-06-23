import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:careconnect/models/appointment.dart';
import 'package:careconnect/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin: mockPlugin);
    when(() => mockPlugin.initialize(settings: any(named: 'settings')))
        .thenAnswer((_) async => true);
    when(() => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        )).thenAnswer((_) async {});
    when(() => mockPlugin.cancel(id: any(named: 'id')))
        .thenAnswer((_) async {});
  });

  group('NotificationService.initialize', () {
    test('initializes the underlying plugin', () async {
      await service.initialize();
      verify(() => mockPlugin.initialize(settings: any(named: 'settings')))
          .called(1);
    });
  });

  group('NotificationService.scheduleAppointmentReminder', () {
    Appointment appointmentIn(Duration fromNow) => Appointment(
          id: 'appt-1',
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now().add(fromNow),
          location: 'Clinic',
        );

    test('schedules both reminders when appointment is more than 24h away',
        () async {
      await service.scheduleAppointmentReminder(
        appointmentIn(const Duration(hours: 48)),
      );
      verify(() => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(2);
    });

    test('schedules only the 1-hour reminder when within the 24h window',
        () async {
      await service.scheduleAppointmentReminder(
        appointmentIn(const Duration(hours: 2)),
      );
      verify(() => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('schedules nothing for an appointment already in the past',
        () async {
      await service.scheduleAppointmentReminder(
        appointmentIn(const Duration(hours: -1)),
      );
      verifyNever(() => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          ));
    });
  });

  group('NotificationService.cancelAppointmentReminders', () {
    test('cancels both the 24h and 1h reminder ids', () async {
      await service.cancelAppointmentReminders('appt-1');
      verify(() => mockPlugin.cancel(id: 'appt-1'.hashCode)).called(1);
      verify(() => mockPlugin.cancel(id: 'appt-1'.hashCode + 1)).called(1);
    });
  });
}
