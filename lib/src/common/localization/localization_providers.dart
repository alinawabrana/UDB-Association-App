import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeStorageKey = 'app_locale_code';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _loadSavedLocale();
  }

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await _preferences;
    final savedCode = prefs.getString(_localeStorageKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == state) {
      return;
    }
    state = locale;
    final prefs = await _preferences;
    await prefs.setString(_localeStorageKey, locale.languageCode);
  }

  Future<void> toggleLocale() {
    if (state.languageCode == 'fr') {
      return setLocale(const Locale('en'));
    }
    return setLocale(const Locale('fr'));
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

