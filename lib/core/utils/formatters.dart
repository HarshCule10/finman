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

  /// Formats a monetary amount with the specified currency symbol.
  /// 
  /// Features:
  /// - Displays currency symbol as prefix
  /// - Includes thousand separators (e.g., 1,234.56)
  /// - Shows exactly two decimal places
  /// - Handles negative amounts with minus sign before currency symbol
  /// 
  /// Example:
  /// ```dart
  /// formatCurrency('$', 1234.56)  // Returns: "$1,234.56"
  /// formatCurrency('₹', -500.0)   // Returns: "-₹500.00"
  /// formatCurrency('€', 0.0)      // Returns: "€0.00"
  /// ```
  static String formatCurrency(String currencySymbol, double amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    
    // Format with thousand separators and two decimal places
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(absoluteAmount);
    
    // Build the final string with proper sign placement
    if (isNegative) {
      return '-$currencySymbol$formattedAmount';
    } else {
      return '$currencySymbol$formattedAmount';
    }
  }

  /// Capitalizes the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
