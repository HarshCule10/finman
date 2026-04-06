import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(storage)),
      ],
      child: const FinManApp(),
    ),
  );
}
