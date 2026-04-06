import 'package:flutter_test/flutter_test.dart';
import 'package:finman/data/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('creates CategoryModel with all required fields', () {
      final category = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      expect(category.id, 'cat_1');
      expect(category.name, 'Food & Dining');
      expect(category.iconName, 'restaurant');
      expect(category.budgetLimit, isNull);
      expect(category.isFavorite, false);
      expect(category.colorValue, 0xFFFF6B6B);
      expect(category.createdAt, isNotNull);
    });

    test('creates CategoryModel with optional fields', () {
      final category = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        budgetLimit: 500.0,
        isFavorite: true,
        colorValue: 0xFFFF6B6B,
      );

      expect(category.budgetLimit, 500.0);
      expect(category.isFavorite, true);
    });

    test('copyWith creates new instance with updated fields', () {
      final category = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        budgetLimit: 500.0,
        isFavorite: false,
        colorValue: 0xFFFF6B6B,
      );

      final updatedCategory = category.copyWith(
        name: 'Dining Out',
        isFavorite: true,
      );

      expect(updatedCategory.id, 'cat_1');
      expect(updatedCategory.name, 'Dining Out');
      expect(updatedCategory.iconName, 'restaurant');
      expect(updatedCategory.budgetLimit, 500.0);
      expect(updatedCategory.isFavorite, true);
      expect(updatedCategory.colorValue, 0xFFFF6B6B);
      expect(updatedCategory.createdAt, category.createdAt);
    });

    test('toJson serializes CategoryModel correctly', () {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      final category = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        budgetLimit: 500.0,
        isFavorite: true,
        colorValue: 0xFFFF6B6B,
        createdAt: createdAt,
      );

      final json = category.toJson();

      expect(json['id'], 'cat_1');
      expect(json['name'], 'Food & Dining');
      expect(json['iconName'], 'restaurant');
      expect(json['budgetLimit'], 500.0);
      expect(json['isFavorite'], true);
      expect(json['colorValue'], 0xFFFF6B6B);
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('toJson handles null budgetLimit', () {
      final category = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );

      final json = category.toJson();

      expect(json['budgetLimit'], isNull);
    });

    test('fromJson deserializes CategoryModel correctly', () {
      final json = {
        'id': 'cat_1',
        'name': 'Food & Dining',
        'iconName': 'restaurant',
        'budgetLimit': 500.0,
        'isFavorite': true,
        'colorValue': 0xFFFF6B6B,
        'createdAt': '2024-01-15T10:30:00.000',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, 'cat_1');
      expect(category.name, 'Food & Dining');
      expect(category.iconName, 'restaurant');
      expect(category.budgetLimit, 500.0);
      expect(category.isFavorite, true);
      expect(category.colorValue, 0xFFFF6B6B);
      expect(category.createdAt, DateTime.parse('2024-01-15T10:30:00.000'));
    });

    test('fromJson handles null budgetLimit', () {
      final json = {
        'id': 'cat_1',
        'name': 'Food & Dining',
        'iconName': 'restaurant',
        'budgetLimit': null,
        'isFavorite': false,
        'colorValue': 0xFFFF6B6B,
        'createdAt': '2024-01-15T10:30:00.000',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.budgetLimit, isNull);
    });

    test('fromJson defaults isFavorite to false when null', () {
      final json = {
        'id': 'cat_1',
        'name': 'Food & Dining',
        'iconName': 'restaurant',
        'budgetLimit': null,
        'isFavorite': null,
        'colorValue': 0xFFFF6B6B,
        'createdAt': '2024-01-15T10:30:00.000',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.isFavorite, false);
    });

    test('JSON round-trip preserves all data', () {
      final original = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        budgetLimit: 500.0,
        isFavorite: true,
        colorValue: 0xFFFF6B6B,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = CategoryModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.iconName, original.iconName);
      expect(restored.budgetLimit, original.budgetLimit);
      expect(restored.isFavorite, original.isFavorite);
      expect(restored.colorValue, original.colorValue);
      expect(restored.createdAt, original.createdAt);
    });

    test('JSON round-trip preserves data with null budgetLimit', () {
      final original = CategoryModel(
        id: 'cat_1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        isFavorite: false,
        colorValue: 0xFFFF6B6B,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = CategoryModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.iconName, original.iconName);
      expect(restored.budgetLimit, isNull);
      expect(restored.isFavorite, original.isFavorite);
      expect(restored.colorValue, original.colorValue);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
