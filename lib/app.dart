import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'data/services/storage_service.dart';
import 'screens/lock/lock_screen.dart';
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
      home: _resolveHomeScreen(storage),
    );
  }

  /// Determines which screen to show on launch:
  ///   - Not onboarded → Onboarding flow
  ///   - Has security → Lock screen
  ///   - Otherwise → Main dashboard
  Widget _resolveHomeScreen(StorageService storage) {
    if (!storage.isOnboarded) return const OnboardingScreen();
    if (storage.securityType != null) return const LockScreen();
    return const AppShell();
  }
}
