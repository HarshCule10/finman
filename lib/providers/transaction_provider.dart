import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction.dart';
import '../data/services/storage_service.dart';
import '../core/utils/date_range.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Transaction> _transactions = [];
  final Map<String, double> _cachedTotals = {};
  String? _errorMessage;

  TransactionProvider(this._storage);

  DateTime get selectedMonth => _selectedMonth;
  List<Transaction> get transactions => _transactions;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads all transactions from storage into memory
  Future<void> loadTransactions() async {
    try {
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      _errorMessage = null;
      debugPrint('Successfully loaded ${_transactions.length} transactions');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _errorMessage = 'Failed to load transactions. Please try again.';
      _transactions = []; // Fallback to empty state
      notifyListeners();
    }
  }

  /// Returns transactions within the specified date range
  List<Transaction> getTransactionsInRange(DateRange range) {
    try {
      return _transactions
          .where((t) => range.contains(t.date))
          .toList();
    } catch (e) {
      debugPrint('Error filtering transactions by range: $e');
      return []; // Fallback to empty list
    }
  }

  /// Calculates the total amount for transactions in the specified date range
  /// 
  /// If [expensesOnly] is true, only expense transactions (isIncome = false) are included.
  /// Uses caching to avoid recalculating the same totals.
  double getTotalForRange(DateRange range, {bool expensesOnly = true}) {
    try {
      final cacheKey = '${range.start.toIso8601String()}_${range.end.toIso8601String()}_$expensesOnly';
      
      // Return cached value if available
      if (_cachedTotals.containsKey(cacheKey)) {
        return _cachedTotals[cacheKey]!;
      }
      
      // Calculate total
      final transactionsInRange = getTransactionsInRange(range);
      final filteredTransactions = expensesOnly
          ? transactionsInRange.where((t) => !t.isIncome)
          : transactionsInRange;
      
      final total = filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
      
      // Cache the result
      _cachedTotals[cacheKey] = total;
      
      return total;
    } catch (e) {
      debugPrint('Error calculating total for range: $e');
      return 0.0; // Fallback to zero
    }
  }

  /// Returns a map of category names to their total amounts for the specified date range
  /// 
  /// Only includes expense transactions (isIncome = false).
  Map<String, double> getCategoryTotalsForRange(DateRange range) {
    try {
      final transactionsInRange = getTransactionsInRange(range);
      final expenseTransactions = transactionsInRange.where((t) => !t.isIncome);
      
      final categoryTotals = <String, double>{};
      for (final transaction in expenseTransactions) {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
      }
      
      return categoryTotals;
    } catch (e) {
      debugPrint('Error calculating category totals: $e');
      return {}; // Fallback to empty map
    }
  }

  /// Invalidates all cached totals
  void _invalidateCache() {
    _cachedTotals.clear();
  }

  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      _selectedMonth = next;
      notifyListeners();
    }
  }

  List<Transaction> get allTransactions => _transactions.isNotEmpty 
      ? _transactions 
      : _storage.getAllTransactions();

  List<Transaction> get monthTransactions =>
      allTransactions
          .where((t) => t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month)
          .toList();

  List<Transaction> get recentTransactions =>
      allTransactions.take(20).toList();

  double get monthIncome => monthTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthExpenses => monthTransactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthBalance => monthIncome - monthExpenses;

  double get totalBalance => allTransactions.fold(
      0.0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));

  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final t in monthTransactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Future<bool> add({
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
    String note = '',
  }) async {
    try {
      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        category: category,
        date: date,
        note: note,
        isIncome: isIncome,
      );
      await _storage.addTransaction(transaction);
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      _errorMessage = null;
      debugPrint('Successfully added transaction: ${transaction.id}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      _errorMessage = 'Failed to add transaction. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _storage.deleteTransaction(id);
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      _errorMessage = null;
      debugPrint('Successfully deleted transaction: $id');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      _errorMessage = 'Failed to delete transaction. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
    String note = '',
  }) async {
    try {
      final transaction = Transaction(
        id: id,
        amount: amount,
        category: category,
        date: date,
        note: note,
        isIncome: isIncome,
      );
      await _storage.updateTransaction(transaction);
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      _errorMessage = null;
      debugPrint('Successfully updated transaction: $id');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      _errorMessage = 'Failed to update transaction. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ── Chart data ──────────────────────────────────────────────────────────────

  /// Returns daily income/expense totals for a given week (Mon–Sun).
  /// Result list has 7 entries index 0=Mon … 6=Sun.
  List<Map<String, double>> getWeeklyChartData(DateTime weekStart) {
    final data = List.generate(
      7,
      (_) => {'income': 0.0, 'expense': 0.0},
    );
    for (final t in _storage.getAllTransactions()) {
      final dayOffset = t.date
          .difference(
              DateTime(weekStart.year, weekStart.month, weekStart.day))
          .inDays;
      if (dayOffset >= 0 && dayOffset < 7) {
        if (t.isIncome) {
          data[dayOffset]['income'] = data[dayOffset]['income']! + t.amount;
        } else {
          data[dayOffset]['expense'] = data[dayOffset]['expense']! + t.amount;
        }
      }
    }
    return data;
  }

  /// Returns weekly income/expense totals for the given month.
  /// Splits the month into ISO weeks (up to 5 groups).
  List<Map<String, double>> getMonthlyChartData(DateTime month) {
    // Find first and last day of month
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final weeks = <Map<String, double>>[];

    DateTime weekStart = firstDay;
    while (weekStart.isBefore(lastDay) ||
        weekStart.isAtSameMomentAs(lastDay)) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final clampedEnd = weekEnd.isAfter(lastDay) ? lastDay : weekEnd;
      weeks.add({'income': 0.0, 'expense': 0.0});

      for (final t in _storage.getAllTransactions()) {
        final d = DateTime(t.date.year, t.date.month, t.date.day);
        if (!d.isBefore(weekStart) && !d.isAfter(clampedEnd)) {
          if (t.isIncome) {
            weeks.last['income'] = weeks.last['income']! + t.amount;
          } else {
            weeks.last['expense'] = weeks.last['expense']! + t.amount;
          }
        }
      }
      weekStart = weekStart.add(const Duration(days: 7));
    }
    return weeks;
  }

  // ── Weekly helpers ───────────────────────────────────────────────────────────

  DateTime get _currentWeekStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  List<Transaction> get weekTransactions {
    final start = _currentWeekStart;
    final end = start.add(const Duration(days: 7));
    return allTransactions
        .where((t) =>
            !t.date.isBefore(start) && t.date.isBefore(end))
        .toList();
  }

  double get weekIncome =>
      weekTransactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get weekExpenses =>
      weekTransactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get weekBalance => weekIncome - weekExpenses;
}
