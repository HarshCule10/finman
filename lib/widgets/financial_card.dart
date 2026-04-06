import 'package:flutter/material.dart';
import '../data/models/card_model.dart';

/// A widget that displays a financial card with gradient background
/// and all card details including bank name, masked card number,
/// cardholder name, expiry date, and card type icon.
class FinancialCard extends StatelessWidget {
  final CardModel card;

  const FinancialCard({
    super.key,
    required this.card,
  });

  /// Returns the masked card number in format "**** **** **** 1234"
  String _getMaskedCardNumber() {
    return card.maskedCardNumber;
  }

  /// Returns the appropriate icon widget for the card type
  Widget _getCardTypeIcon() {
    IconData iconData;
    
    switch (card.cardType) {
      case CardType.visa:
        // Using a credit card icon as placeholder for Visa
        iconData = Icons.credit_card;
        break;
      case CardType.mastercard:
        // Using a credit card icon as placeholder for Mastercard
        iconData = Icons.credit_card;
        break;
      case CardType.amex:
        // Using a credit card icon as placeholder for Amex
        iconData = Icons.credit_card;
        break;
      case CardType.discover:
        // Using a credit card icon as placeholder for Discover
        iconData = Icons.credit_card;
        break;
      case CardType.other:
        // Generic card icon for other/unknown types
        iconData = Icons.credit_card_outlined;
        break;
    }

    return Icon(
      iconData,
      color: Colors.white.withValues(alpha: 0.9),
      size: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create gradient from the card's gradient colors
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: card.gradientColors.map((colorValue) => Color(colorValue)).toList(),
    );

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Bank name (left) and Card type icon (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.bankName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _getCardTypeIcon(),
                ],
              ),
              
              const Spacer(),
              
              // Center: Masked card number
              Text(
                _getMaskedCardNumber(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              
              const Spacer(),
              
              // Bottom row: Cardholder name (left) and Expiry date (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.cardholderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    card.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Premium Glossy Overlay
        Positioned(
          top: -100,
          right: -50,
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
