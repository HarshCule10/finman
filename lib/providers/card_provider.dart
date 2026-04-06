import 'package:flutter/material.dart';
import '../data/models/card_model.dart';
import '../data/services/storage_service.dart';

class CardProvider extends ChangeNotifier {
  final StorageService _storage;
  List<CardModel> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  CardProvider(this._storage) {
    loadCards();
  }

  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  bool get hasCards => _cards.isNotEmpty;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads all cards from storage
  Future<void> loadCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _storage.getAllCards();
      debugPrint('Successfully loaded ${_cards.length} cards');
    } catch (e) {
      debugPrint('Error loading cards: $e');
      _errorMessage = 'Failed to load cards. Please try again.';
      _cards = []; // Fallback to empty state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new card to storage
  Future<bool> addCard(CardModel card) async {
    try {
      await _storage.addCard(card);
      _cards.add(card);
      _errorMessage = null;
      debugPrint('Successfully added card: ${card.id}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding card: $e');
      _errorMessage = 'Failed to add card. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing card in storage
  Future<bool> updateCard(CardModel card) async {
    try {
      await _storage.updateCard(card);
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        _errorMessage = null;
        debugPrint('Successfully updated card: ${card.id}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating card: $e');
      _errorMessage = 'Failed to update card. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a card from storage
  Future<bool> deleteCard(String id) async {
    try {
      await _storage.deleteCard(id);
      _cards.removeWhere((c) => c.id == id);
      _errorMessage = null;
      debugPrint('Successfully deleted card: $id');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting card: $e');
      _errorMessage = 'Failed to delete card. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
