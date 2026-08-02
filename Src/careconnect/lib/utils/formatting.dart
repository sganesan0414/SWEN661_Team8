/// Shared display formatting.
///
/// These helpers previously lived as private copies inside dashboard_screen,
/// appointments_screen and reminders — including two different `_monthName`
/// functions, one returning "January" and one returning "Jan", so the same
/// appointment rendered differently depending on which screen showed it.
library;

const List<String> _fullMonths = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _shortMonths = [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// "January" for month 1. Returns an empty string for an out-of-range month.
String monthName(int month) =>
    month >= 1 && month <= 12 ? _fullMonths[month] : '';

/// "Jan" for month 1. Returns an empty string for an out-of-range month.
String shortMonthName(int month) =>
    month >= 1 && month <= 12 ? _shortMonths[month] : '';

/// "3:05 PM"
String formatTime(DateTime dt) => formatHourMinute(dt.hour, dt.minute);

/// "3:05 PM" from raw hour/minute, for [TimeOfDay]-style values.
String formatHourMinute(int hour, int minute) {
  final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  final m = minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}

/// "January 5, 2026"
String formatLongDate(DateTime dt) =>
    '${monthName(dt.month)} ${dt.day}, ${dt.year}';

/// "Jan 5, 2026"
String formatShortDate(DateTime dt) =>
    '${shortMonthName(dt.month)} ${dt.day}, ${dt.year}';

/// "1/5/2026" — for dense rows where a numeric date is easier to scan.
String formatNumericDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

/// "Monday, January 5"
String formatWeekdayDate(DateTime dt) =>
    '${_weekdays[dt.weekday - 1]}, ${monthName(dt.month)} ${dt.day}';

/// A time-appropriate greeting. The dashboard previously hard-coded
/// "Good Morning", which read as wrong for most of the day.
String greetingForHour(int hour) {
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

/// Up to two uppercase initials for an avatar.
///
/// Guards against names that are empty or contain repeated/trailing spaces —
/// the previous inline `name.split(' ').map((w) => w[0])` threw a RangeError on
/// the empty strings those produce.
String initialsOf(String name, {String fallback = '?'}) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return fallback;
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}
