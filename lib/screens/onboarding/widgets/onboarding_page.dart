import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable layout for a single onboarding page.
/// Provides consistent spacing with an icon slot, title, subtitle, and
/// a flexible content area below.
class OnboardingPage extends StatelessWidget {
  final IconData? icon;
  final Widget? imageWidget;
  final String title;
  final String subtitle;
  final Widget content;

  const OnboardingPage({
    super.key,
    this.icon,
    this.imageWidget,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Hero visual — either a custom image widget or an icon
          if (imageWidget != null)
            imageWidget!
          else if (icon != null)
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),

          const SizedBox(height: 28),

          // Content slot
          Expanded(
            flex: 3,
            child: content
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .slideY(begin: 0.15, curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }
}
