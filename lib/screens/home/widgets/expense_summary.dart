import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/utils/formatters.dart';

/// Enum representing the time period for expense summary
enum TimePeriod { weekly, monthly }

/// Widget that displays expense totals with a weekly/monthly toggle.
/// 
/// Features:
/// - Toggle between weekly and monthly views
/// - Display total expenses for selected period
/// - Show comparison to previous period with animated transition
/// - Format currency amounts using user's preferred currency symbol
class ExpenseSummary extends StatefulWidget {
  const ExpenseSummary({super.key});

  @override
  State<ExpenseSummary> createState() => _ExpenseSummaryState();
}

class _ExpenseSummaryState extends State<ExpenseSummary> with SingleTickerProviderStateMixin {
  TimePeriod _selectedPeriod = TimePeriod.weekly;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handles period change with animation
  void _onPeriodChanged(TimePeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
      });
      // Restart animation for smooth transition
      _animationController.reset();
      _animationController.forward();
    }
  }

  /// Calculates total expenses for the selected period
  double _calculateTotal(TransactionProvider provider) {
    final range = _selectedPeriod == TimePeriod.weekly
        ? DateRange.currentWeek()
        : DateRange.currentMonth();
    return provider.getTotalForRange(range, expensesOnly: true);
  }

  /// Calculates comparison percentage to previous period
  double _calculateComparison(TransactionProvider provider) {
    final currentRange = _selectedPeriod == TimePeriod.weekly
        ? DateRange.currentWeek()
        : DateRange.currentMonth();
    final previousRange = _selectedPeriod == TimePeriod.weekly
        ? DateRange.previousWeek()
        : DateRange.previousMonth();

    final currentTotal = provider.getTotalForRange(currentRange, expensesOnly: true);
    final previousTotal = provider.getTotalForRange(previousRange, expensesOnly: true);

    if (previousTotal == 0) return 0;
    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  /// Builds the period toggle (segmented control)
  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Weekly', TimePeriod.weekly),
          const SizedBox(width: 4),
          _buildToggleButton('Monthly', TimePeriod.monthly),
        ],
      ),
    );
  }

  /// Builds individual toggle button
  Widget _buildToggleButton(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _onPeriodChanged(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Builds the total amount display with formatted currency
  Widget _buildTotalAmount(String currencySymbol, double total) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expenses',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(currencySymbol, total),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the comparison indicator with animated transition
  Widget _buildComparisonIndicator(double comparisonPercentage) {
    if (comparisonPercentage == 0) {
      return const SizedBox.shrink();
    }

    final isIncrease = comparisonPercentage > 0;
    final color = isIncrease ? Colors.red : Colors.green;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${comparisonPercentage.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'vs last ${_selectedPeriod == TimePeriod.weekly ? 'week' : 'month'}',
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final storageService = Provider.of<StorageService>(context);
    
    final currencySymbol = storageService.currency;
    final total = _calculateTotal(transactionProvider);
    final comparison = _calculateComparison(transactionProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalAmount(currencySymbol, total),
              _buildPeriodToggle(),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonIndicator(comparison),
        ],
      ),
    );
  }
}
