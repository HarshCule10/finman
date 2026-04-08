import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction.dart';
import '../data/services/storage_service.dart';
import '../core/utils/date_range.dart';
import '../core/constants/categories.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Transaction> _transactions = [];
  final Map<String, double> _cachedTotals = {};
  String? _errorMessage;

  TransactionProvider(this._storage);

  DateTime get selectedMonth => _selectedMonth;
  
  List<Transaction> get rawTransactions => _transactions.isNotEmpty 
      ? _transactions 
      : _storage.getAllTransactions();
      
  List<Transaction> get allTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return rawTransactions.where((t) {
      if (t.recurringId == null) return true;
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      return !txDate.isAfter(today);
    }).toList();
  }

  List<Transaction> get transactions => allTransactions;
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

  // allTransactions getter was replaced and moved to the top.

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
    String? cardId,
  }) async {
    try {
      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        category: category,
        date: date,
        note: note,
        isIncome: isIncome,
        cardId: cardId,
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

  Future<bool> addRecurring({
    required double amount,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
    required bool isIncome,
    String note = '',
    String? cardId,
  }) async {
    try {
      final recurringId = _uuid.v4();
      DateTime current = startDate;
      
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        final transaction = Transaction(
          id: _uuid.v4(),
          amount: amount,
          category: category,
          date: current,
          note: note,
          isIncome: isIncome,
          cardId: cardId,
          recurringId: recurringId,
          frequency: frequency,
        );
        await _storage.addTransaction(transaction);
        
        switch (frequency) {
          case 'Daily':
            current = current.add(const Duration(days: 1));
            break;
          case 'Weekly':
            current = current.add(const Duration(days: 7));
            break;
          case 'Monthly':
            current = DateTime(current.year, current.month + 1, current.day);
            break;
          case 'Yearly':
            current = DateTime(current.year + 1, current.month, current.day);
            break;
          default:
            current = current.add(const Duration(days: 30));
        }
      }
      
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to set up recurring transactions. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Returns a list of grouped future recurring transactions.
  List<Map<String, dynamic>> getRecurringGroups() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final groups = <String, List<Transaction>>{};
    for (final t in rawTransactions) {
      if (t.recurringId != null) {
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);
        if (txDate.isAfter(today)) {
          groups.putIfAbsent(t.recurringId!, () => []).add(t);
        }
      }
    }
    
    final result = <Map<String, dynamic>>[];
    groups.forEach((id, txs) {
      txs.sort((a, b) => a.date.compareTo(b.date));
      result.add({
        'recurringId': id,
        'nextTransaction': txs.first,
        'remainingCount': txs.length,
      });
    });
    
    result.sort((a, b) => (a['nextTransaction'] as Transaction).date.compareTo((b['nextTransaction'] as Transaction).date));
    return result;
  }

  Future<bool> cancelNextPayment(String recurringId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final futures = rawTransactions.where((t) {
        if (t.recurringId != recurringId) return false;
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);
        return txDate.isAfter(today);
      }).toList();
      
      if (futures.isNotEmpty) {
        futures.sort((a, b) => a.date.compareTo(b.date));
        await delete(futures.first.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelEntireSubscription(String recurringId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final futures = rawTransactions.where((t) {
        if (t.recurringId != recurringId) return false;
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);
        return txDate.isAfter(today);
      }).map((t) => t.id).toList();
      
      for (final id in futures) {
        await _storage.deleteTransaction(id);
      }
      
      _transactions = _storage.getAllTransactions();
      _invalidateCache();
      notifyListeners();
      return true;
    } catch (e) {
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
    String? cardId,
  }) async {
    try {
      final transaction = Transaction(
        id: id,
        amount: amount,
        category: category,
        date: date,
        note: note,
        isIncome: isIncome,
        cardId: cardId,
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

  /// Normalises a stored category value to a key.
  /// Old data stored full labels (e.g. "Food & Dining"); new data stores keys (e.g. "food").
  /// If [stored] already is a key, returns it unchanged.
  String _normalizeCategory(String stored) {
    // Already a key?
    if (AppCategories.fromKey(stored) != null) return stored;
    // Try matching by label (case-insensitive)
    final match = AppCategories.all.where(
      (c) => c.label.toLowerCase() == stored.toLowerCase(),
    ).firstOrNull;
    return match?.key ?? stored;
  }

  // ── Statistics helpers ────────────────────────────────────────────────────────

  /// Category breakdown for a given month, sorted descending by amount.
  /// Set [expensesOnly] to false to get income categories instead.
  Map<String, double> getCategoryBreakdownForMonth(
    DateTime month, {
    bool expensesOnly = true,
  }) {
    final txs = allTransactions
        .where((t) =>
            t.date.year == month.year &&
            t.date.month == month.month &&
            t.isIncome != expensesOnly) // income when !expensesOnly
        .toList();
    final map = <String, double>{};
    for (final t in txs) {
      final key = _normalizeCategory(t.category);
      map[key] = (map[key] ?? 0) + t.amount;
    }
    // Sort descending
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  /// Returns daily totals for a specific month/year, filtered by income status.
  /// Result is a list of maps with 'date' (DateTime) and 'amount' (double).
  List<Map<String, dynamic>> getDailyTrendForMonth(
    DateTime month, {
    required bool isIncome,
  }) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final result = <Map<String, dynamic>>[];
    final transactions = allTransactions;

    // Iterate through each day of the month
    for (int i = 1; i <= daysInMonth; i++) {
      final dayStart = DateTime(month.year, month.month, i);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTotal = transactions.where((t) {
        return t.isIncome == isIncome &&
            !t.date.isBefore(dayStart) &&
            t.date.isBefore(dayEnd);
      }).fold(0.0, (sum, t) => sum + t.amount);

      result.add({
        'date': dayStart,
        'amount': dayTotal,
      });
    }

    return result;
  }

  /// All transactions for a specific category key within a month.
  /// Handles both key-stored and legacy label-stored transactions.
  List<Transaction> getTransactionsByCategory(String categoryKey, DateTime month) {
    final catLabel =
        AppCategories.fromKey(categoryKey)?.label.toLowerCase();
    return allTransactions.where((t) {
      if (t.date.year != month.year || t.date.month != month.month) return false;
      final stored = t.category;
      if (stored == categoryKey) return true;
      if (catLabel != null && stored.toLowerCase() == catLabel) return true;
      return false;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── Search helpers ──────────────────────────────────────────────────────────

  /// Full-text search across note and category with optional filters.
  /// [isIncome] null = all, true = income only, false = expenses only.
  List<Transaction> searchTransactions({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryKey,
    bool? isIncome,
  }) {
    var results = allTransactions.toList();

    // Text search (case-insensitive across note + category)
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results
          .where((t) =>
              t.note.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))
          .toList();
    }

    // Date range
    if (startDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      results = results.where((t) => !t.date.isBefore(start)).toList();
    }
    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day)
          .add(const Duration(days: 1));
      results = results.where((t) => t.date.isBefore(end)).toList();
    }

    // Category — matches stored key OR legacy label strings (backward compat)
    if (categoryKey != null && categoryKey.isNotEmpty) {
      final catLabel =
          AppCategories.fromKey(categoryKey)?.label.toLowerCase();
      results = results.where((t) {
        final stored = t.category;
        // Key match (new data) OR label match (old data stored as label)
        if (stored == categoryKey) return true;
        if (catLabel != null && stored.toLowerCase() == catLabel) return true;
        return false;
      }).toList();
    }

    // Income / Expense
    if (isIncome != null) {
      results = results.where((t) => t.isIncome == isIncome).toList();
    }

    // Sort newest first
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
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
