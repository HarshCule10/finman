import 'package:flutter_test/flutter_test.dart';
import 'package:finman/data/models/card_model.dart';

void main() {
  group('CardType Enum', () {
    test('enum has all required values', () {
      expect(CardType.values.length, 5);
      expect(CardType.values, contains(CardType.visa));
      expect(CardType.values, contains(CardType.mastercard));
      expect(CardType.values, contains(CardType.amex));
      expect(CardType.values, contains(CardType.discover));
      expect(CardType.values, contains(CardType.other));
    });

    test('enum name property returns correct string', () {
      expect(CardType.visa.name, 'visa');
      expect(CardType.mastercard.name, 'mastercard');
      expect(CardType.amex.name, 'amex');
      expect(CardType.discover.name, 'discover');
      expect(CardType.other.name, 'other');
    });

    test('toJson extension method serializes to string', () {
      // Validates: Requirements 4.1, 20.1
      expect(CardType.visa.toJson(), 'visa');
      expect(CardType.mastercard.toJson(), 'mastercard');
      expect(CardType.amex.toJson(), 'amex');
      expect(CardType.discover.toJson(), 'discover');
      expect(CardType.other.toJson(), 'other');
    });

    test('fromJson extension method deserializes from string', () {
      // Validates: Requirements 4.1, 20.1
      expect(CardTypeJson.fromJson('visa'), CardType.visa);
      expect(CardTypeJson.fromJson('mastercard'), CardType.mastercard);
      expect(CardTypeJson.fromJson('amex'), CardType.amex);
      expect(CardTypeJson.fromJson('discover'), CardType.discover);
      expect(CardTypeJson.fromJson('other'), CardType.other);
    });

    test('fromJson defaults to CardType.other for unknown values', () {
      // Validates: Requirements 20.1
      expect(CardTypeJson.fromJson('unknown'), CardType.other);
      expect(CardTypeJson.fromJson('invalid_type'), CardType.other);
      expect(CardTypeJson.fromJson(''), CardType.other);
    });

    test('JSON serialization round-trip preserves enum value', () {
      // Validates: Requirements 4.1, 20.1
      for (final cardType in CardType.values) {
        // Serialize to string
        final jsonString = cardType.toJson();
        
        // Deserialize back to enum
        final restored = CardTypeJson.fromJson(jsonString);
        
        expect(restored, cardType);
      }
    });

    test('extension methods work in CardModel serialization', () {
      // Validates: Requirements 4.1, 20.1
      final card = CardModel(
        id: 'test_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'Test User',
        expiryDate: '12/25',
        cardType: CardType.amex,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      final json = card.toJson();
      expect(json['cardType'], 'amex');

      final restored = CardModel.fromJson(json);
      expect(restored.cardType, CardType.amex);
    });
  });
}
