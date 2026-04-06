import 'package:flutter_test/flutter_test.dart';
import 'package:finman/core/utils/formatters.dart';

void main() {
  group('Formatters.formatCurrency', () {
    group('Currency symbol prefix', () {
      test('should display currency symbol as prefix for positive amounts', () {
        expect(Formatters.formatCurrency('\$', 100.0), startsWith('\$'));
        expect(Formatters.formatCurrency('₹', 100.0), startsWith('₹'));
        expect(Formatters.formatCurrency('€', 100.0), startsWith('€'));
      });

      test('should display currency symbol after minus sign for negative amounts', () {
        final result = Formatters.formatCurrency('\$', -100.0);
        expect(result, startsWith('-'));
        expect(result, contains('\$'));
        expect(result.indexOf('-'), lessThan(result.indexOf('\$')));
      });
    });

    group('Thousand separators', () {
      test('should include thousand separators for amounts >= 1000', () {
        expect(Formatters.formatCurrency('\$', 1000.0), contains(','));
        expect(Formatters.formatCurrency('\$', 1234.56), '\$1,234.56');
        expect(Formatters.formatCurrency('₹', 10000.0), '₹10,000.00');
        expect(Formatters.formatCurrency('€', 1234567.89), '€1,234,567.89');
      });

      test('should not include thousand separators for amounts < 1000', () {
        expect(Formatters.formatCurrency('\$', 999.99), isNot(contains(',')));
        expect(Formatters.formatCurrency('\$', 100.0), '\$100.00');
        expect(Formatters.formatCurrency('₹', 50.5), '₹50.50');
      });
    });

    group('Two decimal places', () {
      test('should display exactly two decimal places for whole numbers', () {
        expect(Formatters.formatCurrency('\$', 100.0), '\$100.00');
        expect(Formatters.formatCurrency('₹', 0.0), '₹0.00');
        expect(Formatters.formatCurrency('€', 1234.0), '€1,234.00');
      });

      test('should display exactly two decimal places for decimal numbers', () {
        expect(Formatters.formatCurrency('\$', 100.5), '\$100.50');
        expect(Formatters.formatCurrency('₹', 1234.56), '₹1,234.56');
        expect(Formatters.formatCurrency('€', 99.99), '€99.99');
      });

      test('should round to two decimal places when more decimals provided', () {
        expect(Formatters.formatCurrency('\$', 100.555), '\$100.56');
        expect(Formatters.formatCurrency('₹', 100.554), '₹100.55');
        expect(Formatters.formatCurrency('€', 100.999), '€101.00');
      });
    });

    group('Negative amounts', () {
      test('should place minus sign before currency symbol', () {
        expect(Formatters.formatCurrency('\$', -100.0), '-\$100.00');
        expect(Formatters.formatCurrency('₹', -1234.56), '-₹1,234.56');
        expect(Formatters.formatCurrency('€', -0.01), '-€0.01');
      });

      test('should handle negative amounts with thousand separators', () {
        expect(Formatters.formatCurrency('\$', -1000.0), '-\$1,000.00');
        expect(Formatters.formatCurrency('₹', -10000.5), '-₹10,000.50');
        expect(Formatters.formatCurrency('€', -1234567.89), '-€1,234,567.89');
      });
    });

    group('Edge cases', () {
      test('should handle zero correctly', () {
        expect(Formatters.formatCurrency('\$', 0.0), '\$0.00');
        expect(Formatters.formatCurrency('₹', 0.0), '₹0.00');
      });

      test('should handle very small amounts', () {
        expect(Formatters.formatCurrency('\$', 0.01), '\$0.01');
        expect(Formatters.formatCurrency('₹', 0.99), '₹0.99');
      });

      test('should handle very large amounts', () {
        expect(Formatters.formatCurrency('\$', 1000000.0), '\$1,000,000.00');
        expect(Formatters.formatCurrency('₹', 9999999.99), '₹9,999,999.99');
      });

      test('should handle different currency symbols', () {
        expect(Formatters.formatCurrency('\$', 100.0), '\$100.00');
        expect(Formatters.formatCurrency('₹', 100.0), '₹100.00');
        expect(Formatters.formatCurrency('€', 100.0), '€100.00');
        expect(Formatters.formatCurrency('£', 100.0), '£100.00');
        expect(Formatters.formatCurrency('¥', 100.0), '¥100.00');
      });
    });

    group('Requirements validation', () {
      test('should meet all formatting requirements together', () {
        // Positive amount with all features
        final result1 = Formatters.formatCurrency('\$', 1234.56);
        expect(result1, startsWith('\$')); // Currency prefix
        expect(result1, contains(',')); // Thousand separator
        expect(result1, endsWith('.56')); // Two decimal places
        expect(result1, '\$1,234.56');

        // Negative amount with all features
        final result2 = Formatters.formatCurrency('₹', -5678.90);
        expect(result2, startsWith('-₹')); // Minus before currency
        expect(result2, contains(',')); // Thousand separator
        expect(result2, endsWith('.90')); // Two decimal places
        expect(result2, '-₹5,678.90');
      });
    });
  });
}
