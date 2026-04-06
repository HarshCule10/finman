/// A utility class for calculating and working with date ranges.
///
/// This class provides methods for calculating common date ranges like
/// current week, previous week, current month, and previous month.
/// It also provides a method to check if a date falls within a range.
class DateRange {
  /// The start date of the range (inclusive).
  final DateTime start;

  /// The end date of the range (inclusive).
  final DateTime end;

  /// Creates a date range with the specified start and end dates.
  const DateRange({
    required this.start,
    required this.end,
  });

  /// Checks if the given [date] falls within this date range (inclusive).
  ///
  /// Returns true if the date is on or after the start date and on or before
  /// the end date.
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }

  /// Returns a [DateRange] representing the current week.
  ///
  /// The week starts on Monday and ends on Sunday.
  /// For example, if today is Wednesday, March 15, 2024:
  /// - Start: Monday, March 13, 2024 at 00:00:00
  /// - End: Sunday, March 19, 2024 at 23:59:59
  static DateRange currentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return DateRange(start: startOfWeek, end: endOfWeek);
  }

  /// Returns a [DateRange] representing the previous week.
  ///
  /// The previous week is the 7 days before the current week starts.
  /// For example, if the current week starts on Monday, March 13, 2024:
  /// - Start: Monday, March 6, 2024 at 00:00:00
  /// - End: Sunday, March 12, 2024 at 23:59:59
  static DateRange previousWeek() {
    final current = currentWeek();
    return DateRange(
      start: current.start.subtract(const Duration(days: 7)),
      end: current.start,
    );
  }

  /// Returns a [DateRange] representing the current calendar month.
  ///
  /// For example, if today is March 15, 2024:
  /// - Start: March 1, 2024 at 00:00:00
  /// - End: March 31, 2024 at 23:59:59
  static DateRange currentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(start: startOfMonth, end: endOfMonth);
  }

  /// Returns a [DateRange] representing the previous calendar month.
  ///
  /// For example, if today is March 15, 2024:
  /// - Start: February 1, 2024 at 00:00:00
  /// - End: February 29, 2024 at 23:59:59
  ///
  /// This method correctly handles year boundaries. For example, if today is
  /// January 15, 2024, the previous month will be December 2023.
  static DateRange previousMonth() {
    final now = DateTime.now();
    final startOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPrevMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
    return DateRange(start: startOfPrevMonth, end: endOfPrevMonth);
  }
}
