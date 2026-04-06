import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'data/services/storage_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/app_shell.dart';

class FinManApp extends StatelessWidget {
  const FinManApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final storage = context.read<StorageService>();

    return MaterialApp(
      title: 'FinMan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: storage.isOnboarded ? const AppShell() : const OnboardingScreen(),
    );
  }
}
