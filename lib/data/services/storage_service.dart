import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/card_model.dart';

class StorageService {
  static const _transactionsBox = 'transactions';
  static const _settingsBox = 'settings';
  static const _cardsKey = 'cards';

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

  // Settings — Profile photo path
  String? get profilePhotoPath => _settings.get('profilePhotoPath');
  Future<void> setProfilePhotoPath(String? path) =>
      _settings.put('profilePhotoPath', path);

  /// Saves a profile photo file to app documents directory
  /// Accepts a File parameter for the image
  /// Generates unique filename with timestamp
  /// Copies image file to documents directory
  /// Deletes old photo if exists
  /// Saves new path to Hive storage
  /// Returns the saved file path
  Future<String> saveProfilePhoto(File imageFile) async {
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    
    // Generate unique filename with timestamp
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Copy image file to documents directory
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    
    // Delete old photo if exists
    final oldPath = profilePhotoPath;
    if (oldPath != null) {
      try {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        debugPrint('Error deleting old photo: $e');
      }
    }
    
    // Save new path to Hive storage
    await setProfilePhotoPath(savedImage.path);
    
    // Return saved file path
    return savedImage.path;
  }

  /// Retrieves the profile photo File object
  /// Returns File if photo exists at stored path, null otherwise
  /// Handles missing or corrupted files gracefully
  Future<File?> getProfilePhotoFile() async {
    try {
      // Retrieve profile photo path from Hive storage
      final path = profilePhotoPath;
      
      // Return null if no path is stored
      if (path == null) {
        return null;
      }
      
      // Create File object from path
      final file = File(path);
      
      // Check if file exists at path
      if (await file.exists()) {
        return file;
      } else {
        // File doesn't exist, clear the stored path
        await setProfilePhotoPath(null);
        return null;
      }
    } catch (e) {
      // Handle any errors gracefully (corrupted files, permission issues, etc.)
      debugPrint('Error retrieving profile photo: $e');
      return null;
    }
  }

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

}

