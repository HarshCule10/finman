import 'package:flutter/material.dart';
import '../core/utils/category_with_total.dart';
import '../core/utils/formatters.dart';
import '../core/theme/app_colors.dart';

/// A widget that displays a single category item in the list with all its details
/// and comparison indicators.
///
/// This widget shows:
/// - Category icon with circular background
/// - Category name and comparison text
/// - Total amount (right-aligned, large font)
/// - Comparison indicator (up/down arrow or "New")
/// - Star icon (filled if favorite, outlined if not)
/// - Ripple effect on tap
/// - Card background with rounded corners and subtle shadow
class CategoryListItem extends StatelessWidget {
  final CategoryWithTotal category;
  final VoidCallback onFavoriteTap;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onFavoriteTap,
  });

  /// Builds the comparison indicator widget showing increase/decrease or "New"
  Widget _buildComparisonIndicator() {
    if (category.isNew) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'New',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final isIncrease = category.isIncrease;
    final color = isIncrease ? AppColors.expense : AppColors.income;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;
    final percentageText = '${category.percentageChange.abs().toStringAsFixed(1)}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          percentageText,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = Color(category.category.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Handle category tap - could navigate to category details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon with circular background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(category.category.iconName),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Category name and comparison indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.category.name,
                      style: TextStyle(
                        color: isDark ? AppColors.textWhite : AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildComparisonIndicator(),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Total amount (right-aligned)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency('₹', category.currentTotal),
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Favorite star icon
              InkWell(
                onTap: onFavoriteTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    category.category.isFavorite
                        ? Icons.star
                        : Icons.star_border,
                    color: category.category.isFavorite
                        ? AppColors.warning
                        : AppColors.textGrey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts icon name string to IconData
  IconData _getIconData(String iconName) {
    // Map common icon names to Material Icons
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pets':
        return Icons.pets;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.category;
    }
  }
}
