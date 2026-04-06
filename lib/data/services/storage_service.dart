import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/card_model.dart';
import '../models/category_model.dart';

class StorageService {
  static const _transactionsBox = 'transactions';
  static const _settingsBox = 'settings';
  static const _cardsKey = 'cards';
  static const _categoriesKey = 'categories';

  late Box<Transaction> _transactions;
  late Box _settings;
  final _secureStorage = const FlutterSecureStorage();

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

  // Cards — Secure storage with JSON serialization
  
  /// Helper method to load cards from secure storage
  Future<List<CardModel>> _loadCards() async {
    try {
      final cardsJson = await _secureStorage.read(key: _cardsKey);
      if (cardsJson == null) return [];
      
      final List<dynamic> cardsList = jsonDecode(cardsJson);
      return cardsList.map((json) => CardModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Helper method to save cards to secure storage
  Future<void> _saveCards(List<CardModel> cards) async {
    final cardsJson = jsonEncode(cards.map((c) => c.toJson()).toList());
    await _secureStorage.write(key: _cardsKey, value: cardsJson);
  }

  /// Retrieves all stored cards
  Future<List<CardModel>> getAllCards() async {
    return await _loadCards();
  }

  /// Adds a new card to secure storage
  Future<void> addCard(CardModel card) async {
    final cards = await _loadCards();
    cards.add(card);
    await _saveCards(cards);
  }

  /// Updates an existing card in secure storage
  Future<void> updateCard(CardModel card) async {
    final cards = await _loadCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      await _saveCards(cards);
    }
  }

  /// Deletes a card from secure storage
  Future<void> deleteCard(String id) async {
    final cards = await _loadCards();
    cards.removeWhere((c) => c.id == id);
    await _saveCards(cards);
  }

  // Categories — Secure storage with JSON serialization
  
  /// Helper method to load categories from secure storage
  Future<List<CategoryModel>> _loadCategories() async {
    try {
      final categoriesJson = await _secureStorage.read(key: _categoriesKey);
      if (categoriesJson == null) return [];
      
      final List<dynamic> categoriesList = jsonDecode(categoriesJson);
      return categoriesList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Helper method to save categories to secure storage
  Future<void> _saveCategories(List<CategoryModel> categories) async {
    final categoriesJson = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _secureStorage.write(key: _categoriesKey, value: categoriesJson);
  }

  /// Retrieves all stored categories
  Future<List<CategoryModel>> getAllCategories() async {
    return await _loadCategories();
  }

  /// Adds a new category to secure storage
  Future<void> addCategory(CategoryModel category) async {
    final categories = await _loadCategories();
    categories.add(category);
    await _saveCategories(categories);
  }

  /// Updates an existing category in secure storage
  Future<void> updateCategory(CategoryModel category) async {
    final categories = await _loadCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await _saveCategories(categories);
    }
  }

  /// Deletes a category from secure storage
  Future<void> deleteCategory(String id) async {
    final categories = await _loadCategories();
    categories.removeWhere((c) => c.id == id);
    await _saveCategories(categories);
  }

  /// Retrieves all favorite categories
  Future<List<CategoryModel>> getFavoriteCategories() async {
    final categories = await _loadCategories();
    return categories.where((c) => c.isFavorite).toList();
  }

  // Transaction filtering methods

  /// Retrieves transactions within a specific date range (inclusive)
  List<Transaction> getTransactionsInDateRange(DateTime start, DateTime end) {
    return getAllTransactions()
        .where((t) => 
            (t.date.isAfter(start) || t.date.isAtSameMomentAs(start)) &&
            (t.date.isBefore(end) || t.date.isAtSameMomentAs(end)))
        .toList();
  }

  /// Retrieves transactions filtered by category
  List<Transaction> getTransactionsByCategory(String category) {
    return getAllTransactions()
        .where((t) => t.category == category)
        .toList();
  }

  // Default categories initialization

  /// Default categories to initialize on first app launch
  static final List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'cat_food',
      name: 'Food & Dining',
      iconName: 'restaurant',
      colorValue: 0xFFFF6B6B,
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Transportation',
      iconName: 'directions_car',
      colorValue: 0xFF4ECDC4,
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'Shopping',
      iconName: 'shopping_bag',
      colorValue: 0xFFFFBE0B,
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Entertainment',
      iconName: 'movie',
      colorValue: 0xFF9B59B6,
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      iconName: 'receipt',
      colorValue: 0xFF3498DB,
    ),
    CategoryModel(
      id: 'cat_health',
      name: 'Healthcare',
      iconName: 'local_hospital',
      colorValue: 0xFFE74C3C,
    ),
    CategoryModel(
      id: 'cat_education',
      name: 'Education',
      iconName: 'school',
      colorValue: 0xFF2ECC71,
    ),
    CategoryModel(
      id: 'cat_other',
      name: 'Other',
      iconName: 'more_horiz',
      colorValue: 0xFF95A5A6,
    ),
  ];

  /// Initializes default categories on first app launch
  /// Only adds categories if no categories exist in storage
  Future<void> initializeDefaultCategories() async {
    final existingCategories = await getAllCategories();
    
    // Only initialize if no categories exist
    if (existingCategories.isEmpty) {
      await _saveCategories(defaultCategories);
    }
  }
}
