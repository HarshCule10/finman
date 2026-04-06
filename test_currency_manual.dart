import 'package:finman/core/utils/formatters.dart';

void main() {
  // Test various scenarios
  print('Positive amounts:');
  print(Formatters.formatCurrency('\$', 1234.56));  // Should be: $1,234.56
  print(Formatters.formatCurrency('₹', 10000.0));   // Should be: ₹10,000.00
  print(Formatters.formatCurrency('€', 0.0));       // Should be: €0.00
  
  print('\nNegative amounts:');
  print(Formatters.formatCurrency('\$', -500.0));   // Should be: -$500.00
  print(Formatters.formatCurrency('₹', -1234.56)); // Should be: -₹1,234.56
  
  print('\nEdge cases:');
  print(Formatters.formatCurrency('\$', 0.01));     // Should be: $0.01
  print(Formatters.formatCurrency('₹', 999.99));   // Should be: ₹999.99
  print(Formatters.formatCurrency('€', 1000000.0)); // Should be: €1,000,000.00
}
