import 'package:flutter/material.dart';
import '../core/constants/categories.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? category.color.withValues( alpha: 0.2) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? category.color : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? category.color : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
