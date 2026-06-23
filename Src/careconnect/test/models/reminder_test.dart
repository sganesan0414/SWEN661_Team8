import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/reminder.dart';

Reminder _buildReminder({
  TimeOfDay time = const TimeOfDay(hour: 9, minute: 5),
  List<bool> days = const [true, true, true, true, true, false, false],
  bool isEnabled = true,
}) {
  return Reminder(
    id: 'r1',
    type: ReminderType.medication,
    title: 'Take pill',
    subtitle: 'Once daily',
    time: time,
    days: days,
    isEnabled: isEnabled,
  );
}

void main() {
  group('Reminder', () {
    test('constructor sets all fields', () {
      final reminder = _buildReminder();
      expect(reminder.id, 'r1');
      expect(reminder.type, ReminderType.medication);
      expect(reminder.title, 'Take pill');
      expect(reminder.subtitle, 'Once daily');
      expect(reminder.isEnabled, isTrue);
    });

    test('copyWith overrides only provided fields', () {
      final original = _buildReminder();
      final updated = original.copyWith(title: 'New title', isEnabled: false);
      expect(updated.title, 'New title');
      expect(updated.isEnabled, isFalse);
      expect(updated.id, original.id);
      expect(updated.subtitle, original.subtitle);
      expect(updated.days, original.days);
    });

    test('copyWith with no args keeps original values', () {
      final original = _buildReminder();
      final copy = original.copyWith();
      expect(copy.title, original.title);
      expect(copy.subtitle, original.subtitle);
      expect(copy.time, original.time);
      expect(copy.days, original.days);
      expect(copy.isEnabled, original.isEnabled);
    });

    test('formattedTime renders AM for morning hours', () {
      final reminder = _buildReminder(time: const TimeOfDay(hour: 9, minute: 5));
      expect(reminder.formattedTime, '9:05 AM');
    });

    test('formattedTime renders PM for afternoon hours', () {
      final reminder = _buildReminder(time: const TimeOfDay(hour: 13, minute: 30));
      expect(reminder.formattedTime, '1:30 PM');
    });

    test('formattedTime renders noon as 12 PM', () {
      final reminder = _buildReminder(time: const TimeOfDay(hour: 12, minute: 0));
      expect(reminder.formattedTime, '12:00 PM');
    });

    test('formattedTime renders midnight as 12 AM', () {
      final reminder = _buildReminder(time: const TimeOfDay(hour: 0, minute: 0));
      expect(reminder.formattedTime, '12:00 AM');
    });

    test('daysLabel returns Every day when all days selected', () {
      final reminder = _buildReminder(
        days: const [true, true, true, true, true, true, true],
      );
      expect(reminder.daysLabel, 'Every day');
    });

    test('daysLabel returns Weekdays for Mon-Fri', () {
      final reminder = _buildReminder(
        days: const [true, true, true, true, true, false, false],
      );
      expect(reminder.daysLabel, 'Weekdays');
    });

    test('daysLabel returns Weekends for Sat-Sun', () {
      final reminder = _buildReminder(
        days: const [false, false, false, false, false, true, true],
      );
      expect(reminder.daysLabel, 'Weekends');
    });

    test('daysLabel lists abbreviated names for custom selection', () {
      final reminder = _buildReminder(
        days: const [true, false, true, false, false, false, false],
      );
      expect(reminder.daysLabel, 'Mon, Wed');
    });

    test('daysLabel returns No days selected when none chosen', () {
      final reminder = _buildReminder(
        days: const [false, false, false, false, false, false, false],
      );
      expect(reminder.daysLabel, 'No days selected');
    });

    test('daysLabel returns empty string when days length is not 7', () {
      final reminder = _buildReminder(days: const [true, false]);
      expect(reminder.daysLabel, '');
    });
  });
}
