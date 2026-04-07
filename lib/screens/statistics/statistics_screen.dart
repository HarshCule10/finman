import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/category_breakdown_list.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/category_transactions_sheet.dart';
import 'widgets/spending_trend_chart.dart';

/// Statistics screen with animated pie chart, spending trend line graph,
/// and sorted category breakdown — with income/expense toggle.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _showExpenses = true; // true=expenses, false=income

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) {
      setState(() => _selectedMonth = next);
    }
  }

  bool get _canGoNext {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return !next.isAfter(DateTime(now.year, now.month));
  }

  void _onCategoryTap(String key) {
    CategoryTransactionsSheet.show(context, key, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final categoryData = provider.getCategoryBreakdownForMonth(
      _selectedMonth,
      expensesOnly: _showExpenses,
    );
    final trendData = provider.getDailySpendingTrend();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Month navigation ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      key: ValueKey(_selectedMonth),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _canGoNext ? _nextMonth : null,
                    color: _canGoNext
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Income / Expense toggle ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildToggle(context),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // ── Pie Chart ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CategoryPieChart(
                key: ValueKey('${_selectedMonth}_$_showExpenses'),
                categoryData: categoryData,
                showExpenses: _showExpenses,
                onCategoryTap: _onCategoryTap,
              ),
            ),

            const SizedBox(height: 32),

            // ── Spending Trend ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Spending Trend (30 days)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SpendingTrendChart(data: trendData),
            ),

            const SizedBox(height: 32),

            // ── Category Breakdown List ─────────────────────────────────
            CategoryBreakdownList(
              key: ValueKey('list_${_selectedMonth}_$_showExpenses'),
              categoryData: categoryData,
              showExpenses: _showExpenses,
              onCategoryTap: _onCategoryTap,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton(
            label: 'Expenses',
            isActive: _showExpenses,
            color: const Color(0xFFFF6B6B),
            primary: primary,
            onTap: () => setState(() => _showExpenses = true),
          ),
          _toggleButton(
            label: 'Income',
            isActive: !_showExpenses,
            color: const Color(0xFF00E5A0),
            primary: primary,
            onTap: () => setState(() => _showExpenses = false),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool isActive,
    required Color color,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? color
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
