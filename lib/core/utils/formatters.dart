import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _currencyDecimal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final _dateShort = DateFormat('dd MMM');
  static final _dateFull = DateFormat('dd MMM yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _dayName = DateFormat('EEEE');
  static final _time = DateFormat('hh:mm a');

  static String currency(double amount) => _currency.format(amount);
  static String currencyDecimal(double amount) => _currencyDecimal.format(amount);
  static String dateShort(DateTime date) => _dateShort.format(date);
  static String dateFull(DateTime date) => _dateFull.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String dayName(DateTime date) => _dayName.format(date);
  static String time(DateTime date) => _time.format(date);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return _dayName.format(date);
    return _dateShort.format(date);
  }
}
