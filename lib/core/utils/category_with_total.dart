import '../../data/models/category_model.dart';

/// Helper class for displaying categories with calculated totals and comparisons
/// 
/// This class combines a category with its current and previous period totals,
/// automatically calculating percentage change and comparison indicators.
class CategoryWithTotal {
  final CategoryModel category;
  final double currentTotal;
  final double previousTotal;
  final double percentageChange;
  final bool isNew;

  CategoryWithTotal({
    required this.category,
    required this.currentTotal,
    required this.previousTotal,
  })  : percentageChange = previousTotal > 0
            ? ((currentTotal - previousTotal) / previousTotal) * 100
            : 0,
        isNew = previousTotal == 0;

  /// Returns true if the current total increased compared to the previous period
  bool get isIncrease => percentageChange > 0;

  /// Returns true if the current total decreased compared to the previous period
  bool get isDecrease => percentageChange < 0;
}
