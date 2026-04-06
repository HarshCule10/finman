import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeProvider(this._storage);

  ThemeMode get themeMode => _storage.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDark => _storage.isDarkMode;

  Future<void> toggle() async {
    await _storage.setDarkMode(!isDark);
    notifyListeners();
  }
}
