import 'package:flutter_test/flutter_test.dart';
import 'package:finman/core/utils/category_with_total.dart';
import 'package:finman/data/models/category_model.dart';

void main() {
  group('CategoryWithTotal', () {
    late CategoryModel testCategory;

    setUp(() {
      testCategory = CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorValue: 0xFFFF6B6B,
      );
    });

    group('constructor', () {
      test('stores category, currentTotal, and previousTotal correctly', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.category, equals(testCategory));
        expect(categoryWithTotal.currentTotal, equals(150.0));
        expect(categoryWithTotal.previousTotal, equals(100.0));
      });

      test('calculates percentageChange correctly when previousTotal > 0', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 100.0,
        );

        // ((150 - 100) / 100) * 100 = 50%
        expect(categoryWithTotal.percentageChange, equals(50.0));
      });

      test('calculates percentageChange as 0 when previousTotal is 0', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 0.0,
        );

        expect(categoryWithTotal.percentageChange, equals(0.0));
      });

      test('sets isNew to true when previousTotal is 0', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 0.0,
        );

        expect(categoryWithTotal.isNew, isTrue);
      });

      test('sets isNew to false when previousTotal > 0', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isNew, isFalse);
      });

      test('handles negative percentage change (decrease)', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 75.0,
          previousTotal: 100.0,
        );

        // ((75 - 100) / 100) * 100 = -25%
        expect(categoryWithTotal.percentageChange, equals(-25.0));
      });

      test('handles zero current total with non-zero previous total', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 0.0,
          previousTotal: 100.0,
        );

        // ((0 - 100) / 100) * 100 = -100%
        expect(categoryWithTotal.percentageChange, equals(-100.0));
      });

      test('handles both totals being zero', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 0.0,
          previousTotal: 0.0,
        );

        expect(categoryWithTotal.percentageChange, equals(0.0));
        expect(categoryWithTotal.isNew, isTrue);
      });
    });

    group('isIncrease getter', () {
      test('returns true when percentageChange is positive', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isIncrease, isTrue);
      });

      test('returns false when percentageChange is negative', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 75.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isIncrease, isFalse);
      });

      test('returns false when percentageChange is zero', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 100.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isIncrease, isFalse);
      });

      test('returns false when previousTotal is zero (new category)', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 0.0,
        );

        expect(categoryWithTotal.isIncrease, isFalse);
      });
    });

    group('isDecrease getter', () {
      test('returns true when percentageChange is negative', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 75.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isDecrease, isTrue);
      });

      test('returns false when percentageChange is positive', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isDecrease, isFalse);
      });

      test('returns false when percentageChange is zero', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 100.0,
          previousTotal: 100.0,
        );

        expect(categoryWithTotal.isDecrease, isFalse);
      });

      test('returns false when previousTotal is zero (new category)', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 150.0,
          previousTotal: 0.0,
        );

        expect(categoryWithTotal.isDecrease, isFalse);
      });
    });

    group('edge cases', () {
      test('handles very large percentage increases', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 1000.0,
          previousTotal: 10.0,
        );

        // ((1000 - 10) / 10) * 100 = 9900%
        expect(categoryWithTotal.percentageChange, equals(9900.0));
        expect(categoryWithTotal.isIncrease, isTrue);
      });

      test('handles very small amounts', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 0.01,
          previousTotal: 0.005,
        );

        // ((0.01 - 0.005) / 0.005) * 100 = 100%
        expect(categoryWithTotal.percentageChange, equals(100.0));
        expect(categoryWithTotal.isIncrease, isTrue);
      });

      test('handles decimal percentage changes', () {
        final categoryWithTotal = CategoryWithTotal(
          category: testCategory,
          currentTotal: 105.5,
          previousTotal: 100.0,
        );

        // ((105.5 - 100) / 100) * 100 = 5.5%
        expect(categoryWithTotal.percentageChange, equals(5.5));
        expect(categoryWithTotal.isIncrease, isTrue);
      });
    });
  });
}
