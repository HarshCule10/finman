import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A selectable card for choosing a security type (PIN / Password / Skip).
/// Highlights with an accent border and subtle fill when selected.
class SecurityOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const SecurityOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color ?? colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Theme.of(context).dividerColor,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.primary.withValues(alpha: 0.06),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : AppColors.textGrey,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? null : AppColors.textGrey,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                  ),
                ],
              ),
            ),

            // Checkmark
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
