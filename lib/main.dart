import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/services/secure_storage_service.dart';
import 'data/services/storage_service.dart';
import 'providers/card_provider.dart';
import 'providers/category_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = StorageService();
  await storage.init();
  
  // Initialize default categories on first app launch
  await storage.initializeDefaultCategories();

  final secureStorage = SecureStorageService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: secureStorage),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => CardProvider(storage)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(storage)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(storage)),
      ],
      child: const FinManApp(),
    ),
  );
}
