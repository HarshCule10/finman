import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../providers/transaction_provider.dart';
import 'all_transactions_screen.dart';
import 'widgets/animated_balance_card.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/period_toggle.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  bool _isMonthly = false; // false = weekly, true = monthly
  int _periodOffset = 0;   // 0 = current, -1 = previous, etc.

  // ── Period navigation helpers ────────────────────────────────────────────────

  DateTime get _currentWeekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: _periodOffset * 7));
  }

  DateTime get _currentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _periodOffset);
  }

  String get _periodLabel {
    if (_isMonthly) {
      return DateFormat('MMMM yyyy').format(_currentMonth);
    } else {
      final start = _currentWeekStart;
      final end = start.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d').format(end)}';
    }
  }

  List<Map<String, double>> _getChartData(TransactionProvider provider) {
    if (_isMonthly) {
      return provider.getMonthlyChartData(_currentMonth);
    } else {
      return provider.getWeeklyChartData(_currentWeekStart);
    }
  }

  List<String> get _chartLabels {
    if (_isMonthly) {
      // Week 1…5
      final data = _getChartLabelsMonthly();
      return data;
    } else {
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
  }

  List<String> _getChartLabelsMonthly() {
    final month = _currentMonth;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final labels = <String>[];
    int week = 1;
    DateTime start = firstDay;
    while (!start.isAfter(lastDay)) {
      labels.add('W$week');
      start = start.add(const Duration(days: 7));
      week++;
    }
    return labels;
  }

  double _getPeriodIncome(TransactionProvider provider) {
    return _getChartData(provider)
        .fold(0.0, (s, d) => s + d['income']!);
  }

  double _getPeriodExpenses(TransactionProvider provider) {
    return _getChartData(provider)
        .fold(0.0, (s, d) => s + d['expense']!);
  }

  // ── Recent transactions ──────────────────────────────────────────────────────

  Widget _buildRecentTransactions(
      BuildContext context, TransactionProvider provider) {
    final recent = provider.allTransactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllTransactionsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'No transactions yet.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final t = recent[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: t.isIncome
                        ? [
                            Theme.of(context).colorScheme.surface,
                            Colors.green.withValues(alpha: 0.09),
                          ]
                        : [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.09),
                          ],
                  ),
                  border: Border.all(
                    color: (t.isIncome
                            ? Colors.green
                            : Theme.of(context).colorScheme.error)
                        .withValues(alpha: 0.18),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (t.isIncome
                              ? Colors.green
                              : Theme.of(context).colorScheme.error)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      t.isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: t.isIncome
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                  ),
                  title: Text(t.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    '${t.date.day}/${t.date.month}/${t.date.year}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                  trailing: Text(
                    Formatters.formatCurrency('₹', t.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: t.isIncome
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              )
                  .animate(delay: (index * 50).ms)
                  .slideY(begin: 0.15, end: 0, duration: 350.ms)
                  .fadeIn(duration: 300.ms);
            },
          ),
      ],
    );
  }

  // ── Chart legend ─────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Income', const Color(0xFF38ef7d)),
        const SizedBox(width: 24),
        _legendItem('Expenses', const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final chartData = _getChartData(provider);
        final periodIncome = _getPeriodIncome(provider);
        final periodExpenses = _getPeriodExpenses(provider);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'Balances',
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

                // ── Hero Balance Card ─────────────────────────────────────────
                AnimatedBalanceCard(
                  totalBalance: provider.totalBalance,
                  income: periodIncome,
                  expenses: periodExpenses,
                ),

                const SizedBox(height: 28),

                // ── Period Toggle + Navigation ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PeriodToggle(
                    isMonthly: _isMonthly,
                    onChanged: (v) => setState(() {
                      _isMonthly = v;
                      _periodOffset = 0;
                    }),
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // ── Period navigation row ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () =>
                            setState(() => _periodOffset--),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _periodLabel,
                          key: ValueKey(_periodLabel),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _periodOffset < 0
                            ? () => setState(() => _periodOffset++)
                            : null,
                        color: _periodOffset < 0
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),

                // ── Bar Chart ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IncomeExpenseChart(
                    data: chartData,
                    labels: _chartLabels,
                  ),
                ).animate(delay: 250.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 8),
                _buildLegend().animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 28),

                // ── Recent Transactions ───────────────────────────────────────
                _buildRecentTransactions(context, provider),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
