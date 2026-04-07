import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/categories.dart';

/// Animated donut pie chart showing category breakdown.
/// Supports touch to highlight a slice and drill-down callback.
class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryData;
  final bool showExpenses;
  final ValueChanged<String> onCategoryTap;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
    required this.showExpenses,
    required this.onCategoryTap,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  double get _total =>
      widget.categoryData.values.fold(0.0, (s, v) => s + v);

  Color _colorForCategory(String key) {
    final cat = widget.showExpenses
        ? AppCategories.expense
        : AppCategories.income;
    final match = cat.where((c) => c.key == key).firstOrNull;
    return match?.color ?? Colors.grey;
  }

  String _labelForCategory(String key) {
    final cat = AppCategories.fromKey(key);
    return cat?.label ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Text(
                'No data for this period',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final entries = widget.categoryData.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });

                      // On tap up, trigger drill-down
                      if (event is FlTapUpEvent && _touchedIndex >= 0) {
                        final key = entries[_touchedIndex].key;
                        widget.onCategoryTap(key);
                      }
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 55,
                  sections: _buildSections(entries),
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
              ),
              // Center total
              TweenAnimationBuilder<double>(
                key: ValueKey(_total),
                tween: Tween(begin: 0, end: _total),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                builder: (context, value, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${_formatCompact(value)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        widget.showExpenses ? 'Spent' : 'Earned',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 16),
        // Legend chips
        _buildLegend(entries),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> entries,
  ) {
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final entry = entries[i];
      final pct = _total > 0 ? (entry.value / _total * 100) : 0.0;
      final color = _colorForCategory(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 36 : 28,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: 1.0,
      );
    });
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries.map((e) {
        final color = _colorForCategory(e.key);
        final label = _labelForCategory(e.key);
        return GestureDetector(
          onTap: () => widget.onCategoryTap(e.key),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  String _formatCompact(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
