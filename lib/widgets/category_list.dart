import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../core/utils/category_with_total.dart';
import '../core/utils/date_range.dart';
import '../screens/home/widgets/expense_summary.dart';
import 'category_list_item.dart';

/// A widget that displays a list of categories with their totals and comparisons.
///
/// Features:
/// - Filters categories by usage (only shows categories with transactions)
/// - Sorts categories by amount in descending order
/// - Limits display to maxItems (default 10)
/// - Shows "View All" option when more than maxItems exist
/// - Uses ListView.builder for efficient rendering
/// - Displays empty state when no expenses exist for the period
class CategoryList extends StatelessWidget {
  final TimePeriod period;
  final int maxItems;

  const CategoryList({
    super.key,
    required this.period,
    this.maxItems = 10,
  });

  /// Gets categories with their totals for the current and previous periods
  List<CategoryWithTotal> _getCategoriesWithTotals(
    CategoryProvider categoryProvider,
    TransactionProvider transactionProvider,
  ) {
    // Get date ranges based on selected period
    final currentRange = period == TimePeriod.weekly
        ? DateRange.currentWeek()
        : DateRange.currentMonth();
    final previousRange = period == TimePeriod.weekly
        ? DateRange.previousWeek()
        : DateRange.previousMonth();

    // Get category totals for both periods
    final currentTotals = transactionProvider.getCategoryTotalsForRange(currentRange);
    final previousTotals = transactionProvider.getCategoryTotalsForRange(previousRange);

    // Create CategoryWithTotal objects for categories with transactions
    final categoriesWithTotals = <CategoryWithTotal>[];
    
    for (final category in categoryProvider.categories) {
      final currentTotal = currentTotals[category.id] ?? 0.0;
      
      // Only include categories that have transactions in the current period
      if (currentTotal > 0) {
        final previousTotal = previousTotals[category.id] ?? 0.0;
        categoriesWithTotals.add(
          CategoryWithTotal(
            category: category,
            currentTotal: currentTotal,
            previousTotal: previousTotal,
          ),
        );
      }
    }

    // Sort by current total in descending order
    categoriesWithTotals.sort((a, b) => b.currentTotal.compareTo(a.currentTotal));

    return categoriesWithTotals;
  }

  /// Builds a single category item
  Widget _buildCategoryItem(CategoryWithTotal category, CategoryProvider categoryProvider) {
    return CategoryListItem(
      category: category,
      onFavoriteTap: () {
        categoryProvider.toggleFavorite(category.category.id);
      },
    );
  }

  /// Builds the empty state when no expenses exist for the period
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses this period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your expenses to see category breakdown',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final categoriesWithTotals = _getCategoriesWithTotals(
      categoryProvider,
      transactionProvider,
    );

    // Show empty state if no categories have transactions
    if (categoriesWithTotals.isEmpty) {
      return _buildEmptyState(context);
    }

    // Determine how many items to display
    final displayCount = categoriesWithTotals.length > maxItems
        ? maxItems
        : categoriesWithTotals.length;
    final hasMore = categoriesWithTotals.length > maxItems;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount + (hasMore ? 1 : 0), // +1 for "View All" option
      itemBuilder: (context, index) {
        // Show "View All" option as the last item
        if (hasMore && index == displayCount) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to view all categories screen
                debugPrint('View All tapped');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View All Categories',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Build category item
        return _buildCategoryItem(
          categoriesWithTotals[index],
          categoryProvider,
        );
      },
    );
  }
}
