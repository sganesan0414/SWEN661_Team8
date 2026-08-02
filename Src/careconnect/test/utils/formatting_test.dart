import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/utils/formatting.dart';

void main() {
  group('initialsOf', () {
    test('takes the first letter of the first two words', () {
      expect(initialsOf('Sarah Johnson'), 'SJ');
      expect(initialsOf('Mary Anne Smith'), 'MA');
    });

    test('uppercases lowercase names', () {
      expect(initialsOf('sarah johnson'), 'SJ');
    });

    test('handles a single word', () {
      expect(initialsOf('Cher'), 'C');
    });

    // The previous inline implementation was
    // `name.split(' ').map((w) => w[0]).take(2).join()`, which throws a
    // RangeError on every input below: splitting on a single space leaves
    // empty segments that have no index 0.
    test('does not throw on repeated or surrounding whitespace', () {
      expect(initialsOf('Sarah  Johnson'), 'SJ');
      expect(initialsOf('  Sarah Johnson  '), 'SJ');
      expect(initialsOf('Sarah\tJohnson'), 'SJ');
    });

    test('falls back instead of throwing on empty input', () {
      expect(initialsOf(''), '?');
      expect(initialsOf('   '), '?');
      expect(initialsOf('', fallback: '—'), '—');
    });
  });

  group('greetingForHour', () {
    test('changes with the time of day', () {
      expect(greetingForHour(0), 'Good Morning');
      expect(greetingForHour(11), 'Good Morning');
      expect(greetingForHour(12), 'Good Afternoon');
      expect(greetingForHour(16), 'Good Afternoon');
      expect(greetingForHour(17), 'Good Evening');
      expect(greetingForHour(23), 'Good Evening');
    });
  });

  group('time formatting', () {
    test('renders 12-hour clock with meridiem', () {
      expect(formatTime(DateTime(2026, 1, 5, 0, 5)), '12:05 AM');
      expect(formatTime(DateTime(2026, 1, 5, 9, 0)), '9:00 AM');
      expect(formatTime(DateTime(2026, 1, 5, 12, 0)), '12:00 PM');
      expect(formatTime(DateTime(2026, 1, 5, 13, 30)), '1:30 PM');
      expect(formatTime(DateTime(2026, 1, 5, 23, 59)), '11:59 PM');
    });

    test('formatHourMinute matches formatTime for the same clock value', () {
      expect(formatHourMinute(13, 30), formatTime(DateTime(2026, 1, 5, 13, 30)));
    });
  });

  group('date formatting', () {
    final date = DateTime(2026, 8, 2);

    test('long, short and numeric forms agree on the same date', () {
      expect(formatLongDate(date), 'August 2, 2026');
      expect(formatShortDate(date), 'Aug 2, 2026');
      expect(formatNumericDate(date), '8/2/2026');
      expect(formatWeekdayDate(date), 'Sunday, August 2');
    });

    test('month names are bounds-safe', () {
      expect(monthName(1), 'January');
      expect(monthName(12), 'December');
      expect(shortMonthName(1), 'Jan');
      // The screen-local versions this replaced indexed a list directly and
      // threw a RangeError for anything outside 1..12.
      expect(monthName(0), '');
      expect(monthName(13), '');
      expect(shortMonthName(99), '');
    });
  });
}
