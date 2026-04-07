import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/categories.dart';

/// Horizontal row of active filter pills with individual ✕ dismiss buttons.
class ActiveFiltersRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCategory;
  final bool? isIncome;
  final VoidCallback onClearDates;
  final VoidCallback onClearCategory;
  final VoidCallback onClearType;
  final VoidCallback onClearAll;

  const ActiveFiltersRow({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedCategory,
    this.isIncome,
    required this.onClearDates,
    required this.onClearCategory,
    required this.onClearType,
    required this.onClearAll,
  });

  bool get _hasFilters =>
      startDate != null || selectedCategory != null || isIncome != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasFilters) return const SizedBox.shrink();

    final pills = <Widget>[];

    if (startDate != null && endDate != null) {
      pills.add(_pill(
        context,
        '${DateFormat('MMM d').format(startDate!)} – ${DateFormat('MMM d').format(endDate!)}',
        const Color(0xFF3B82F6),
        onClearDates,
      ));
    }

    if (selectedCategory != null) {
      final cat = AppCategories.fromKey(selectedCategory!);
      pills.add(_pill(
        context,
        cat?.label ?? selectedCategory!,
        cat?.color ?? Colors.grey,
        onClearCategory,
      ));
    }

    if (isIncome != null) {
      pills.add(_pill(
        context,
        isIncome! ? 'Income' : 'Expense',
        isIncome! ? const Color(0xFF00E5A0) : const Color(0xFFFF6B6B),
        onClearType,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...pills,
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
      BuildContext context, String label, Color color, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}
