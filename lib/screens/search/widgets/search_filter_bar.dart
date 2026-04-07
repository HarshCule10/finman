import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/categories.dart';

/// Row of filter chips for date range, category, and type selection.
class SearchFilterBar extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCategory;
  final bool? isIncome; // null = all
  final ValueChanged<DateTimeRange> onDateRangeSelected;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<bool?> onTypeChanged;

  const SearchFilterBar({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedCategory,
    this.isIncome,
    required this.onDateRangeSelected,
    required this.onCategorySelected,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return Column(
      children: [
        // Row 1: Date + Category
        Row(
          children: [
            Expanded(
              child: _FilterChipButton(
                icon: Icons.calendar_today_rounded,
                label: startDate != null ? 'Date Set' : 'Date Range',
                isActive: startDate != null,
                chipBg: chipBg,
                onTap: () => _pickDateRange(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterChipButton(
                icon: Icons.category_rounded,
                label: selectedCategory != null
                    ? (AppCategories.fromKey(selectedCategory!)?.label ??
                        selectedCategory!)
                    : 'Category',
                isActive: selectedCategory != null,
                chipBg: chipBg,
                onTap: () => _showCategoryPicker(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: Type toggle chips
        Row(
          children: [
            _TypeChip(
              label: 'All',
              isActive: isIncome == null,
              chipBg: chipBg,
              onTap: () => onTypeChanged(null),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: 'Income',
              isActive: isIncome == true,
              color: const Color(0xFF00E5A0),
              chipBg: chipBg,
              onTap: () => onTypeChanged(true),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: 'Expense',
              isActive: isIncome == false,
              color: const Color(0xFFFF6B6B),
              chipBg: chipBg,
              onTap: () => onTypeChanged(false),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF00E5A0),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final allCats = AppCategories.all;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Category',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          onCategorySelected(null);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allCats.length,
                  itemBuilder: (context, index) {
                    final cat = allCats[index];
                    final isSelected = selectedCategory == cat.key;
                    return GestureDetector(
                      onTap: () {
                        onCategorySelected(cat.key);
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.2)
                              : cat.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(color: cat.color, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icon, color: cat.color, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              cat.label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color chipBg;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.chipBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.1) : chipBg,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: accent.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? accent
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? accent
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? color;
  final Color chipBg;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isActive,
    this.color,
    required this.chipBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? effectiveColor.withValues(alpha: 0.12)
                : chipBg,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: effectiveColor.withValues(alpha: 0.4))
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? effectiveColor
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
