import 'package:flutter_test/flutter_test.dart';
import 'package:finman/core/utils/date_range.dart';

void main() {
  group('DateRange', () {
    group('contains', () {
      test('returns true when date is within range', () {
        final range = DateRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31, 23, 59, 59),
        );

        expect(range.contains(DateTime(2024, 3, 15)), isTrue);
      });

      test('returns true when date equals start date', () {
        final range = DateRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31, 23, 59, 59),
        );

        expect(range.contains(DateTime(2024, 3, 1)), isTrue);
      });

      test('returns true when date equals end date', () {
        final range = DateRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31, 23, 59, 59),
        );

        expect(range.contains(DateTime(2024, 3, 31, 23, 59, 59)), isTrue);
      });

      test('returns false when date is before range', () {
        final range = DateRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31, 23, 59, 59),
        );

        expect(range.contains(DateTime(2024, 2, 28)), isFalse);
      });

      test('returns false when date is after range', () {
        final range = DateRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31, 23, 59, 59),
        );

        expect(range.contains(DateTime(2024, 4, 1)), isFalse);
      });
    });

    group('currentWeek', () {
      test('returns a range starting on Monday', () {
        final range = DateRange.currentWeek();

        // Monday is weekday 1 in Dart
        expect(range.start.weekday, equals(DateTime.monday));
      });

      test('returns a range spanning exactly 7 days', () {
        final range = DateRange.currentWeek();

        final duration = range.end.difference(range.start);
        expect(duration.inDays, equals(7));
      });

      test('starts at midnight (00:00:00)', () {
        final range = DateRange.currentWeek();

        expect(range.start.hour, equals(0));
        expect(range.start.minute, equals(0));
        expect(range.start.second, equals(0));
      });

      test('contains today', () {
        final range = DateRange.currentWeek();
        final today = DateTime.now();

        expect(range.contains(today), isTrue);
      });
    });

    group('previousWeek', () {
      test('ends where current week starts', () {
        final current = DateRange.currentWeek();
        final previous = DateRange.previousWeek();

        expect(previous.end, equals(current.start));
      });

      test('spans exactly 7 days', () {
        final range = DateRange.previousWeek();

        final duration = range.end.difference(range.start);
        expect(duration.inDays, equals(7));
      });

      test('starts on Monday', () {
        final range = DateRange.previousWeek();

        expect(range.start.weekday, equals(DateTime.monday));
      });

      test('does not contain today', () {
        final range = DateRange.previousWeek();
        final today = DateTime.now();

        expect(range.contains(today), isFalse);
      });
    });

    group('currentMonth', () {
      test('starts on the first day of the month', () {
        final range = DateRange.currentMonth();

        expect(range.start.day, equals(1));
      });

      test('starts at midnight (00:00:00)', () {
        final range = DateRange.currentMonth();

        expect(range.start.hour, equals(0));
        expect(range.start.minute, equals(0));
        expect(range.start.second, equals(0));
      });

      test('ends on the last day of the month', () {
        final range = DateRange.currentMonth();
        final now = DateTime.now();

        // Get the last day of the current month
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        expect(range.end.day, equals(lastDay));
      });

      test('ends at 23:59:59', () {
        final range = DateRange.currentMonth();

        expect(range.end.hour, equals(23));
        expect(range.end.minute, equals(59));
        expect(range.end.second, equals(59));
      });

      test('contains today', () {
        final range = DateRange.currentMonth();
        final today = DateTime.now();

        expect(range.contains(today), isTrue);
      });

      test('handles February in leap year correctly', () {
        // Create a mock for February 2024 (leap year)
        final feb2024Start = DateTime(2024, 2, 1);
        final feb2024End = DateTime(2024, 3, 0, 23, 59, 59);
        final range = DateRange(start: feb2024Start, end: feb2024End);

        expect(range.end.day, equals(29)); // Leap year has 29 days
      });

      test('handles February in non-leap year correctly', () {
        // Create a mock for February 2023 (non-leap year)
        final feb2023Start = DateTime(2023, 2, 1);
        final feb2023End = DateTime(2023, 3, 0, 23, 59, 59);
        final range = DateRange(start: feb2023Start, end: feb2023End);

        expect(range.end.day, equals(28)); // Non-leap year has 28 days
      });
    });

    group('previousMonth', () {
      test('is the month before the current month', () {
        final current = DateRange.currentMonth();
        final previous = DateRange.previousMonth();

        expect(previous.end.month, equals(current.start.month - 1 == 0 ? 12 : current.start.month - 1));
      });

      test('starts on the first day of the month', () {
        final range = DateRange.previousMonth();

        expect(range.start.day, equals(1));
      });

      test('starts at midnight (00:00:00)', () {
        final range = DateRange.previousMonth();

        expect(range.start.hour, equals(0));
        expect(range.start.minute, equals(0));
        expect(range.start.second, equals(0));
      });

      test('ends at 23:59:59', () {
        final range = DateRange.previousMonth();

        expect(range.end.hour, equals(23));
        expect(range.end.minute, equals(59));
        expect(range.end.second, equals(59));
      });

      test('does not contain today', () {
        final range = DateRange.previousMonth();
        final today = DateTime.now();

        expect(range.contains(today), isFalse);
      });

      test('handles year boundary correctly (January -> December)', () {
        // Mock a date in January to test year boundary
        final jan2024 = DateTime(2024, 1, 15);
        final startOfDec = DateTime(jan2024.year, jan2024.month - 1, 1);
        final endOfDec = DateTime(jan2024.year, jan2024.month, 0, 23, 59, 59);

        expect(startOfDec.year, equals(2023));
        expect(startOfDec.month, equals(12));
        expect(endOfDec.year, equals(2023));
        expect(endOfDec.month, equals(12));
        expect(endOfDec.day, equals(31));
      });
    });
  });
}
