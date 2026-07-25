import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/storage_service.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadThemeMode());

  static ThemeMode _loadThemeMode() {
    final isDark = StorageService.settingsBox.get('darkMode', defaultValue: true);
    return isDark == true ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    StorageService.settingsBox.put('darkMode', state == ThemeMode.dark);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    StorageService.settingsBox.put('darkMode', mode == ThemeMode.dark);
  }
}
