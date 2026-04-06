import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class StorageService {
  static const _transactionsBox = 'transactions';
  static const _settingsBox = 'settings';

  late Box<Transaction> _transactions;
  late Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    _transactions = await Hive.openBox<Transaction>(_transactionsBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // Transactions
  List<Transaction> getAllTransactions() =>
      _transactions.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<Transaction> getTransactionsForMonth(int year, int month) {
    return getAllTransactions()
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) =>
      _transactions.put(transaction.id, transaction);

  Future<void> deleteTransaction(String id) => _transactions.delete(id);

  Future<void> updateTransaction(Transaction transaction) =>
      _transactions.put(transaction.id, transaction);

  // Settings — User profile
  String get userName => _settings.get('userName', defaultValue: '');
  Future<void> setUserName(String name) => _settings.put('userName', name);

  String get displayName => _settings.get('displayName', defaultValue: '');
  Future<void> setDisplayName(String name) => _settings.put('displayName', name);

  String get currency => _settings.get('currency', defaultValue: '₹');
  Future<void> setCurrency(String symbol) => _settings.put('currency', symbol);

  // Settings — Appearance
  bool get isDarkMode => _settings.get('isDarkMode', defaultValue: true);
  Future<void> setDarkMode(bool value) => _settings.put('isDarkMode', value);

  // Settings — Security type: 'pin', 'password', or null (disabled)
  String? get securityType => _settings.get('securityType');
  Future<void> setSecurityType(String? type) =>
      _settings.put('securityType', type);

  // Settings — Onboarding
  bool get isOnboarded => _settings.get('isOnboarded', defaultValue: false);
  Future<void> setOnboarded(bool value) => _settings.put('isOnboarded', value);
}
