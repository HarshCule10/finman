import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction.dart';
import '../data/services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  TransactionProvider(this._storage);

  DateTime get selectedMonth => _selectedMonth;

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

  List<Transaction> get allTransactions => _storage.getAllTransactions();

  List<Transaction> get monthTransactions =>
      _storage.getTransactionsForMonth(_selectedMonth.year, _selectedMonth.month);

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

  Future<void> add({
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
    String note = '',
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      date: date,
      note: note,
      isIncome: isIncome,
    );
    await _storage.addTransaction(transaction);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _storage.deleteTransaction(id);
    notifyListeners();
  }
}
