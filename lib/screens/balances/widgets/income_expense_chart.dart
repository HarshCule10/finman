import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Grouped bar chart showing income (green) and expenses (red) per period.
class IncomeExpenseChart extends StatelessWidget {
  /// List of {income, expense} maps — one per bar group
  final List<Map<String, double>> data;

  /// Label for each bar group (days or week labels)
  final List<String> labels;

  const IncomeExpenseChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold<double>(0, (prev, d) {
      final m = [d['income']!, d['expense']!]
          .reduce((a, b) => a > b ? a : b);
      return m > prev ? m : prev;
    });

    final chartMaxY = (maxY == 0 ? 1000 : maxY * 1.25).ceilToDouble();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: SizedBox(
        key: ValueKey(data.length),
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: chartMaxY,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    Theme.of(context).colorScheme.surface,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = rodIndex == 0 ? 'Income' : 'Expense';
                  final color =
                      rodIndex == 0 ? const Color(0xFF38ef7d) : const Color(0xFFFF6B6B);
                  return BarTooltipItem(
                    '$label\n₹${rod.toY.toStringAsFixed(0)}',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value == meta.max) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '₹${(value / 1000).toStringAsFixed(0)}k',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        labels[idx],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(data.length, (i) {
              final income = data[i]['income']!;
              final expense = data[i]['expense']!;
              return BarChartGroupData(
                x: i,
                groupVertically: false,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    width: 8,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                    ),
                  ),
                  BarChartRodData(
                    toY: expense,
                    width: 8,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFFB71C1C), Color(0xFFFF6B6B)],
                    ),
                  ),
                ],
              );
            }),
          ),
          swapAnimationDuration: const Duration(milliseconds: 600),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
