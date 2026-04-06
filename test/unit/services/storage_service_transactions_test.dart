import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finman/data/services/storage_service.dart';
import 'package:finman/data/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late Directory tempDir;

  setUp(() async {
    // Setup mock secure storage
    FlutterSecureStorage.setMockInitialValues({});
    
    // Create a temporary directory for Hive
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    
    // Initialize Hive with the temporary directory
    Hive.init(tempDir.path);
    
    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    
    storageService = StorageService();
    await storageService.init();
  });

  tearDown(() async {
    // Close all boxes
    await Hive.close();
    
    // Delete the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('StorageService Transaction Filtering Methods', () {
    test('getTransactionsInDateRange returns transactions within date range', () async {
      // Arrange
      final transaction1 = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      final transaction2 = Transaction(
        id: 'txn2',
        amount: 200.0,
        category: 'Transport',
        date: DateTime(2024, 1, 20),
        isIncome: false,
      );

      final transaction3 = Transaction(
        id: 'txn3',
        amount: 300.0,
        category: 'Shopping',
        date: DateTime(2024, 2, 5),
        isIncome: false,
      );

      await storageService.addTransaction(transaction1);
      await storageService.addTransaction(transaction2);
      await storageService.addTransaction(transaction3);

      // Act
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31, 23, 59, 59);
      final filtered = storageService.getTransactionsInDateRange(start, end);

      // Assert
      expect(filtered.length, 2);
      expect(filtered.any((t) => t.id == 'txn1'), true);
      expect(filtered.any((t) => t.id == 'txn2'), true);
      expect(filtered.any((t) => t.id == 'txn3'), false);
    });

    test('getTransactionsInDateRange includes boundary dates', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      final transactionAtStart = Transaction(
        id: 'txn_start',
        amount: 100.0,
        category: 'Food',
        date: startDate,
        isIncome: false,
      );

      final transactionAtEnd = Transaction(
        id: 'txn_end',
        amount: 200.0,
        category: 'Transport',
        date: endDate,
        isIncome: false,
      );

      await storageService.addTransaction(transactionAtStart);
      await storageService.addTransaction(transactionAtEnd);

      // Act
      final filtered = storageService.getTransactionsInDateRange(startDate, endDate);

      // Assert
      expect(filtered.length, 2);
      expect(filtered.any((t) => t.id == 'txn_start'), true);
      expect(filtered.any((t) => t.id == 'txn_end'), true);
    });

    test('getTransactionsInDateRange returns empty list when no transactions in range', () async {
      // Arrange
      final transaction = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      await storageService.addTransaction(transaction);

      // Act
      final start = DateTime(2024, 2, 1);
      final end = DateTime(2024, 2, 28);
      final filtered = storageService.getTransactionsInDateRange(start, end);

      // Assert
      expect(filtered, isEmpty);
    });

    test('getTransactionsInDateRange handles year boundaries correctly', () async {
      // Arrange
      final transaction2023 = Transaction(
        id: 'txn2023',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2023, 12, 31),
        isIncome: false,
      );

      final transaction2024 = Transaction(
        id: 'txn2024',
        amount: 200.0,
        category: 'Transport',
        date: DateTime(2024, 1, 1),
        isIncome: false,
      );

      await storageService.addTransaction(transaction2023);
      await storageService.addTransaction(transaction2024);

      // Act
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final filtered = storageService.getTransactionsInDateRange(start, end);

      // Assert
      expect(filtered.length, 1);
      expect(filtered[0].id, 'txn2024');
    });

    test('getTransactionsByCategory returns transactions matching category', () async {
      // Arrange
      final transaction1 = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      final transaction2 = Transaction(
        id: 'txn2',
        amount: 200.0,
        category: 'Food',
        date: DateTime(2024, 1, 20),
        isIncome: false,
      );

      final transaction3 = Transaction(
        id: 'txn3',
        amount: 300.0,
        category: 'Transport',
        date: DateTime(2024, 1, 25),
        isIncome: false,
      );

      await storageService.addTransaction(transaction1);
      await storageService.addTransaction(transaction2);
      await storageService.addTransaction(transaction3);

      // Act
      final filtered = storageService.getTransactionsByCategory('Food');

      // Assert
      expect(filtered.length, 2);
      expect(filtered.every((t) => t.category == 'Food'), true);
      expect(filtered.any((t) => t.id == 'txn1'), true);
      expect(filtered.any((t) => t.id == 'txn2'), true);
    });

    test('getTransactionsByCategory returns empty list when no matching transactions', () async {
      // Arrange
      final transaction = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      await storageService.addTransaction(transaction);

      // Act
      final filtered = storageService.getTransactionsByCategory('Transport');

      // Assert
      expect(filtered, isEmpty);
    });

    test('getTransactionsByCategory is case-sensitive', () async {
      // Arrange
      final transaction1 = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      final transaction2 = Transaction(
        id: 'txn2',
        amount: 200.0,
        category: 'food',
        date: DateTime(2024, 1, 20),
        isIncome: false,
      );

      await storageService.addTransaction(transaction1);
      await storageService.addTransaction(transaction2);

      // Act
      final filtered = storageService.getTransactionsByCategory('Food');

      // Assert
      expect(filtered.length, 1);
      expect(filtered[0].id, 'txn1');
    });

    test('getTransactionsByCategory includes both income and expense transactions', () async {
      // Arrange
      final expense = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      final income = Transaction(
        id: 'txn2',
        amount: 500.0,
        category: 'Food',
        date: DateTime(2024, 1, 20),
        isIncome: true,
      );

      await storageService.addTransaction(expense);
      await storageService.addTransaction(income);

      // Act
      final filtered = storageService.getTransactionsByCategory('Food');

      // Assert
      expect(filtered.length, 2);
      expect(filtered.any((t) => t.isIncome == true), true);
      expect(filtered.any((t) => t.isIncome == false), true);
    });

    test('filtering methods work together correctly', () async {
      // Arrange
      final transaction1 = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        date: DateTime(2024, 1, 15),
        isIncome: false,
      );

      final transaction2 = Transaction(
        id: 'txn2',
        amount: 200.0,
        category: 'Food',
        date: DateTime(2024, 2, 15),
        isIncome: false,
      );

      final transaction3 = Transaction(
        id: 'txn3',
        amount: 300.0,
        category: 'Transport',
        date: DateTime(2024, 1, 20),
        isIncome: false,
      );

      await storageService.addTransaction(transaction1);
      await storageService.addTransaction(transaction2);
      await storageService.addTransaction(transaction3);

      // Act - First filter by date range, then by category
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final dateFiltered = storageService.getTransactionsInDateRange(start, end);
      final categoryFiltered = dateFiltered.where((t) => t.category == 'Food').toList();

      // Assert
      expect(categoryFiltered.length, 1);
      expect(categoryFiltered[0].id, 'txn1');
    });
  });
}
