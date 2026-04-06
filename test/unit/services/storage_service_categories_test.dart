import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finman/data/services/storage_service.dart';
import 'package:finman/data/models/category_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() {
    // Setup mock secure storage
    FlutterSecureStorage.setMockInitialValues({});
    storageService = StorageService();
  });

  group('StorageService Category Methods', () {
    test('getAllCategories returns empty list when no categories stored', () async {
      final categories = await storageService.getAllCategories();
      expect(categories, isEmpty);
    });

    test('addCategory stores a category and getAllCategories retrieves it', () async {
      // Arrange
      final category = CategoryModel(
        id: 'cat1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        budgetLimit: 5000.0,
        isFavorite: false,
        colorValue: 0xFFFF6B6B,
      );

      // Act
      await storageService.addCategory(category);
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'cat1');
      expect(categories[0].name, 'Food & Dining');
      expect(categories[0].iconName, 'restaurant');
      expect(categories[0].budgetLimit, 5000.0);
      expect(categories[0].isFavorite, false);
      expect(categories[0].colorValue, 0xFFFF6B6B);
    });

    test('addCategory preserves order of categories', () async {
      // Arrange
      final cat1 = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      final cat2 = CategoryModel(
        id: 'cat2',
        name: 'Transport',
        iconName: 'directions_car',
        colorValue: 0xFF4ECDC4,
      );

      // Act
      await storageService.addCategory(cat1);
      await storageService.addCategory(cat2);
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories[0].id, 'cat1');
      expect(categories[1].id, 'cat2');
    });

    test('updateCategory modifies existing category', () async {
      // Arrange
      final category = CategoryModel(
        id: 'cat1',
        name: 'Old Name',
        iconName: 'restaurant',
        budgetLimit: 1000.0,
        isFavorite: false,
        colorValue: 0xFFFF6B6B,
      );

      await storageService.addCategory(category);

      final updatedCategory = category.copyWith(
        name: 'New Name',
        budgetLimit: 2000.0,
        isFavorite: true,
      );

      // Act
      await storageService.updateCategory(updatedCategory);
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'cat1');
      expect(categories[0].name, 'New Name');
      expect(categories[0].budgetLimit, 2000.0);
      expect(categories[0].isFavorite, true);
      expect(categories[0].iconName, 'restaurant'); // Unchanged
    });

    test('updateCategory does nothing if category not found', () async {
      // Arrange
      final cat1 = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      await storageService.addCategory(cat1);

      final nonExistentCategory = CategoryModel(
        id: 'cat999',
        name: 'Non-existent',
        iconName: 'help',
        colorValue: 0xFF000000,
      );

      // Act
      await storageService.updateCategory(nonExistentCategory);
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'cat1'); // Original category unchanged
    });

    test('deleteCategory removes category from storage', () async {
      // Arrange
      final cat1 = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      final cat2 = CategoryModel(
        id: 'cat2',
        name: 'Transport',
        iconName: 'directions_car',
        colorValue: 0xFF4ECDC4,
      );

      await storageService.addCategory(cat1);
      await storageService.addCategory(cat2);

      // Act
      await storageService.deleteCategory('cat1');
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'cat2');
    });

    test('deleteCategory handles non-existent category gracefully', () async {
      // Arrange
      final category = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      await storageService.addCategory(category);

      // Act
      await storageService.deleteCategory('nonexistent');
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'cat1');
    });

    test('getFavoriteCategories returns only favorite categories', () async {
      // Arrange
      final cat1 = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        isFavorite: true,
        colorValue: 0xFFFF6B6B,
      );

      final cat2 = CategoryModel(
        id: 'cat2',
        name: 'Transport',
        iconName: 'directions_car',
        isFavorite: false,
        colorValue: 0xFF4ECDC4,
      );

      final cat3 = CategoryModel(
        id: 'cat3',
        name: 'Shopping',
        iconName: 'shopping_bag',
        isFavorite: true,
        colorValue: 0xFFFFBE0B,
      );

      await storageService.addCategory(cat1);
      await storageService.addCategory(cat2);
      await storageService.addCategory(cat3);

      // Act
      final favorites = await storageService.getFavoriteCategories();

      // Assert
      expect(favorites.length, 2);
      expect(favorites[0].id, 'cat1');
      expect(favorites[1].id, 'cat3');
      expect(favorites.every((c) => c.isFavorite), true);
    });

    test('getFavoriteCategories returns empty list when no favorites', () async {
      // Arrange
      final category = CategoryModel(
        id: 'cat1',
        name: 'Food',
        iconName: 'restaurant',
        isFavorite: false,
        colorValue: 0xFFFF6B6B,
      );

      await storageService.addCategory(category);

      // Act
      final favorites = await storageService.getFavoriteCategories();

      // Assert
      expect(favorites, isEmpty);
    });

    test('category storage round-trip preserves all fields', () async {
      // Arrange
      final originalCategory = CategoryModel(
        id: 'test-cat-123',
        name: 'Entertainment',
        iconName: 'movie',
        budgetLimit: 3500.50,
        isFavorite: true,
        colorValue: 0xFF9B59B6,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      // Act
      await storageService.addCategory(originalCategory);
      final categories = await storageService.getAllCategories();
      final retrievedCategory = categories[0];

      // Assert
      expect(retrievedCategory.id, originalCategory.id);
      expect(retrievedCategory.name, originalCategory.name);
      expect(retrievedCategory.iconName, originalCategory.iconName);
      expect(retrievedCategory.budgetLimit, originalCategory.budgetLimit);
      expect(retrievedCategory.isFavorite, originalCategory.isFavorite);
      expect(retrievedCategory.colorValue, originalCategory.colorValue);
      expect(retrievedCategory.createdAt, originalCategory.createdAt);
    });

    test('category with null budgetLimit is stored and retrieved correctly', () async {
      // Arrange
      final category = CategoryModel(
        id: 'cat1',
        name: 'Other',
        iconName: 'more_horiz',
        budgetLimit: null,
        isFavorite: false,
        colorValue: 0xFF95A5A6,
      );

      // Act
      await storageService.addCategory(category);
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].budgetLimit, null);
    });

    test('multiple categories can be stored and retrieved', () async {
      // Arrange
      final categories = List.generate(
        5,
        (i) => CategoryModel(
          id: 'cat$i',
          name: 'Category $i',
          iconName: 'icon_$i',
          budgetLimit: (i + 1) * 1000.0,
          isFavorite: i % 2 == 0,
          colorValue: 0xFF000000 + i * 0x111111,
        ),
      );

      // Act
      for (final category in categories) {
        await storageService.addCategory(category);
      }
      final retrievedCategories = await storageService.getAllCategories();

      // Assert
      expect(retrievedCategories.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(retrievedCategories[i].id, 'cat$i');
        expect(retrievedCategories[i].name, 'Category $i');
        expect(retrievedCategories[i].isFavorite, i % 2 == 0);
      }
    });

    test('initializeDefaultCategories creates 8 default categories when storage is empty', () async {
      // Act
      await storageService.initializeDefaultCategories();
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 8);
      expect(categories[0].id, 'cat_food');
      expect(categories[0].name, 'Food & Dining');
      expect(categories[1].id, 'cat_transport');
      expect(categories[1].name, 'Transportation');
      expect(categories[2].id, 'cat_shopping');
      expect(categories[2].name, 'Shopping');
      expect(categories[3].id, 'cat_entertainment');
      expect(categories[3].name, 'Entertainment');
      expect(categories[4].id, 'cat_bills');
      expect(categories[4].name, 'Bills & Utilities');
      expect(categories[5].id, 'cat_health');
      expect(categories[5].name, 'Healthcare');
      expect(categories[6].id, 'cat_education');
      expect(categories[6].name, 'Education');
      expect(categories[7].id, 'cat_other');
      expect(categories[7].name, 'Other');
    });

    test('initializeDefaultCategories does not overwrite existing categories', () async {
      // Arrange
      final existingCategory = CategoryModel(
        id: 'custom_cat',
        name: 'Custom Category',
        iconName: 'custom_icon',
        colorValue: 0xFF123456,
      );
      await storageService.addCategory(existingCategory);

      // Act
      await storageService.initializeDefaultCategories();
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 'custom_cat');
      expect(categories[0].name, 'Custom Category');
    });

    test('default categories have correct icons and colors', () async {
      // Act
      await storageService.initializeDefaultCategories();
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories[0].iconName, 'restaurant');
      expect(categories[0].colorValue, 0xFFFF6B6B);
      expect(categories[1].iconName, 'directions_car');
      expect(categories[1].colorValue, 0xFF4ECDC4);
      expect(categories[2].iconName, 'shopping_bag');
      expect(categories[2].colorValue, 0xFFFFBE0B);
      expect(categories[3].iconName, 'movie');
      expect(categories[3].colorValue, 0xFF9B59B6);
      expect(categories[4].iconName, 'receipt');
      expect(categories[4].colorValue, 0xFF3498DB);
      expect(categories[5].iconName, 'local_hospital');
      expect(categories[5].colorValue, 0xFFE74C3C);
      expect(categories[6].iconName, 'school');
      expect(categories[6].colorValue, 0xFF2ECC71);
      expect(categories[7].iconName, 'more_horiz');
      expect(categories[7].colorValue, 0xFF95A5A6);
    });

    test('default categories are not marked as favorites', () async {
      // Act
      await storageService.initializeDefaultCategories();
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.every((c) => c.isFavorite == false), true);
    });

    test('default categories have no budget limits', () async {
      // Act
      await storageService.initializeDefaultCategories();
      final categories = await storageService.getAllCategories();

      // Assert
      expect(categories.every((c) => c.budgetLimit == null), true);
    });
  });
}
