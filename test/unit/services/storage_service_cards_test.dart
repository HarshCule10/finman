import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finman/data/services/storage_service.dart';
import 'package:finman/data/models/card_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() {
    // Setup mock secure storage
    FlutterSecureStorage.setMockInitialValues({});
    storageService = StorageService();
  });

  group('StorageService Card Methods', () {
    test('getAllCards returns empty list when no cards stored', () async {
      final cards = await storageService.getAllCards();
      expect(cards, isEmpty);
    });

    test('addCard stores a card and getAllCards retrieves it', () async {
      // Arrange
      final card = CardModel(
        id: 'card1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      // Act
      await storageService.addCard(card);
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 1);
      expect(cards[0].id, 'card1');
      expect(cards[0].bankName, 'Test Bank');
      expect(cards[0].cardNumber, '1234567890123456');
      expect(cards[0].cardholderName, 'John Doe');
      expect(cards[0].expiryDate, '12/25');
      expect(cards[0].cardType, CardType.visa);
      expect(cards[0].gradientColors, [0xFF00D09C, 0xFF7B61FF]);
    });

    test('addCard preserves order of cards', () async {
      // Arrange
      final card1 = CardModel(
        id: 'card1',
        bankName: 'Bank A',
        cardNumber: '1111222233334444',
        cardholderName: 'Alice',
        expiryDate: '01/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      final card2 = CardModel(
        id: 'card2',
        bankName: 'Bank B',
        cardNumber: '5555666677778888',
        cardholderName: 'Bob',
        expiryDate: '02/26',
        cardType: CardType.mastercard,
        gradientColors: [0xFFFF6B6B, 0xFFFFBE0B],
      );

      // Act
      await storageService.addCard(card1);
      await storageService.addCard(card2);
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 2);
      expect(cards[0].id, 'card1');
      expect(cards[1].id, 'card2');
    });

    test('updateCard modifies existing card', () async {
      // Arrange
      final card = CardModel(
        id: 'card1',
        bankName: 'Old Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      await storageService.addCard(card);

      final updatedCard = card.copyWith(
        bankName: 'New Bank',
        cardholderName: 'Jane Doe',
      );

      // Act
      await storageService.updateCard(updatedCard);
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 1);
      expect(cards[0].id, 'card1');
      expect(cards[0].bankName, 'New Bank');
      expect(cards[0].cardholderName, 'Jane Doe');
      expect(cards[0].cardNumber, '1234567890123456'); // Unchanged
    });

    test('updateCard does nothing if card not found', () async {
      // Arrange
      final card1 = CardModel(
        id: 'card1',
        bankName: 'Bank A',
        cardNumber: '1111222233334444',
        cardholderName: 'Alice',
        expiryDate: '01/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      await storageService.addCard(card1);

      final nonExistentCard = CardModel(
        id: 'card999',
        bankName: 'Bank Z',
        cardNumber: '9999888877776666',
        cardholderName: 'Nobody',
        expiryDate: '12/30',
        cardType: CardType.other,
        gradientColors: [0xFF000000, 0xFFFFFFFF],
      );

      // Act
      await storageService.updateCard(nonExistentCard);
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 1);
      expect(cards[0].id, 'card1'); // Original card unchanged
    });

    test('deleteCard removes card from storage', () async {
      // Arrange
      final card1 = CardModel(
        id: 'card1',
        bankName: 'Bank A',
        cardNumber: '1111222233334444',
        cardholderName: 'Alice',
        expiryDate: '01/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      final card2 = CardModel(
        id: 'card2',
        bankName: 'Bank B',
        cardNumber: '5555666677778888',
        cardholderName: 'Bob',
        expiryDate: '02/26',
        cardType: CardType.mastercard,
        gradientColors: [0xFFFF6B6B, 0xFFFFBE0B],
      );

      await storageService.addCard(card1);
      await storageService.addCard(card2);

      // Act
      await storageService.deleteCard('card1');
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 1);
      expect(cards[0].id, 'card2');
    });

    test('deleteCard handles non-existent card gracefully', () async {
      // Arrange
      final card = CardModel(
        id: 'card1',
        bankName: 'Bank A',
        cardNumber: '1111222233334444',
        cardholderName: 'Alice',
        expiryDate: '01/25',
        cardType: CardType.visa,
        gradientColors: [0xFF00D09C, 0xFF7B61FF],
      );

      await storageService.addCard(card);

      // Act
      await storageService.deleteCard('nonexistent');
      final cards = await storageService.getAllCards();

      // Assert
      expect(cards.length, 1);
      expect(cards[0].id, 'card1');
    });

    test('card storage round-trip preserves all fields', () async {
      // Arrange
      final originalCard = CardModel(
        id: 'test-card-123',
        bankName: 'Premium Bank',
        cardNumber: '4532123456789012',
        cardholderName: 'JOHN SMITH',
        expiryDate: '06/28',
        cardType: CardType.amex,
        gradientColors: [0xFF1A2B3C, 0xFF4D5E6F],
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      // Act
      await storageService.addCard(originalCard);
      final cards = await storageService.getAllCards();
      final retrievedCard = cards[0];

      // Assert
      expect(retrievedCard.id, originalCard.id);
      expect(retrievedCard.bankName, originalCard.bankName);
      expect(retrievedCard.cardNumber, originalCard.cardNumber);
      expect(retrievedCard.cardholderName, originalCard.cardholderName);
      expect(retrievedCard.expiryDate, originalCard.expiryDate);
      expect(retrievedCard.cardType, originalCard.cardType);
      expect(retrievedCard.gradientColors, originalCard.gradientColors);
      expect(retrievedCard.createdAt, originalCard.createdAt);
    });

    test('multiple cards can be stored and retrieved', () async {
      // Arrange
      final cards = List.generate(
        5,
        (i) => CardModel(
          id: 'card$i',
          bankName: 'Bank $i',
          cardNumber: '${1000 + i}${2000 + i}${3000 + i}${4000 + i}',
          cardholderName: 'User $i',
          expiryDate: '0${i + 1}/2${i}',
          cardType: CardType.values[i % CardType.values.length],
          gradientColors: [0xFF000000 + i * 0x111111, 0xFFFFFFFF - i * 0x111111],
        ),
      );

      // Act
      for (final card in cards) {
        await storageService.addCard(card);
      }
      final retrievedCards = await storageService.getAllCards();

      // Assert
      expect(retrievedCards.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(retrievedCards[i].id, 'card$i');
        expect(retrievedCards[i].bankName, 'Bank $i');
      }
    });
  });
}
