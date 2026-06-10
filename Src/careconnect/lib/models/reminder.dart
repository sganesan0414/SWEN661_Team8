import 'package:flutter/material.dart';

enum ReminderType { medication, appointment }

class Reminder {
  final String id;
  final ReminderType type;
  final String title;
  final String subtitle;
  final TimeOfDay time;
  final List<bool> days; // index 0=Mon … 6=Sun
  final bool isEnabled;

  const Reminder({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });

  Reminder copyWith({
    String? title,
    String? subtitle,
    TimeOfDay? time,
    List<bool>? days,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id,
      type: type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      days: days ?? List<bool>.from(this.days),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  String get formattedTime {
    final h = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get daysLabel {
    if (days.length != 7) return '';
    if (days.every((d) => d)) return 'Every day';
    final isWeekdays =
        days[0] && days[1] && days[2] && days[3] && days[4] && !days[5] && !days[6];
    if (isWeekdays) return 'Weekdays';
    final isWeekends =
        !days[0] && !days[1] && !days[2] && !days[3] && !days[4] && days[5] && days[6];
    if (isWeekends) return 'Weekends';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = <String>[];
    for (int i = 0; i < 7; i++) {
      if (days[i]) active.add(names[i]);
    }
    return active.isEmpty ? 'No days selected' : active.join(', ');
  }
}
