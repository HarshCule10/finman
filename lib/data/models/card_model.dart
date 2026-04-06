/// Enum representing different card network types
enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  other,
}

/// Extension methods for CardType JSON serialization
extension CardTypeJson on CardType {
  /// Converts CardType to JSON string
  String toJson() => name;

  /// Creates CardType from JSON string
  static CardType fromJson(String json) {
    return CardType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => CardType.other,
    );
  }
}

/// Model representing a financial card (credit card, debit card, etc.)
class CardModel {
  final String id;
  final String bankName;
  final String cardNumber; // Stored in full, masked in UI
  final String cardholderName;
  final String expiryDate; // Format: MM/YY
  final CardType cardType;
  final List<int> gradientColors; // Two color values for gradient
  final DateTime createdAt;

  CardModel({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cardType,
    required this.gradientColors,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Returns the masked card number with only last 4 digits visible
  /// Format: "**** **** **** 1234"
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final last4 = cardNumber.substring(cardNumber.length - 4);
    
    if (cardNumber.length == 16) {
      return "**** **** **** $last4";
    } else if (cardNumber.length == 12) {
      return "**** **** $last4";
    }
    return '**** **** **** $last4';
  }

  /// Creates a copy of this CardModel with the given fields replaced
  CardModel copyWith({
    String? id,
    String? bankName,
    String? cardNumber,
    String? cardholderName,
    String? expiryDate,
    CardType? cardType,
    List<int>? gradientColors,
  }) {
    return CardModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      gradientColors: gradientColors ?? this.gradientColors,
      createdAt: createdAt,
    );
  }

  /// Converts this CardModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'expiryDate': expiryDate,
      'cardType': cardType.toJson(),
      'gradientColors': gradientColors,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a CardModel from a JSON map
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      cardNumber: json['cardNumber'] as String,
      cardholderName: json['cardholderName'] as String,
      expiryDate: json['expiryDate'] as String,
      cardType: CardTypeJson.fromJson(json['cardType'] as String),
      gradientColors: (json['gradientColors'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
