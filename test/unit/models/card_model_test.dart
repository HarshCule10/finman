import 'package:flutter_test/flutter_test.dart';
import 'package:finman/data/models/card_model.dart';

void main() {
  group('CardModel', () {
    test('creates CardModel with all required fields', () {
      final card = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      expect(card.id, 'card_1');
      expect(card.bankName, 'Test Bank');
      expect(card.cardNumber, '1234567890123456');
      expect(card.cardholderName, 'John Doe');
      expect(card.expiryDate, '12/25');
      expect(card.cardType, CardType.visa);
      expect(card.gradientColors, [0xFF00D09C, 0xFF7B61FF]);
      expect(card.createdAt, isNotNull);
    });

    test('maskedCardNumber returns correctly masked number', () {
      final card = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      expect(card.maskedCardNumber, '**** **** **** 3456');
    });

    test('maskedCardNumber handles short card numbers', () {
      final card = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '123',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      expect(card.maskedCardNumber, '123');
    });

    test('copyWith creates new instance with updated fields', () {
      final card = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      final updatedCard = card.copyWith(
        bankName: 'New Bank',
        cardholderName: 'Jane Doe',
      );

      expect(updatedCard.id, 'card_1');
      expect(updatedCard.bankName, 'New Bank');
      expect(updatedCard.cardholderName, 'Jane Doe');
      expect(updatedCard.cardNumber, '1234567890123456');
      expect(updatedCard.expiryDate, '12/25');
      expect(updatedCard.createdAt, card.createdAt);
    });

    test('toJson serializes CardModel correctly', () {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      final card = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
        createdAt: createdAt,
      );

      final json = card.toJson();

      expect(json['id'], 'card_1');
      expect(json['bankName'], 'Test Bank');
      expect(json['cardNumber'], '1234567890123456');
      expect(json['cardholderName'], 'John Doe');
      expect(json['expiryDate'], '12/25');
      expect(json['cardType'], 'visa');
      expect(json['gradientColors'], [0xFF00D09C, 0xFF7B61FF]);
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('fromJson deserializes CardModel correctly', () {
      final json = {
        'id': 'card_1',
        'bankName': 'Test Bank',
        'cardNumber': '1234567890123456',
        'cardholderName': 'John Doe',
        'expiryDate': '12/25',
        'cardType': 'visa',
        'gradientColors': [0xFF00D09C, 0xFF7B61FF],
        'createdAt': '2024-01-15T10:30:00.000',
      };

      final card = CardModel.fromJson(json);

      expect(card.id, 'card_1');
      expect(card.bankName, 'Test Bank');
      expect(card.cardNumber, '1234567890123456');
      expect(card.cardholderName, 'John Doe');
      expect(card.expiryDate, '12/25');
      expect(card.cardType, CardType.visa);
      expect(card.gradientColors, [0xFF00D09C, 0xFF7B61FF]);
      expect(card.createdAt, DateTime.parse('2024-01-15T10:30:00.000'));
    });

    test('JSON round-trip preserves all data', () {
      final original = CardModel(
        id: 'card_1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.mastercard,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = CardModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.bankName, original.bankName);
      expect(restored.cardNumber, original.cardNumber);
      expect(restored.cardholderName, original.cardholderName);
      expect(restored.expiryDate, original.expiryDate);
      expect(restored.cardType, original.cardType);
      expect(restored.gradientColors, original.gradientColors);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles all CardType values', () {
      final cardTypes = ['visa', 'mastercard', 'amex', 'discover', 'other'];

      for (final type in cardTypes) {
        final json = {
          'id': 'card_1',
          'bankName': 'Test Bank',
          'cardNumber': '1234567890123456',
          'cardholderName': 'John Doe',
          'expiryDate': '12/25',
          'cardType': type,
          'gradientColors': [0xFF00D09C, 0xFF7B61FF],
          'createdAt': '2024-01-15T10:30:00.000',
        };

        final card = CardModel.fromJson(json);
        expect(card.cardType.name, type);
      }
    });

    test('fromJson defaults to CardType.other for unknown type', () {
      final json = {
        'id': 'card_1',
        'bankName': 'Test Bank',
        'cardNumber': '1234567890123456',
        'cardholderName': 'John Doe',
        'expiryDate': '12/25',
        'cardType': 'unknown_type',
        'gradientColors': [0xFF00D09C, 0xFF7B61FF],
        'createdAt': '2024-01-15T10:30:00.000',
      };

      final card = CardModel.fromJson(json);
      expect(card.cardType, CardType.other);
    });
  });
}
