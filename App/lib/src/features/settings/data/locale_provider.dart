import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  static const _localeKey = 'app_locale';

  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    return _parseLocale(savedLocale);
  }

  Future<void> updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    state = AsyncData(locale);
  }

  Locale _parseLocale(String? languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'zh':
        return const Locale('zh');
      case 'pt':
        return const Locale('pt');
      case 'es':
        return const Locale('es');
      case 'id':
        return const Locale('id');
      default:
        // Default to English
        return const Locale('en');
    }
  }

  /// Get available locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('zh'), // Chinese
    Locale('pt'), // Portuguese
    Locale('es'), // Spanish
    Locale('id'), // Indonesian
  ];

  /// Get locale display name
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'pt':
        return 'Português';
      case 'es':
        return 'Español';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return locale.languageCode;
    }
  }
}
