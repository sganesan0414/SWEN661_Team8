import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
  }

  Future<void> scheduleAppointmentReminder(Appointment appointment) async {
    const androidDetails = AndroidNotificationDetails(
      'appointments',
      'Appointment Reminders',
      channelDescription: 'Reminders for upcoming appointments',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final body =
        '${appointment.doctorName} - ${appointment.specialty} at ${appointment.location}';

    final minus24h = appointment.dateTime.subtract(const Duration(hours: 24));
    final minus1h = appointment.dateTime.subtract(const Duration(hours: 1));
    final now = DateTime.now();

    if (minus24h.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: appointment.id.hashCode,
        title: 'Appointment Tomorrow',
        body: body,
        scheduledDate: tz.TZDateTime.from(minus24h, tz.local),
        notificationDetails: notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    if (minus1h.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: appointment.id.hashCode + 1,
        title: 'Appointment in 1 Hour',
        body: body,
        scheduledDate: tz.TZDateTime.from(minus1h, tz.local),
        notificationDetails: notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAppointmentReminders(String id) async {
    await _plugin.cancel(id: id.hashCode);
    await _plugin.cancel(id: id.hashCode + 1);
  }
}
