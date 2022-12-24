import 'package:flutter/material.dart';
import 'package:tabnews/service/storage.dart';

class CurrentTheme with ChangeNotifier {
  StorageService storage = StorageService();
  ThemeMode currentTheme = ThemeMode.system;

  CurrentTheme() {
    storage.sharedPreferencesGet('theme', 'system').then(switchTheme);
  }

  ThemeMode getCurrentTheme() => currentTheme;

  void switchTheme(String value) {
    switch (value) {
      case 'system':
        currentTheme = ThemeMode.system;
        break;

      case 'light':
        currentTheme = ThemeMode.light;
        break;

      case 'dark':
        currentTheme = ThemeMode.dark;
        break;
    }
    notifyListeners();
  }
}
