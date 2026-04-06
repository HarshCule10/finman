import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/storage_service.dart';

class CategoryProvider extends ChangeNotifier {
  final StorageService _storage;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  CategoryProvider(this._storage);

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get favoriteCategories =>
      _categories.where((c) => c.isFavorite).toList();
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads all categories from storage
  Future<void> loadCategories() async {
    try {
      _categories = await _storage.getAllCategories();
      _errorMessage = null;
      debugPrint('Successfully loaded ${_categories.length} categories');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _errorMessage = 'Failed to load categories. Please try again.';
      _categories = []; // Fallback to empty state
      notifyListeners();
    }
  }

  /// Initializes default categories if none exist
  Future<bool> initializeDefaultCategories() async {
    try {
      await _storage.initializeDefaultCategories();
      await loadCategories();
      debugPrint('Successfully initialized default categories');
      return true;
    } catch (e) {
      debugPrint('Error initializing default categories: $e');
      _errorMessage = 'Failed to initialize categories. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Toggles the favorite status of a category
  Future<bool> toggleFavorite(String categoryId) async {
    try {
      final category = getCategoryById(categoryId);
      if (category == null) {
        debugPrint('Category not found: $categoryId');
        _errorMessage = 'Category not found.';
        notifyListeners();
        return false;
      }

      final updatedCategory = category.copyWith(
        isFavorite: !category.isFavorite,
      );

      await _storage.updateCategory(updatedCategory);
      
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
        _errorMessage = null;
        debugPrint('Successfully toggled favorite for category: $categoryId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      _errorMessage = 'Failed to update category. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Retrieves a category by its ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
