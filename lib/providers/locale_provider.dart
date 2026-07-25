import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/storage_service.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_loadLocale());

  static Locale _loadLocale() {
    final langCode =
        StorageService.settingsBox.get('language', defaultValue: 'ru');
    return Locale(langCode);
  }

  void setLocale(Locale locale) {
    state = locale;
    StorageService.settingsBox.put('language', locale.languageCode);
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'ru'
        ? const Locale('en')
        : const Locale('ru');
    setLocale(newLocale);
  }
}
