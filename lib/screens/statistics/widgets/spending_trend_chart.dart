import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Curved line chart showing daily spending trend over a period.
class SpendingTrendChart extends StatefulWidget {
  final List<Map<String, dynamic>> data; // [{date, amount}, ...]

  const SpendingTrendChart({super.key, required this.data});

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart> {
  int? _touchedIndex;

  double get _maxY {
    if (widget.data.isEmpty) return 100;
    final max = widget.data
        .map((d) => (d['amount'] as double))
        .reduce((a, b) => a > b ? a : b);
    return max == 0 ? 100 : max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final labelColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

    if (widget.data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No spending data yet',
            style: TextStyle(color: labelColor, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: gridColor,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: _maxY / 4,
                getTitlesWidget: (value, meta) {
                  if (value == _maxY) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _formatCompact(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _bottomInterval,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= widget.data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = widget.data[idx]['date'] as DateTime;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('d/M').format(date),
                      style: TextStyle(
                        fontSize: 9,
                        color: labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (widget.data.length - 1).toDouble(),
          minY: 0,
          maxY: _maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              setState(() {
                if (event is FlTapUpEvent ||
                    event is FlPanEndEvent ||
                    event is FlLongPressEnd) {
                  _touchedIndex = null;
                } else if (response?.lineBarSpots != null &&
                    response!.lineBarSpots!.isNotEmpty) {
                  _touchedIndex =
                      response.lineBarSpots!.first.spotIndex;
                }
              });
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final idx = spot.spotIndex;
                  final date = widget.data[idx]['date'] as DateTime;
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n',
                    TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '₹${spot.y.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                widget.data.length,
                (i) => FlSpot(
                  i.toDouble(),
                  widget.data[i]['amount'] as double,
                ),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFF00E5A0),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isTouched = index == _touchedIndex;
                  return FlDotCirclePainter(
                    radius: isTouched ? 5 : 0,
                    color: const Color(0xFF00E5A0),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00E5A0).withValues(alpha: 0.25),
                    const Color(0xFF00E5A0).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }

  double get _bottomInterval {
    final len = widget.data.length;
    if (len <= 7) return 1;
    if (len <= 14) return 2;
    return (len / 6).ceilToDouble();
  }

  String _formatCompact(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
