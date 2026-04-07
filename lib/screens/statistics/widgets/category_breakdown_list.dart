import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/formatters.dart';

/// Sorted list of categories with animated progress bars and percentages.
class CategoryBreakdownList extends StatelessWidget {
  final Map<String, double> categoryData;
  final bool showExpenses;
  final ValueChanged<String> onCategoryTap;

  const CategoryBreakdownList({
    super.key,
    required this.categoryData,
    required this.showExpenses,
    required this.onCategoryTap,
  });

  double get _total =>
      categoryData.values.fold(0.0, (s, v) => s + v);

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) return const SizedBox.shrink();

    final entries = categoryData.entries.toList();
    final maxValue = entries.first.value; // Already sorted descending

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Top Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(entries.length, (i) {
          final entry = entries[i];
          final cat = AppCategories.fromKey(entry.key);
          final pct = _total > 0 ? (entry.value / _total * 100) : 0.0;
          final barFraction = maxValue > 0 ? entry.value / maxValue : 0.0;
          final color = cat?.color ?? Colors.grey;

          return _CategoryRow(
            icon: cat?.icon ?? Icons.category_rounded,
            label: cat?.label ?? Formatters.capitalize(entry.key),
            amount: entry.value,
            percentage: pct,
            barFraction: barFraction,
            color: color,
            delay: (i * 80).ms,
            onTap: () => onCategoryTap(entry.key),
          );
        }),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double percentage;
  final double barFraction;
  final Color color;
  final Duration delay;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.barFraction,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: barFraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: color.withValues(alpha: 0.1),
                        ),
                        FractionallySizedBox(
                          widthFactor: value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color,
                                  color.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 350.ms).slideX(
          begin: 0.1,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}
