import 'package:flutter/material.dart';
import '../data/models/card_model.dart';

/// Modal bottom sheet for selecting a card during transaction creation.
/// Displays cards with nicknames (when present) and gradient previews.
class CardSelectorSheet extends StatelessWidget {
  final List<CardModel> cards;
  final String? selectedCardId;
  final Function(CardModel?) onCardSelected;

  const CardSelectorSheet({
    super.key,
    required this.cards,
    this.selectedCardId,
    required this.onCardSelected,
  });

  /// Shows the card selector as a modal bottom sheet.
  /// Returns the selected CardModel or null if "No Card" was selected.
  static Future<CardModel?> show(
    BuildContext context, {
    required List<CardModel> cards,
    String? selectedCardId,
  }) async {
    return showModalBottomSheet<CardModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardSelectorSheet(
        cards: cards,
        selectedCardId: selectedCardId,
        onCardSelected: (card) => Navigator.pop(context, card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Card',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // "No Card" option
          ListTile(
            leading: const Icon(Icons.credit_card_off),
            title: const Text('No Card'),
            subtitle: const Text('Transaction without card'),
            selected: selectedCardId == null,
            onTap: () => onCardSelected(null),
          ),
          const Divider(),
          // Card list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final isSelected = card.id == selectedCardId;
                
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: card.gradientColors.map((c) => Color(c)).toList(),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  title: Text(
                    card.nickname ?? card.bankName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    card.nickname != null
                        ? '${card.bankName} • ${card.maskedCardNumber}'
                        : card.maskedCardNumber,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: isSelected,
                  onTap: () => onCardSelected(card),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
