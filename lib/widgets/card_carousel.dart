import 'package:flutter/material.dart';
import '../data/models/card_model.dart';
import 'financial_card.dart';

/// A horizontally scrollable carousel widget that displays financial cards
/// with page indicators.
class CardCarousel extends StatefulWidget {
  final List<CardModel> cards;
  final VoidCallback onAddCard;

  const CardCarousel({
    super.key,
    required this.cards,
    required this.onAddCard,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Use 1.0 so cards take full width
    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Called when the page changes
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Builds the page indicator with animated dots
  Widget _buildPageIndicator(BuildContext context) {
    final totalDots = widget.cards.isEmpty ? 1 : widget.cards.length + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalDots,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state when no cards exist
  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: widget.onAddCard,
      child: Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_card,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              widget.cards.isEmpty ? 'Add your first card' : 'Add another card',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.cards.isEmpty 
                  ? 'Tap here to add a card and start tracking'
                  : 'Tap here to add another card to your wallet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCards = widget.cards.isEmpty ? 1 : widget.cards.length + 1;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(), // Smooth scroll with momentum
            itemCount: totalCards,
            itemBuilder: (context, index) {
              if (widget.cards.isEmpty || index == widget.cards.length) {
                return _buildEmptyState(context);
              }
              final card = widget.cards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FinancialCard(card: card),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(context),
      ],
    );
  }
}
