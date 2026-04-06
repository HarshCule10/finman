import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finman/data/models/card_model.dart';
import 'package:finman/data/services/storage_service.dart';
import 'package:finman/providers/card_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late CardProvider provider;

  setUp(() {
    // Setup mock secure storage
    FlutterSecureStorage.setMockInitialValues({});
    storage = StorageService();
    provider = CardProvider(storage);
  });

  group('CardProvider', () {
    test('should initialize with empty cards list', () {
      expect(provider.cards, isEmpty);
      expect(provider.hasCards, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('should load cards from storage', () async {
      // Add a card to storage first
      final card = CardModel(
        id: 'test-1',
        bankName: 'Test Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );
      await storage.addCard(card);

      // Load cards
      await provider.loadCards();

      expect(provider.cards, hasLength(1));
      expect(provider.cards.first.id, 'test-1');
      expect(provider.hasCards, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('should add a card', () async {
      final card = CardModel(
        id: 'test-2',
        bankName: 'Another Bank',
        cardNumber: '9876543210987654',
        cardholderName: 'Jane Smith',
        expiryDate: '06/26',
        cardType: CardType.mastercard,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );

      await provider.addCard(card);

      expect(provider.cards, hasLength(1));
      expect(provider.cards.first.id, 'test-2');
      expect(provider.hasCards, isTrue);
    });

    test('should update a card', () async {
      // Add a card first
      final card = CardModel(
        id: 'test-3',
        bankName: 'Original Bank',
        cardNumber: '1111222233334444',
        cardholderName: 'Bob Johnson',
        expiryDate: '03/27',
        cardType: CardType.visa,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );
      await provider.addCard(card);

      // Update the card
      final updatedCard = card.copyWith(bankName: 'Updated Bank');
      await provider.updateCard(updatedCard);

      expect(provider.cards, hasLength(1));
      expect(provider.cards.first.bankName, 'Updated Bank');
    });

    test('should delete a card', () async {
      // Add a card first
      final card = CardModel(
        id: 'test-4',
        bankName: 'Delete Me Bank',
        cardNumber: '5555666677778888',
        cardholderName: 'Alice Brown',
        expiryDate: '09/28',
        cardType: CardType.amex,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );
      await provider.addCard(card);
      expect(provider.cards, hasLength(1));

      // Delete the card
      await provider.deleteCard('test-4');

      expect(provider.cards, isEmpty);
      expect(provider.hasCards, isFalse);
    });

    test('should set isLoading flag during loadCards', () async {
      bool wasLoading = false;
      
      provider.addListener(() {
        if (provider.isLoading) {
          wasLoading = true;
        }
      });

      await provider.loadCards();

      expect(wasLoading, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('should notify listeners after adding a card', () async {
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      final card = CardModel(
        id: 'test-5',
        bankName: 'Notification Bank',
        cardNumber: '1234123412341234',
        cardholderName: 'Test User',
        expiryDate: '12/29',
        cardType: CardType.visa,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );

      await provider.addCard(card);

      expect(notificationCount, greaterThan(0));
    });

    test('should notify listeners after updating a card', () async {
      // Add a card first
      final card = CardModel(
        id: 'test-6',
        bankName: 'Original',
        cardNumber: '1234567890123456',
        cardholderName: 'Test User',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );
      await provider.addCard(card);

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      final updatedCard = card.copyWith(bankName: 'Updated');
      await provider.updateCard(updatedCard);

      expect(notificationCount, greaterThan(0));
    });

    test('should notify listeners after deleting a card', () async {
      // Add a card first
      final card = CardModel(
        id: 'test-7',
        bankName: 'Delete Bank',
        cardNumber: '1234567890123456',
        cardholderName: 'Test User',
        expiryDate: '12/25',
        cardType: CardType.visa,
        gradientColors: [0xFFD4C5A0, 0xFF00D09C],
      );
      await provider.addCard(card);

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      await provider.deleteCard('test-7');

      expect(notificationCount, greaterThan(0));
    });
  });
}
